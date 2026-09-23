/*
 * Fault and alarm monitor (monitor_faults, 0x803e), called from main()
 * every tick, before state_control().
 *
 * bu_pos is the brew unit travel (motor encoder pulses from the lower
 * limit) until the top switch closes. A bigger coffee dose gives a SHORTER
 * stroke: 0xC9..0xF1 is normal, >= 0xF2 means no coffee (beans empty),
 * < 0xC9 "less coffee" (too much ground coffee), < 0xB4 while moving up
 * sends the machine to state 6 (brew unit recovery).
 *
 * bu_stroke_ref (r0bc:bd) is the learned full stroke reference; the
 * menu + on/off power-up combination clears it.
 *
 * Temperatures are NTC codes: 255 - ADC, higher code = colder.
 */
#include "pb.h"

/* sensors (r013) */
#define SN_TOP        0x02  /* brew unit upper switch */
#define SN_BOTTOM     0x04  /* brew unit lower switch */
#define SN_NO_GROUNDS 0x08  /* grounds container missing */
#define SN_TANK_EMPTY 0x40  /* no water in the tank */

/* alarms (r018) */
#define AL_TANK_EMPTY 0x01
#define AL_GROUNDS    0x02  /* empty the grounds container */
#define AL_DESCALE    0x04
#define AL_FILTER     0x08
#define AL_FINE       0x10  /* ground too fine: no flow while pumping */
#define AL_BEANS      0x20  /* beans empty */
#define AL_FAULT      0x40  /* general fault */
#define AL_NTC_A      0x80  /* coffee thermoblock NTC / heating fault */

/* alarms2 (r019) */
#define AL2_NTC_B     0x10  /* steam thermoblock NTC */
#define AL2_LESS      0x20  /* "less coffee": too much ground coffee */
#define AL2_BU        0x40  /* brew unit motor fault */
#define AL2_GROUNDS   0x80

/* tickflags (r01c) */
#define TICK_100MS    0x08
#define TICK_10S      0x20

/* 0x1020: water between descalings by set_hardness, flowmeter pulses */
static const uint32_t descale_limit_tbl[4] = { 5000000UL, 2600000UL, 1400000UL, 800000UL };

/* brew unit fault: raise it once (class only grows), stop and restart the
   recovery sequence at `step` (L_80fc / L_8168) */
static void bu_fault(uint8_t cls, uint8_t step)
{
    if (fault_class < cls) {
        alarms2 |= AL2_BU;
        fault_class = cls;
        step_timer = 10;                /* 1 s */
        fault_step = step;
    }
}

/* 0x803e */
void monitor_faults(void)
{
    loop_tasks++;

    if (!(sensors & SN_NO_GROUNDS))
        grounds_out_timer = 50;         /* 5 s */

    /* heater watchdogs: reloaded here, counted down elsewhere; a zero
       below is a coffee heater fault */
    rf03 = 180;
    if (mstate != 1 || !(heatB_demand() || heatA_demand()) ||
        (pump_state == 1 && (out_loads & 0x08)))
        ref3 = 36;

    /* brew unit motor watchdog (0x8078) */
    if (bu_state == 1 || bu_state == 2) {
        if ((tickflags & TICK_100MS) && motor_run_timer != 0xFF) {
            motor_run_timer++;
            switch (bu_zone) {
            case 0:
                goto check_long;
            case 1:                     /* L_809c */
                if (motor_run_timer > 0x77) {
                    if (alarms2 & AL2_BU)
                        fault_class = 3;
                    else
                        bu_fault(2, 2);
                }
                break;
            case 2:                     /* L_80aa */
                if (motor_run_timer > 0x1D && (sensors & SN_BOTTOM)) {
                    alarms2 |= AL2_BU;
                    fault_class = 3;
                    break;
                }
check_long:                             /* L_80ba: 11.9 s without completing */
                if (motor_run_timer > 0x77) {
                    if (alarms2 & AL2_BU)
                        fault_class = 3;
                    else
                        bu_fault(1, 0);
                }
                break;
            case 3:                     /* L_80de */
                if (motor_run_timer > 0x1D && (sensors & SN_TOP)) {
                    alarms2 |= AL2_BU;
                    fault_class = 3;
                } else if (motor_run_timer > 0x77) {
                    if (alarms2 & AL2_BU)
                        fault_class = 3;
                    else
                        bu_fault(2, 2);
                }
                break;
            }
        }
    } else {
        motor_run_timer = 0;
    }

    /* stroke longer than the learned reference while going up (0x812c) */
    if (bu_pos >= (uint16_t)(bu_stroke_ref + 7) && bu_state == 1 && bu_stroke_ref != 0) {
        if (alarms2 & AL2_BU)
            fault_class = 3;
        else
            bu_fault(2, 0);
    }

    /* stroke too short: brew unit recovery (0x817e) */
    if (bu_pos < 0xB4 && (bu_state == 1 || bu_state == 4) && (sensors & SN_TOP) &&
        bu_stroke_ref != 0 && mstate != 6 && saved_mstate != 6 && saved_mstep != 3) {
        step_timer = 10;
        saved_mstate = mstate;
        saved_mstep = mstep;
        mstate = 6;
        mstep = 0;
    }

    /* grounds container (0x81da): 72 h timer once it has something in it */
    if (grounds_count == 0)
        grounds_timer = 0x6540;         /* 25920 x 10 s */
    else if ((tickflags & TICK_10S) && grounds_timer != 0)
        grounds_timer--;

    if ((grounds_count > 0x8B || grounds_timer == 0) &&
        ((mstate == 7 && mstep == 0) || mstate == 1))
        alarms |= AL_GROUNDS;
    else if (sensors & SN_NO_GROUNDS)
        alarms |= AL_GROUNDS;
    else
        alarms &= ~AL_GROUNDS;

    /* container removed for 5 s: emptied (0x8236) */
    if ((tickflags & TICK_100MS) && grounds_out_timer != 0) {
        if (--grounds_out_timer == 0) {
            grounds_count = 0;
            alarms2 &= ~AL2_GROUNDS;
            red9 = 5;                   /* save the counters */
        }
    }

    /* descaling (0x8258) */
    if (water_since_descale >= descale_limit_tbl[set_hardness])
        alarms |= AL_DESCALE;
    else
        alarms &= ~AL_DESCALE;

    if (mstate == 4 && mstep == 6) {    /* descaling finished */
        water_since_descale = 0;
        if (stat_descale != 0xFF)
            stat_descale++;
        red9 = 5;
    }

    /* water filter (0x82e2) */
    if (water_since_filter >= 100000UL)
        alarms |= AL_FILTER;
    else
        alarms &= ~AL_FILTER;

    /* no flow while the pump runs (0x8306) */
    if (pump_state == 1 && (out_loads & 0x08)) {
        if (flow_watchdog2 == 0)
            alarms |= AL_FINE;
        else
            alarms &= ~AL_FINE;
    }

    /* flow present flag r01f.1 while brewing (0x831c) */
    if ((mstate == 7 && mstep == 11) || (flags25 & 0x80)) {
        if ((tickflags & TICK_100MS) && red6 != 0) {
            if (--red6 == 0 && pump_cnt_l < 3)
                r01f &= ~0x02;
        }
        if (pump_cnt_l >= 0x2D)
            r01f |= 0x02;
    } else {
        red6 = 20;                      /* 2 s */
        r01f |= 0x02;
    }

    if (sensors & SN_TANK_EMPTY)
        alarms |= AL_TANK_EMPTY;
    else
        alarms &= ~AL_TANK_EMPTY;

    /* dose check at the top of the stroke (state 7 step 7), sticky */
    if (mstate == 7 && mstep == 7) {
        if (bu_pos >= 0xF2)
            alarms |= AL_BEANS;         /* no coffee in the chamber */
        else if (bu_pos < 0xC9)
            alarms2 |= AL2_LESS;        /* too much coffee */
    }

    /* NTC checks (0x83a6), sticky */
    if (ref3 == 0 || rf03 == 0 || temp_coffee < 0x13 || temp_coffee > 0xFC) {
        alarms |= AL_NTC_A;
        fault_class = 3;
    }
    if (temp_steam < 5 || temp_steam > 0xFC) {
        alarms2 |= AL2_NTC_B;
        fault_class = 3;
    }

    if ((alarms & AL_NTC_A) || (alarms2 & AL2_NTC_B) || (alarms2 & AL2_BU))
        alarms |= AL_FAULT;

    /* fault acknowledge (0x83f0): tank re-inserted once the recovery
       sequence has finished */
    if ((alarms & AL_FAULT) && (sensor_events & 0x04) &&
        ((fault_class == 1 && fault_step == 5) || (fault_class == 2 && fault_step == 4))) {
        alarms &= ~AL_FAULT;
        alarms2 &= ~AL2_BU;
        fault_class = 0;
        if (mstate == 0 || mstate == 2) {
            mstate = 0;
            mstep = 2;                  /* standby */
        } else {
            mstate = 1;                 /* warm-up again */
            mstep = 0;
            if (temp_coffee > 0x8E)     /* rinse unless still hot */
                flags21 |= 0x08;
            else
                flags21 &= ~0x08;
        }
    }
}
