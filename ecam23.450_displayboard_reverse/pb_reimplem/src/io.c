/*
 * Inputs, outputs and the power stage (0x61A8 inputs_clear, 0x6208
 * inputs_task, 0x6302 outputs_task, 0x4998 power_task).
 *
 * Pin map (see docs/pb_notes/hw.md):
 *   RA5  switch (unknown)          RA6  flowmeter (isr_tmr2)
 *   RA7  brew unit top limit       RB0  grounds container (AC sensed)
 *   RB1  water tank (AC sensed)    RB2/RB5 brew unit motor up/down (isr_tmr0)
 *   RB3  main relay: loads and sensor supply
 *   RB4  water level               RC1  brew unit encoder (isr_tmr2)
 *   RD1  coffee heater             RD2  grinder     RD3  valve (loads2.0)
 *   RD4  pump                      RD5  valve       RD6  motor full power
 *   RD7  steam heater              RE0  water spout RE1  brew unit bottom limit
 *
 * `sensors` (sent to the display as pb_flags3), 1 = active:
 *   0 spout present (RE0 low)      1 brew unit at the top (RA7 low)
 *   2 brew unit at the bottom (RE1) 3 grounds container missing (RB0 toggles)
 *   4 water tank missing (RB1 toggles) 5 RA5 low
 *   6 water level low (RB4 low)
 */
#include "pb.h"

/* sysflags */
#define SYS_MAINS_LOST  0x20
/* tickflags */
#define TICK_10MS       0x04
#define TICK_100MS      0x08

/* 0x61A8 */
void inputs_clear(void)
{
    key_edges = 0;
    keys_hi_edges = 0;
    sensor_edges = 0;
    keys = 0;
    keys_hi = 0;
    sensors = 0;
}

/* 0x6208: keys from the display, debounced sensors, key count */
void inputs_task(void)
{
    uint8_t s = 0;

    loop_tasks++;
    key_edges = 0;
    keys_hi_edges = 0;
    sensor_edges = 0;
    sensor_events &= ~0x06;

    /* keys: the display sends them already debounced (spi frame) */
    key_edges = disp_keys & (disp_keys ^ keys);
    keys_hi_edges = disp_keys_hi & (disp_keys_hi ^ keys_hi);
    keys = disp_keys;
    keys_hi = disp_keys_hi;

    if (tickflags & TICK_10MS) {
        if (active_timer || wake_timer) {
            /* sensors are only powered with the main relay: read them */
            if (PORTAbits.RA7) s |= 0x02;
            if (PORTAbits.RA5) s |= 0x20;
            if (PORTBbits.RB4) s |= 0x40;
            if (PORTEbits.RE0) s |= 0x01;
            if (PORTEbits.RE1) s |= 0x04;
            PIE1bits.TMR2IE = 0;
            s &= 0xE7;
            if (ac_toggle & 0x02) s |= 0x10;
            if (ac_toggle & 0x01) s |= 0x08;
            PIE1bits.TMR2IE = 1;
            s ^= 0x63;                      /* active-low inputs */
        } else {
            /* off: keep the last values, only the AC-sensed ones are live */
            s = sensors & 0x67;
            PIE1bits.TMR2IE = 0;
            s &= 0xE7;
            if (ac_toggle & 0x02) s |= 0x10;
            if (ac_toggle & 0x01) s |= 0x08;
            PIE1bits.TMR2IE = 1;
        }

        /* accept a new value after 6 identical samples (50 ms) */
        if (s != sensors && s == sensor_sample) {
            if (++sensor_debounce > 4) {
                sensor_debounce = 0;
                if ((sensors & 0x20) && !(s & 0x20))
                    sensor_events |= 0x02;  /* RA5 released */
                if ((sensors & 0x10) && !(s & 0x10))
                    sensor_events |= 0x04;  /* water tank put back */
                sensor_edges = (s ^ sensors) & s;
                sensors = s;
            }
        } else {
            sensor_debounce = 0;
            sensor_sample = s;
        }
    }

    /* number of drink / function keys held */
    keys_count = 0;
    if (keys & 0x10) keys_count++;
    if (keys & 0x01) keys_count++;
    if (keys & 0x02) keys_count++;
    if (keys_hi & 0x02) keys_count++;
    if (keys & 0x80) keys_count++;
    if (keys & 0x04) keys_count++;
    if (keys & 0x08) keys_count++;
    if (keys & 0x40) keys_count++;
}

/* 0x6302: map the load requests of the units to the output pins. The triac
 * outputs of PORTD are only written by isr_ccp1_zc, in step with the mains;
 * here they go to portd_req. */
void outputs_task(void)
{
    loop_tasks++;
    INTCONbits.GIE = 0;

    portd_req = 0;
    if (out_loads & 0x40)  portd_req |= 0x40;   /* RD6 motor full power */
    if (out_loads & 0x04)  portd_req |= 0x02;   /* RD1 coffee heater    */
    if (out_loads & 0x10)  portd_req |= 0x04;   /* RD2 grinder          */
    if (out_loads & 0x08)  portd_req |= 0x10;   /* RD4 pump             */
    if (out_loads & 0x80)  portd_req |= 0x20;   /* RD5                  */
    if (out_loads2 & 0x01) portd_req |= 0x08;   /* RD3                  */
    if (out_loads & 0x20)  portd_req |= 0x80;   /* RD7 steam heater     */

    if (out_loads & 0x02)                       /* brew unit up   (RB2) */
        flags21 |= 0x01;
    else
        flags21 &= ~0x01;
    if (out_loads & 0x01)                       /* brew unit down (RB5) */
        flags21 |= 0x20;
    else
        flags21 &= ~0x20;

    /* main relay */
    if (active_timer || wake_timer)
        PORTBbits.RB3 = 1;
    else
        PORTBbits.RB3 = 0;

    /* no mains: drop every PORTD output at once */
    if (sysflags & SYS_MAINS_LOST) {
        portd_tmp = PORTD;
        portd_tmp &= 0x01;
        PORTD = portd_tmp;
    }

    INTCONbits.GIE = 1;
}

/* 0x4998: standby / power stage.
 *
 * active_timer (100 ms units) keeps the main relay on. It is reloaded to
 * 10 s whenever the machine is doing anything; once it runs out in standby
 * (state 0 step 2 = off, EEPROM idle, no fault) the outputs are reset and the
 * relay drops. From standby, the power key (alone) or the auto-start time
 * starts wake_timer: 300 ms later the power stage is on and the reason is
 * passed to the state machine as a one-pass flag in flags26 (bit 4: key,
 * bit 2: auto-start, bit 1: reason 3, unused here). r01e.1 is the test mode
 * (test_timer running). */
void power_task(void)
{
    flags26 &= ~(0x10 | 0x04 | 0x02);
    loop_tasks++;

    if (active_timer == 0 && !(r01e & 0x02)) {
        if ((key_edges & 0x10) && keys_count == 1) {
            wake_timer = 30;
            wake_reason = 1;                /* power key */
        } else if (!(settings & 0x01) &&    /* auto-start enabled */
                   mstate == 0 && mstep == 2 && wake_reason == 0 &&
                   set_autostart_h == disp_hour && set_autostart_m == disp_min &&
                   disp_sec < 11) {
            wake_timer = 30;
            wake_reason = 2;                /* auto-start time reached */
        } else if ((tickflags & TICK_10MS) && wake_timer) {
            wake_timer--;
            if (wake_timer == 0) {
                active_timer = 100;
                if (wake_reason) {
                    switch (wake_reason) {
                    case 1: flags26 |= 0x10; break;
                    case 2: flags26 |= 0x04; break;
                    case 3: flags26 |= 0x02; break;
                    }
                    wake_reason = 0;
                }
            }
        }
    }

    /* test mode: at most 1 s left */
    if ((r01e & 0x02) && active_timer > 10)
        active_timer = 10;

    if ((mstate == 0 && mstep == 2 && test_timer == 0 &&
         !(ee_flags & 0x10) && !(ee_flags & 0x01) && !(ee_flags & 0x04) &&
         !(alarms & 0x40)) || (r01e & 0x02)) {
        /* idle in standby (or test mode): count down */
        if (active_timer && (tickflags & TICK_100MS)) {
            active_timer--;
            if (active_timer == 0) {
                INTCONbits.GIE = 0;
                NOP();
                PORTA = 0;
                PORTB = 0x2C;               /* reset value (as hw_init): motor
                                               gates off; RB3 is set here and
                                               cleared by outputs_task */
                PORTC = 0x40;
                PORTE = 0;
                wake_timer = 0;
                INTCONbits.GIE = 1;
            }
        }
    } else {
        active_timer = 100;
    }

    if (test_timer == 0) {
        r01e &= ~0x02;
    } else if (r01e & 0x02) {
        mstate = 0;
        mstep = 2;
    }
}
