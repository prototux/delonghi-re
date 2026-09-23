/*
 * Unit sequencing, progress bar and counters (0x6832..0x6FCC, 0x7E58..0x803C).
 *
 * Every tick the state logic (state_control) sets the unit requests and the
 * "wait" bits of the units it wants to finish (wait_flags, ioflags.3). After
 * the unit drivers ran, step_sequencer advances the current step counter
 * once every requested unit reports done:
 *   test_step   in a test mode (test_timer != 0)
 *   fault_step  during a brew unit fault recovery (fault_class 1 or 2)
 *   mstep       otherwise
 * The state logic can also step explicitly with wait_flags.5 (+1),
 * wait_flags.6 (-1) and gateflags2.7 (-2).
 */
#include "pb.h"
#include "units.h"

/* 0x7E58: which units are waited for this tick (bit 0 grinder, 1 brew unit,
 * 2 pump, 3 heater A, 4 heater B). The unit drivers leave "done" only once
 * the state logic stops waiting (see the done cases in water.c,
 * brew_unit.c). */
void wait_snapshot(void)
{
    wait_snap = 0;
    if (wait_flags & WAIT_HEATA)
        wait_snap |= 0x08;
    if (ioflags & IO_WAIT_HEATB)
        wait_snap |= 0x10;
    if (wait_flags & WAIT_GRIND)
        wait_snap |= 0x01;
    if (wait_flags & WAIT_BU)
        wait_snap |= 0x02;
    if (wait_flags & WAIT_PUMP)
        wait_snap |= 0x04;
}

/* 0x7E86 */
void step_sequencer(void)
{
    uint8_t done = 0;                               /* FSR2L, same bits as wait_snap */
    uint8_t all_done;

    if ((wait_flags & WAIT_HEATA) && (heatA_state == 2 || heatA_state == 3))
        done |= 0x08;
    if ((ioflags & IO_WAIT_HEATB) && (heatB_state == 2 || heatB_state == 3))
        done |= 0x10;
    if ((wait_flags & WAIT_GRIND) && (grind_state == 2 || grind_state == 3))
        done |= 0x01;
    if ((wait_flags & WAIT_BU) && (bu_state == 3 || bu_state == 6))
        done |= 0x02;
    if ((wait_flags & WAIT_PUMP) && (pump_state == 2 || pump_state == 3))
        done |= 0x04;

    all_done = !((wait_flags & WAIT_GRIND) && !(done & 0x01)) &&
               !((wait_flags & WAIT_BU) && !(done & 0x02)) &&
               !((wait_flags & WAIT_PUMP) && !(done & 0x04)) &&
               !((wait_flags & WAIT_HEATA) && !(done & 0x08)) &&
               !((ioflags & IO_WAIT_HEATB) && !(done & 0x10));

    if (all_done && wait_snap != 0) {
        /* 0x7F28: every requested unit is done, next step */
        if (test_timer != 0)
            test_step++;
        else if (fault_class == 1 || fault_class == 2)
            fault_step++;
        else
            mstep++;
    } else if (wait_flags & STEP_FWD) {             /* 0x7F56 */
        if (test_timer != 0) {
            if (test_step != 0xFF)
                test_step++;
        } else if (fault_class == 1 || fault_class == 2) {
            if (fault_step != 0xFF)
                fault_step++;
        } else if (mstep != 0xFF) {
            mstep++;
        }
    } else if (wait_flags & STEP_BACK) {            /* 0x7F92 */
        if (test_timer != 0) {
            if (test_step != 0)
                test_step--;
        } else if (fault_class == 1 || fault_class == 2) {
            if (fault_step != 0)
                fault_step--;
        } else if (mstep != 0) {
            mstep--;
        }
    } else if (gateflags2 & STEP_BACK2) {           /* 0x7FD4 */
        if (test_timer != 0) {
            if (test_step > 1)
                test_step -= 2;
        } else if (fault_class == 1 || fault_class == 2) {
            if (fault_step > 1)
                fault_step -= 2;
        } else if (mstep > 1) {
            mstep -= 2;
        }
    }

    /* 0x8010: cappuccino sub-phases */
    if (flags1d & F1D_WAIT_BU) {
        if (bu_state == 3 || bu_state == 6)
            cappu_phase++;
    } else if (flags1d & F1D_WAIT_GRIND) {
        if (grind_state == 2 || grind_state == 3)
            cappu_phase++;
    }
}

/* The library division (0x0EBA / 0x8518) returns 0 when dividing by 0. */
static uint8_t div32(uint32_t num, uint32_t den)
{
    return den ? (uint8_t)(num / den) : 0;
}

static uint8_t div16s(int16_t num, int16_t den)
{
    return den ? (uint8_t)(num / den) : 0;
}

/* 0x6B6E: progress 0..100 shown by the display (SPI tx[9]).
 *
 * When a new value is computed, progress_hold is loaded with 50 and the
 * value is kept until timebase has counted it down; fixed values clear the
 * hold. vol = req_pump_vol, pulses = pump_cnt_l. */
void progress_update(void)
{
    switch (mstate) {
    case 0x0E:                                      /* hot water */
        if (progress_hold != 0)
            break;
        progress = div32((uint32_t)pump_cnt_l * 100, req_pump_vol);
        progress_hold = 50;
        break;

    case 1:                                         /* heating up / rinse */
        if (mstep < 4 || mstep == 9) {
            if (progress_hold != 0)
                break;
            if (temp_coffee > 0xED)                 /* colder than ~25 C */
                progress = 0;
            else                                    /* 16 bit signed maths */
                progress = div16s((int16_t)((0xED - temp_coffee) * 100),
                                  (int16_t)(0xED - req_heatA_sp));
            progress_hold = 50;
        } else if (mstep == 5) {
            if (progress_hold != 0)
                break;
            progress = div32((uint32_t)pump_cnt_l * 100, req_pump_vol);
            progress_hold = 50;
        } else {
            progress = 100;
            progress_hold = 0;
        }
        break;

    case 8:
        if (mstep < 5) {
            progress = 10;
            progress_hold = 0;
        } else if (mstep == 5) {
            if (progress_hold != 0)
                break;
            progress = 10;
            progress += div32((uint32_t)pump_cnt_l * 90, req_pump_vol);
            progress_hold = 50;
        } else {
            progress = 100;
            progress_hold = 0;
        }
        break;

    case 7:                                         /* coffee */
        if (mstep < 4) {
            progress = 0;
            progress_hold = 0;
        } else if (mstep == 4) {
            progress = (flags28 & F28_PROG_MODE) ? 0 : 10;
            progress_hold = 0;
        } else if (mstep < 0x0B) {
            if (flags28 & F28_PROG_MODE)
                progress = 0;
            else
                progress = (flags1d & F1D_CAPPU) ? 50 : 20;
            progress_hold = 0;
        } else if (mstep == 0x0B) {                 /* brewing */
            if (progress_hold != 0)
                break;
            if (flags28 & F28_PROG_MODE) {          /* programming: out of 390 pulses */
                if (pump_cnt_l >= 390)
                    progress = 100;
                else
                    progress = div32((uint32_t)pump_cnt_l * 100, 390);
            } else if (flags1d & F1D_CAPPU) {
                progress = 50;
                progress += div32((uint32_t)pump_cnt_l * 50, req_pump_vol);
            } else {
                progress = 20;
                progress += div32((uint32_t)pump_cnt_l * 80, req_pump_vol);
            }
            progress_hold = 50;
        } else {
            progress = 100;
            progress_hold = 0;
        }
        break;

    case 0x0A:                                      /* descaling */
        if (mstep < 3) {
            progress = 10;
            progress_hold = 0;
        } else if (mstep == 3) {
            if ((flags1d & F1D_PROG_QTY) && progress_hold == 0) {
                if (uptime_100ms >= 2400) {
                    progress = 100;
                    progress_hold = 0;
                } else {
                    progress = 10;
                    progress += div32((uint32_t)uptime_100ms * 90, 2400);
                    progress_hold = 50;
                }
            } else {
                /* 0x6E36 */
                if (progress_hold != 0 || r096 == 0)
                    break;
                progress = 10;
                if (flags1d & F1D_CAPPU)
                    progress += div32((uint32_t)uptime_100ms * 40, r096);
                else
                    progress += div32((uint32_t)uptime_100ms * 90, r096);
                progress_hold = 50;
            }
        } else {
            progress = (flags1d & F1D_CAPPU) ? 50 : 100;
            progress_hold = 0;
        }
        break;

    case 0x0C:                                      /* cleaning */
        if (mstep < 2) {
            progress = 10;
            progress_hold = 0;
        } else if (mstep == 2) {
            if (clean_ticks > 0x63) {
                progress = 100;
                progress_hold = 0;
            } else {
                if (progress_hold != 0)
                    break;
                progress = 10;
                progress += div32((uint32_t)clean_ticks * 90, 100);
                progress_hold = 50;
            }
        } else {
            progress = 100;
            progress_hold = 0;
        }
        break;

    case 0x0B:
        if (mstep < 2) {
            progress = 10;
            progress_hold = 0;
        } else if (mstep == 2) {
            if ((flags1d & F1D_PROG_QTY) && progress_hold == 0) {
                if (pump_cnt_l >= 1000) {
                    progress = 100;
                    progress_hold = 0;
                } else {
                    progress = 10;
                    progress += div32((uint32_t)pump_cnt_l * 90, 1000);
                    progress_hold = 50;
                }
            } else {
                if (progress_hold != 0)
                    break;
                progress = 10;
                progress += div32((uint32_t)pump_cnt_l * 90, req_pump_vol);
                progress_hold = 50;
            }
        } else {
            progress = 100;
            progress_hold = 0;
        }
        break;

    default:
        progress_hold = 0;
        break;
    }

    if (progress > 100)
        progress = 100;
}

/* 0x6832: drink, water and brew unit position counters. */
void counters_update(void)
{
    uint8_t i;

    /* end of a coffee: drink counters */
    if ((wait_flags & WAIT_END_OF_BREW) && mstate == 7 && mstep > 0x0D) {
        wait_flags &= ~WAIT_END_OF_BREW;
        red9 = 5;
        ee_save_req_c3 = 5;                         /* save the settings record */
        if (flags21 & F21_ONE_CUP) {
            if (grounds_count < 0xF5)
                grounds_count += 10;
            else
                grounds_count = 0xFF;
        } else {
            if (grounds_count < 0xF0)
                grounds_count += 15;
            else
                grounds_count = 0xFF;
        }
        if (cnt_ca < 0xFE)
            cnt_ca += (flags21 & F21_ONE_CUP) ? 1 : 2;
        if (stat_coffee < 0xFFFE)
            stat_coffee += (flags21 & F21_ONE_CUP) ? 1 : 2;
    }

    /* one milk drink */
    if (flags1d & F1D_MILK_DONE) {
        flags1d &= ~F1D_MILK_DONE;
        red9 = 5;
        if (stat_milk != 0xFFFF)
            stat_milk++;
    }

    /* flowmeter pulse */
    if (sysflags & SYS_FLOW_PULSE) {
        red9 = 30;
        sysflags &= ~SYS_FLOW_PULSE;

        if ((mstate == 7 && mstep == 0x0B) || (flags25 & F25_BREWING)) {
            if (flow_win != 0xFF)
                flow_win++;                         /* brew_power_adapt window */
        }

        if (pump_cnt_l != 0xFFFF) {
            if (req_pump_vol != PUMP_UNLIMITED ||
                (mstate == 7 && mstep < 0x0E && mstep != 0) ||
                (mstate == 0x0C && mstep < 3) ||
                (mstate == 5 && mstep == 1))
                pump_cnt_l++;
        }

        if (nowater_cnt_l != 0xFFFF) {
            if ((mstate == 7 && mstep < 0x0E && mstep != 0) ||
                (mstate == 0x0B && mstep < 3) ||
                (mstate == 8 && mstep < 6) ||
                (mstate == 2 && mstep < 4) ||
                (mstate == 0x0A && mstep < 5) ||
                (mstate == 0x0C && mstep < 3) ||
                (mstate == 1 && mstep == 5) ||
                (mstate == 4 && (mstep == 4 || mstep == 1)) ||
                mstate == 5) {
                if (alarms & ALM_NO_WATER)
                    nowater_cnt_l++;                /* pumped with FILL TANK on */
            }
        }

        /* descaling counter: +8 per pulse with a water filter, +10 without,
         * saturating at 0x00FFFFFF */
        if ((settings & SET_FILTER) && !(alarms & ALM_BIT3)) {
            if (water_since_descale < 0x00FFFFF7)
                water_since_descale += 8;
            else
                water_since_descale = 0x00FFFFFF;
        } else {
            if (water_since_descale < 0x00FFFFF5)
                water_since_descale += 10;
            else
                water_since_descale = 0x00FFFFFF;
        }

        if (water_since_filter != 0xFFFFFFFF)
            water_since_filter++;

        /* descaling (0x0A), cleaning (0x0C) and state 5 count 5 more times,
         * i.e. 6 times in total */
        if (mstate == 0x0A || mstate == 0x0C || mstate == 5) {
            for (i = 0; i <= 4; i++) {
                if ((settings & SET_FILTER) && !(alarms & ALM_BIT3)) {
                    if (water_since_descale < 0x00FFFFF7)
                        water_since_descale += 8;
                    else
                        water_since_descale = 0x00FFFFFF;
                } else {
                    if (water_since_descale < 0x00FFFFF5)
                        water_since_descale += 10;
                    else
                        water_since_descale = 0x00FFFFFF;
                }
            }
        }

        if (stat_water != 0xFFFFFFFF)
            stat_water++;
    }

    if (!(alarms & ALM_NO_WATER))
        nowater_cnt_l = 0;
    if (!(settings & SET_FILTER))
        water_since_filter = 0;

    /* brew unit encoder pulse */
    if (sysflags & SYS_BU_PULSE) {
        sysflags &= ~SYS_BU_PULSE;
        if (ioflags & IO_BU_DIR_UP) {
            if (bu_pos != 0xFFFF)
                bu_pos++;
        } else if (bu_pos != 0) {
            bu_pos--;
        }
    }
}
