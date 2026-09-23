/*
 * Timers and software time base (0x0040 timers_init, 0x0158 zc_watch_init,
 * 0x016A timebase).
 *
 * Hardware timers (8 MHz internal oscillator, Fosc/4 = 2 MHz):
 *   TMR0  1:2 prescaler, reloaded +0x38 -> interrupt every 200 us (isr_tmr0:
 *         triac gate timing inside the mains half cycle)
 *   TMR1  1:2 prescaler = 1 MHz free running, captured by CCP1 on each mains
 *         zero-cross edge (isr_ccp1_zc)
 *   TMR2  1:4 prescaler, PR2 = 249, 1:2 postscaler -> interrupt every 1 ms
 *         (isr_tmr2: debouncing, ADC start, SPI resync, 10 ms tick)
 *
 * Software ticks, handed to the main loop as one-pass flags in `tickflags`:
 *   bit 2  10 ms   from TMR2 (isr_tmr2 sets bit 0, timebase turns it into bit 2)
 *   bit 3  100 ms  from the mains zero-cross count (isr_ccp1_zc sets flags25.5)
 *   bit 4  1 s     10 x 100 ms
 *   bit 5  10 s    10 x 1 s
 * so the 100 ms / 1 s / 10 s ticks stop when the mains is missing.
 *
 * Every tick decrements a list of down-counters used by the other modules;
 * all of them (except the startup / zero-cross / UART ones) only run once the
 * machine is "started" (sysflags.2, 0.8 s after reset).
 */
#include "pb.h"

/* sysflags */
#define SYS_STARTED     0x04    /* startup delay elapsed, state machine runs  */
#define SYS_MAINS_LOST  0x20    /* no valid zero-cross                         */
#define SYS_UART_TX     0x80    /* UART transmit in progress                   */

/* tickflags */
#define TICK_RAW10MS    0x01    /* set by isr_tmr2                             */
#define TICK_10MS       0x04
#define TICK_100MS      0x08
#define TICK_1S         0x10
#define TICK_10S        0x20

/* flags25 */
#define MAINS_100MS     0x20    /* set by isr_ccp1_zc every 10/12 half cycles  */

/* 0x1030: auto-off delays in 10 s units, indexed by set_autooff:
 * 15 min, 30 min, 1 h, 2 h, 3 h */
static const uint16_t autooff_table[5] = { 90, 180, 360, 720, 1080 };

#define DEC_NZ(x)   do { if (x) (x)--; } while (0)

/* 0x0040: timers, capture, and the initial value of the software timers */
void timers_init(void)
{
    T0CONbits.TMR0ON = 0;
    TMR0L = 0x37;
    T0CON = 0xC0;               /* on, 8 bit, Fosc/4, 1:2 -> 200 us with +0x38 */
    INTCONbits.TMR0IF = 0;
    INTCONbits.TMR0IE = 1;

    T1CONbits.TMR1ON = 0;
    CCP1CON = 0x05;             /* capture on every rising edge (then toggled)  */
    PIR1bits.CCP1IF = 0;
    PIE1bits.CCP1IE = 1;
    T1CON = 0x10;               /* Fosc/4, 1:2 -> 1 us per count                */
    T1CONbits.TMR1ON = 1;

    TMR2 = 0;
    T2CON = 0x09;               /* 1:4 prescaler, 1:2 postscaler                */
    PR2 = 0xF9;                 /* -> 1 ms                                      */
    T2CONbits.TMR2ON = 1;
    PIR1bits.TMR2IF = 0;
    PIE1bits.TMR2IE = 1;

    T3CON = 0;
    PIR2bits.TMR3IF = 0;

    /* 60 Hz values until isr_ccp1_zc has measured the mains */
    ac_sample_delay = 4;
    halfcycles_100ms = 12;
    mains_100ms_cnt = 12;
    div_10ms = 10;
    div_1s = 10;
    div_10s = 10;
    startup_timer = 80;         /* 0.8 s */

    bu_delay_down = 30;
    bu_delay_up = 30;
    re9d = 10;
    heatA_hold = 10;
    heatB_hold = 10;
    bu_softstart = 50;
    bu_runon = 50;
    ready_timer = 4500;
    wake_timer = 0;
    ready_countdown = 100;
    reda = 20;
    lang_cycle_timer2 = 30;
    reb4 = 20;
    active_timer = 100;
    recf = 100;
    reed = 12;
    ref3 = 36;
    autooff_time = autooff_table[set_autooff];
    reea = 6;
    grounds_timer = 0x6540;     /* 25920 x 10 s = 72 h */
    energy_timer = 60;
    eco_timer = 120;

    /* start the input debouncers from the current pin levels */
    if (PORTCbits.RC1)          /* brew unit encoder */
        ioflags |= 0x04;
    else
        ioflags &= ~0x04;
    r053 = 3;
    if (PORTAbits.RA6)          /* flowmeter */
        ioflags |= 0x02;
    else
        ioflags &= ~0x02;
    r055 = 3;
}

/* 0x0158: zero-cross watchdog. Until the first valid zero-cross the mains is
 * considered present; 80 ms without one sets sysflags.5 (timebase). */
void zc_watch_init(void)
{
    zc_watchdog = 8;
    zc_lost_cnt = 5;
    zc_ok_cnt = 5;
    sysflags &= ~SYS_MAINS_LOST;
}

/* 0x016A: turn the interrupt ticks into one-pass flags and run the timers.
 * Called first in every main loop pass. */
void timebase(void)
{
    loop_tasks++;
    tickflags &= ~(TICK_10MS | TICK_100MS | TICK_1S | TICK_10S);

    /* ---- 10 ms */
    if (tickflags & TICK_RAW10MS) {
        tickflags &= ~TICK_RAW10MS;
        tickflags |= TICK_10MS;

        if (startup_timer) {
            startup_timer--;
            if (startup_timer == 0)
                sysflags |= SYS_STARTED;
        }
        if (zc_watchdog) {
            zc_watchdog--;
            if (zc_watchdog == 0) {         /* 80 ms without a zero-cross */
                sysflags |= SYS_MAINS_LOST;
                zc_ok_cnt = 5;
            }
        }
        if (uart_tx_to) {
            uart_tx_to--;
            if (uart_tx_to == 0)
                sysflags &= ~SYS_UART_TX;
        }
        if (uart_rx_to) {
            uart_rx_to--;
            if (uart_rx_to == 0)            /* inter-byte timeout: restart the frame */
                uart_rx_idx = 0;
        }
        if (sysflags & SYS_STARTED) {
            DEC_NZ(ee_write_timer);
            DEC_NZ(re9d);
            DEC_NZ(heatA_hold);
            DEC_NZ(heatB_hold);
            DEC_NZ(bu_softstart);
            DEC_NZ(bu_runon);
            DEC_NZ(bu_delay_down);
            DEC_NZ(bu_delay_up);
            DEC_NZ(r09c);                   /* 16 bit */
            DEC_NZ(progress_hold);
        }
    }

    /* ---- 100 ms, counted in mains half cycles */
    if (!(flags25 & MAINS_100MS))
        return;
    flags25 &= ~MAINS_100MS;
    tickflags |= TICK_100MS;
    if (sysflags & SYS_STARTED) {
        DEC_NZ(reda);
        DEC_NZ(step_timer);                 /* 16 bit */
        DEC_NZ(flow_watchdog2);
        DEC_NZ(bu_idle);
        DEC_NZ(red8);
        DEC_NZ(rebb);
        DEC_NZ(reb8);
        DEC_NZ(reb5);
        DEC_NZ(lang_cycle_timer);
        DEC_NZ(test_key_sel);
        DEC_NZ(link_timeout);
        DEC_NZ(prog_press_timer);
        DEC_NZ(reba);
        DEC_NZ(reb9);
        DEC_NZ(flow_start_delay);
        DEC_NZ(reb4);
        DEC_NZ(red6);
        DEC_NZ(rec4);
        DEC_NZ(rebd);
        DEC_NZ(preheat_delay);
        DEC_NZ(red3);
        DEC_NZ(cappu_toggle_win);
        if (uptime_100ms != 0xFFFF)         /* saturates */
            uptime_100ms++;
    }

    /* ---- 1 s */
    if (--div_1s != 0)
        return;
    div_1s = 10;
    tickflags |= TICK_1S;
    if (sysflags & SYS_STARTED) {
        DEC_NZ(activity_timer);
        DEC_NZ(rf03);
        DEC_NZ(rf07);
        DEC_NZ(bu_idle_delay);
        DEC_NZ(ref9);
        DEC_NZ(menu_timeout);
        DEC_NZ(rf04);
        DEC_NZ(less_coffee_timer);
        DEC_NZ(beans_alarm_timer);
        DEC_NZ(refc);
        DEC_NZ(refb);
        DEC_NZ(rf01);
        DEC_NZ(ref7);
        DEC_NZ(refa);
    }

    /* ---- 10 s */
    if (--div_10s != 0)
        return;
    div_10s = 10;
    tickflags |= TICK_10S;
    if (sysflags & SYS_STARTED) {
        DEC_NZ(ref3);
        DEC_NZ(reed);
        DEC_NZ(reea);
        DEC_NZ(reee);
        DEC_NZ(ref0);
    }
}
