/*
 * Interrupts (0x6FCE isr, 0x04DA isr_tmr0, 0x05CA isr_tmr2, 0x06BC
 * isr_ccp1_zc, 0x04AA/0x04C2 mains_set_50hz/60hz).
 *
 * Single priority level (IPEN = 0). The handler serves one source per entry,
 * in this order: TMR0, SSP (SPI from the display), CCP1 (zero-cross), TMR2,
 * ADC, UART RX, UART TX. The original saves the compiler temporaries
 * r000-r00E, FSR0-2, TBLPTR, TABLAT and PROD in rF63-rF7F; the compiler does
 * that here.
 *
 * Mains and triacs
 * ----------------
 * RC2 carries the mains zero-cross. CCP1 captures TMR1 (1 us) on alternating
 * edges, so every half cycle gives one capture. A valid half period is
 * 8000-12000 us at 50 Hz, 6600-10000 us at 60 Hz. On each valid one:
 *  - the triac outputs of PORTD are written from portd_req (outputs_task),
 *    with the gates of the pump (RD4) and RD2 held for 2 ms (gate_timer = 10
 *    TMR0 ticks), so these loads conduct for the whole half cycle;
 *  - the heaters (RD1 coffee, RD7 steam) use burst firing: fire_timer expires
 *    just before the next zero-cross (9 ms / 7.6 ms), isr_tmr0 decides then
 *    whether the next half cycle is on, raises the gate and latches the
 *    decision (tickflags.7 / ioflags.5) so the zero-cross keeps the gate up
 *    until gate_timer reaches 3 (1.4 ms). The heater power is a number of half
 *    cycles on per window of 320 half cycles (heaterN_window);
 *  - the brew unit motor (RB2 up, RB5 down, active low) is phase-angle fired:
 *    a single 200 us pulse when zc_ticks = 10, i.e. 2 ms after the edge that
 *    reset zc_ticks.
 */
#include "pb.h"

/* sysflags */
#define SYS_FLOW_PULSE  0x01    /* flowmeter rising edge                       */
#define SYS_ENC_PULSE   0x10    /* brew unit encoder rising edge               */
#define SYS_MAINS_LOST  0x20

/* tickflags */
#define TICK_RAW10MS    0x01
#define HEATA_FIRED     0x80    /* heater 1 fires this half cycle              */

/* ioflags */
#define IO_FLOW_LEVEL   0x02    /* debounced RA6                               */
#define IO_ENC_LEVEL    0x04    /* debounced RC1                               */
#define HEATB_FIRED     0x20    /* heater 2 fires this half cycle              */
#define IO_PUMP_PULSED  0x40    /* pump in pulse mode (pump_period/on_cycles)  */
#define HEATA_FILL      0x80    /* heater 1 takes the half cycles heater 2
                                   leaves free (and is not windowed)           */
/* flags21 */
#define MOTOR_UP        0x01
#define HEATA_GATE      0x04    /* heater 1 requested (portd_req.1)            */
#define MOTOR_DOWN      0x20
/* gateflags2 */
#define HEATB_GATE      0x02    /* heater 2 requested (portd_req.7)            */
/* flags26 */
#define HEATB_FILL      0x01    /* heater 2 takes the half cycles heater 1
                                   leaves free                                 */
/* flags25 */
#define MAINS_KNOWN     0x08
#define MAINS_50HZ      0x10
#define MAINS_100MS     0x20
/* flags28 */
#define ZC_NEXT_RISING  0x80    /* CCP1 now waits for a rising edge            */
/* heatflags: apply a new power at once instead of at the end of the window */
#define HEATB_NOW       0x20
#define HEATA_NOW       0x40

#define WINDOW  0x140           /* 320 half cycles per heater power window     */

/* 0x04AA */
static void mains_set_50hz(void)
{
    ac_sample_delay = 5;
    flags25 |= MAINS_KNOWN | MAINS_50HZ;
    halfcycles_100ms = 10;
    burst_fire_delay = 45;      /* 9 ms */
}

/* 0x04C2 */
static void mains_set_60hz(void)
{
    ac_sample_delay = 4;
    flags25 |= MAINS_KNOWN;
    flags25 &= ~MAINS_50HZ;
    halfcycles_100ms = 12;
    burst_fire_delay = 38;      /* 7.6 ms */
}

/* 0x04DA: every 200 us */
static void isr_tmr0(void)
{
    INTCONbits.TMR0IF = 0;
    TMR0L += 0x38;

    /* end of the gate pulses started at the zero-cross */
    if (gate_timer) {
        gate_timer--;
        if (gate_timer == 3) {              /* 1.4 ms: heaters */
            portd_tmp = PORTD;
            portd_tmp &= 0x7D;
            PORTD = portd_tmp;
        } else if (gate_timer == 0) {       /* 2 ms: heaters, RD2, pump */
            portd_tmp = PORTD;
            portd_tmp &= 0x69;
            PORTD = portd_tmp;
        }
    }

    /* brew unit motor: phase-angle pulse 2 ms after the zero-cross */
    if (zc_ticks != 0xFF)
        zc_ticks++;
    if (flags21 & MOTOR_UP) {
        if (zc_ticks == 10)
            PORTBbits.RB2 = 0;
    } else {
        PORTBbits.RB2 = 1;
    }
    if (flags21 & MOTOR_DOWN) {
        if (zc_ticks == 10)
            PORTBbits.RB5 = 0;
    } else {
        PORTBbits.RB5 = 1;
    }

    /* just before the next zero-cross: heater burst decisions */
    if (fire_timer == 0)
        return;
    fire_timer--;
    if (fire_timer != 0)
        return;

    /* heater 1 (RD1). Fires when requested and inside its share of the
     * window, or always in fill mode unless heater 2 fires this half cycle.
     * The first "on" decision only arms tickflags.7, the gate is raised from
     * the second one. */
    if ((flags21 & HEATA_GATE) &&
        ((heatA_req && heater1_power_cur >= heater1_window) || (ioflags & HEATA_FILL)) &&
        !((ioflags & HEATA_FILL) && (gateflags2 & HEATB_GATE) &&
          heater2_power_cur >= heater2_window)) {
        if (tickflags & HEATA_FIRED)
            PORTDbits.RD1 = 1;
        else
            tickflags |= HEATA_FIRED;
    } else {
        tickflags &= ~HEATA_FIRED;
    }

    /* heater 2 (RD7), the same with the roles swapped */
    if ((gateflags2 & HEATB_GATE) &&
        ((heatB_req && heater2_power_cur >= heater2_window) || (flags26 & HEATB_FILL)) &&
        !((flags26 & HEATB_FILL) && (flags21 & HEATA_GATE) &&
          heater1_power_cur >= heater1_window)) {
        if (ioflags & HEATB_FIRED)
            PORTDbits.RD7 = 1;
        else
            ioflags |= HEATB_FIRED;
        return;
    }
    ioflags &= ~HEATB_FIRED;
    r01f &= ~0x01;
}

/* 0x05CA: every 1 ms */
static void isr_tmr2(void)
{
    PIR1bits.TMR2IF = 0;

    /* ADC conversion 10 ms after the channel switch (adc_task) */
    if (adc_start_timer) {
        adc_start_timer--;
        if (adc_start_timer == 0)
            ADCON0bits.GO = 1;
    }

    /* SPI slave resync: re-armed by isr_spi on every byte, so it only expires
     * after 15 ms without a byte from the display */
    if (spi_resync_timer) {
        spi_resync_timer--;
        if (spi_resync_timer == 0) {
            spi_resync_timer = 15;
            SSPCON1 = 0x15;         /* slave, SS disabled, CKP = 1 */
            SSPSTAT = 0;
            spi_idx = 0;
            (void)SSPBUF;
            SSPCON1bits.SSPEN = 1;
            PIR1bits.SSPIF = 0;
        }
    }

    /* brew unit encoder RC1, 3 ms debounce; a rising edge sets sysflags.4 and
     * restarts the 3 s stall timer */
    if (PORTCbits.RC1) {
        if (ioflags & IO_ENC_LEVEL) {
            r053 = 3;
        } else if (--r053 == 0) {
            ioflags |= IO_ENC_LEVEL;
            sysflags |= SYS_ENC_PULSE;
            r053 = 3;
            bu_idle = 30;
        }
    } else {
        if (!(ioflags & IO_ENC_LEVEL)) {
            r053 = 3;
        } else if (--r053 == 0) {
            ioflags &= ~IO_ENC_LEVEL;
            r053 = 3;
        }
    }

    /* flowmeter RA6, 3 ms debounce, only while the power stage is on */
    if (active_timer || wake_timer) {
        if (PORTAbits.RA6) {
            if (ioflags & IO_FLOW_LEVEL) {
                r055 = 3;
            } else if (--r055 == 0) {
                ioflags |= IO_FLOW_LEVEL;
                sysflags |= SYS_FLOW_PULSE;
                r055 = 3;
                flow_watchdog2 = flow_watchdog;
            }
        } else {
            if (!(ioflags & IO_FLOW_LEVEL)) {
                r055 = 3;
            } else if (--r055 == 0) {
                ioflags &= ~IO_FLOW_LEVEL;
                r055 = 3;
            }
        }
    }

    /* AC-sensed switches (RB0 grounds container, RB1 water tank), sampled at
     * a fixed point of the half cycle: a missing part makes the pin follow
     * the mains, so it toggles between two samples */
    if (ac_sample_timer) {
        ac_sample_timer--;
        if (ac_sample_timer == 0) {
            ac_inputs = (PORTB & 0x02) | (PORTB & 0x01);
            ac_toggle = ac_inputs ^ ac_inputs_prev;
            ac_inputs_prev = ac_inputs;
        }
    }

    if (--div_10ms == 0) {
        div_10ms = 10;
        tickflags |= TICK_RAW10MS;
    }
}

/* 0x06BC: mains zero-cross, one capture per half cycle */
static void isr_ccp1_zc(void)
{
    ccpr_now = CCPR1;
    zc_period = ccpr_now - ccpr_prev;

    /* Once the frequency is known, too short a period is a glitch: the
     * reference edge is kept so the next capture measures from it. */
    if ((zc_period >= 8000 && (flags25 & MAINS_50HZ)) ||
        (zc_period >= 6600 && !(flags25 & MAINS_50HZ)) ||
        !(flags25 & MAINS_KNOWN))
        ccpr_prev = ccpr_now;

    /* capture the other edge next time */
    if (CCP1CON == 0x05) {
        CCP1CON = 0x04;
        flags28 &= ~ZC_NEXT_RISING;
    } else {
        CCP1CON = 0x05;
        flags28 |= ZC_NEXT_RISING;
    }
    PIR1bits.CCP1IF = 0;

    if (!(flags25 & MAINS_KNOWN)) {
        /* frequency detection: 30 consecutive half periods on one side of
         * 9171 us decide, 200 edges without a decision force 50 Hz */
        zc_watchdog = 8;
        if (zc_period >= 6600 && zc_period < 12001) {
            if (zc_period >= 9171) {
                zc_cnt60 = 0;
                if (++zc_cnt50 > 29)
                    mains_set_50hz();
            } else {
                zc_cnt50 = 0;
                if (++zc_cnt60 > 29)
                    mains_set_60hz();
            }
        }
        if (++zc_valid_cnt > 199)
            mains_set_50hz();
    } else if ((zc_period >= 8000 && zc_period < 12001 && (flags25 & MAINS_50HZ)) ||
               (zc_period >= 6600 && zc_period < 10001 && !(flags25 & MAINS_50HZ))) {
        /* ---- valid half cycle */
        ac_sample_timer = ac_sample_delay;
        fire_timer = burst_fire_delay;
        zc_watchdog = 8;
        zc_lost_cnt = 5;
        if (flags28 & ZC_NEXT_RISING)       /* this was a falling edge */
            zc_ticks = 0;
        if (zc_ok_cnt && (sysflags & SYS_MAINS_LOST)) {
            zc_ok_cnt--;
            if (zc_ok_cnt == 0)             /* 5 good half cycles */
                sysflags &= ~SYS_MAINS_LOST;
        }

        if (portd_req & 0x02)
            flags21 |= HEATA_GATE;
        else
            flags21 &= ~HEATA_GATE;
        if (portd_req & 0x80)
            gateflags2 |= HEATB_GATE;
        else
            gateflags2 &= ~HEATB_GATE;

        /* heater 1 window. The powers 0x40, 0xA0, 0x100 and 0x140 (and any
         * power with heatflags.6) apply at once, others at the next window. */
        if (!(flags21 & HEATA_GATE) || (ioflags & HEATA_FILL)) {
            heater1_window = WINDOW;
            heater1_power_cur = 0;
        } else {
            if (heatA_power == 0x140 || (heatflags & HEATA_NOW) ||
                heatA_power == 0x40 || heatA_power == 0xA0 || heatA_power == 0x100)
                heater1_power_cur = heatA_power;
            if (heater1_window >= WINDOW) {
                heater1_window = 0;
                heater1_power_cur = heatA_power;
            }
            if (heater1_window == 0 && heatA_req)
                heatA_req--;                /* windows left at this power */
            heater1_window++;
        }

        /* heater 2 window: 0x140, 0x100 (or heatflags.5) apply at once */
        if (!(gateflags2 & HEATB_GATE) || (flags26 & HEATB_FILL)) {
            heater2_window = WINDOW;
            heater2_power_cur = 0;
        } else {
            if (heatB_power == 0x140 || heatB_power == 0x100 || (heatflags & HEATB_NOW))
                heater2_power_cur = heatB_power;
            if (heater2_window >= WINDOW) {
                heater2_window = 0;
                heater2_power_cur = heatB_power;
            }
            if (heater2_window == 0 && heatB_req)
                heatB_req--;
            heater2_window++;
        }
        heatflags &= ~(HEATA_NOW | HEATB_NOW);

        /* pump pulse mode: on for the first pump_on_cycles half cycles out
         * of every pump_period */
        if ((portd_req & 0x10) && (ioflags & IO_PUMP_PULSED)) {
            if (pump_pulse_cnt == 0)
                pump_pulse_cnt = pump_period;
            pump_pulse_cnt--;
            if (pump_pulse_cnt >= pump_on_cycles)
                portd_req &= ~0x10;
        } else {
            pump_pulse_cnt = 0;
        }

        /* gates up: RD0 is an input and kept, RD1/RD7 only when armed */
        portd_tmp = PORTD;
        portd_tmp &= 0x01;
        portd_tmp |= portd_req & 0x7D;
        if (tickflags & HEATA_FIRED)
            portd_tmp |= 0x02;
        if (ioflags & HEATB_FIRED)
            portd_tmp |= 0x80;
        PORTD = portd_tmp;
        gate_timer = 10;
    } else {
        /* ---- bad half period: only the too long ones (missing edges)
         * count towards mains lost */
        zc_ok_cnt = 5;
        if ((zc_period >= 12000 && (flags25 & MAINS_50HZ)) ||
            (zc_period >= 10000 && !(flags25 & MAINS_50HZ))) {
            if (zc_lost_cnt) {
                zc_lost_cnt--;
                if (zc_lost_cnt == 0)
                    sysflags |= SYS_MAINS_LOST;
            }
        }
    }

    /* 100 ms tick in mains half cycles (glitches included) */
    if (--mains_100ms_cnt == 0) {
        mains_100ms_cnt = halfcycles_100ms;
        flags25 |= MAINS_100MS;
    }
}

/* 0x6FCE */
void __interrupt() isr(void)
{
    if (INTCONbits.TMR0IF && INTCONbits.TMR0IE)
        isr_tmr0();
    else if (PIR1bits.SSPIF && PIE1bits.SSPIE)
        isr_spi();
    else if (PIR1bits.CCP1IF && PIE1bits.CCP1IE)
        isr_ccp1_zc();
    else if (PIR1bits.TMR2IF && PIE1bits.TMR2IE)
        isr_tmr2();
    else if (PIR1bits.ADIF && PIE1bits.ADIE)
        isr_adc();
    else if (PIR1bits.RCIF && PIE1bits.RCIE)
        isr_uart_rx();
    else if (PIR1bits.TXIF && PIE1bits.TXIE)
        isr_uart_tx();
}
