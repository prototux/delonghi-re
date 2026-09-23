/*
 * Thermoblock heaters (0x7106..0x797E).
 *
 * Two thermoblocks, each on a triac burst-fired by the ISRs over a window of
 * 320 mains half cycles: heater A (coffee, RD1) and heater B (steam, RD7).
 * These functions only compute the power (half cycles on per window) in
 * heatA_power / heatB_power and the "heating / at temperature" state.
 *
 * Temperatures are NTC codes (temp_coffee, temp_steam = 255 - ADC):
 * a HIGHER code means COLDER. A setpoint of 0 means off; 0xF8, 0xFA, 0xFD
 * and 0xFF are fixed-power specials (see units.h).
 *
 * The state logic (state_control) writes the requests req_heatA_sp,
 * req_heatB_sp and req_heat_mode every tick, then calls, in order:
 * heat_power_mgr, heatB_ctrl, heatA_ctrl, ... brew_power_adapt.
 */
#include "pb.h"
#include "units.h"

/* 0x1003: heater A, first threshold above the error gives the power step */
static const uint8_t heatA_thresholds[9] = {
    0x05, 0x0A, 0x19, 0x28, 0x37, 0x46, 0x55, 0x64, 0x73
};
/* 0x100D: heater B, normal */
static const uint8_t heatB_thresholds[9] = {
    0x05, 0x07, 0x0A, 0x0F, 0x15, 0x23, 0x33, 0x4F, 0x6D
};
/* 0x1017: heater B when flags1d.2 */
static const uint8_t heatB_thresholds2[9] = {
    0x05, 0x07, 0x0A, 0x0F, 0x1C, 0x2B, 0x3C, 0x4F, 0x6D
};
/* 0x103B: brew_power_adapt, flow pulses per window -> power index */
static const uint8_t flow_thresholds[9] = {
    0x03, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12
};
/* 0x1044: heater A power during brewing, indexed by brew_pwr_idx (0..9) */
static const uint16_t brew_power[10] = {
    0x020, 0x040, 0x060, 0x080, 0x0A0, 0x0C0, 0x100, 0x120, 0x140, 0x140
};

/* Power from a threshold table: the index of the first threshold greater
 * than err, times 32, plus 32 (0x20..0x120). The callers make sure err is
 * below the last threshold. */
static uint16_t threshold_power(const uint8_t *tbl, uint8_t err)
{
    uint8_t i = 0;

    while (!(err < tbl[i]))
        i++;
    return (uint16_t)i * 32 + 0x20;
}

/* 0x76DE: does heater B want power?
 * Colder than the setpoint (+3 of hysteresis unless already heating), or a
 * max/fixed setpoint; never with setpoint 0 or a heater B fault. */
uint8_t heatB_demand(void)
{
    uint8_t thr;

    if (heatB_state == 1)
        thr = req_heatB_sp;
    else
        thr = (uint8_t)(req_heatB_sp + 3);      /* 8 bit, wraps */

    if (thr < temp_steam || req_heatB_sp == SP_MAX || req_heatB_sp == SP_FIXED_100) {
        if (req_heatB_sp != 0 && !(alarms2 & ALM2_HEATB_FAULT))
            return 1;
    }
    return 0;
}

/* 0x7716: does heater A want power? Same as heater B, with the 0xF8/0xFA
 * specials, and only while reb8 == 0 and r01f.1. */
uint8_t heatA_demand(void)
{
    uint8_t thr;

    if (heatA_state == 1)
        thr = req_heatA_sp;
    else
        thr = (uint8_t)(req_heatA_sp + 3);

    if (thr < temp_coffee || req_heatA_sp == SP_FIXED_40 || req_heatA_sp == SP_FIXED_A0 ||
        req_heatA_sp == SP_FIXED_100 || req_heatA_sp == SP_MAX) {
        if (req_heatA_sp != 0 && reb8 == 0 && (r01f & F1F_HEATA_EN) && !(alarms & ALM_HEATA_FAULT))
            return 1;
    }
    return 0;
}

/* 0x7106: share the mains between the two heaters.
 *
 * flags28.3 / flags28.4 allow heater A / B to fire in this window. In the
 * alternating modes, flags28.5 says whose turn it is and heatA_req /
 * heatB_req are the number of windows granted (read by the heater ISR).
 * heatA_hold / heatB_hold are set to 10 while a heater is heating; timebase
 * counts them down.
 *
 *   mode 0  A only           mode 3  B only
 *   mode 1  alternate, A gets 3 windows, B 2
 *   mode 2  alternate, 2 windows each
 *   mode 4  both (ioflags.7)  mode 5  both (flags26.0)
 */
void heat_power_mgr(void)
{
    flags28 &= ~(F28_HEATA_SLOT | F28_HEATB_SLOT);
    if (heatA_state == 1)
        heatA_hold = 10;
    if (heatB_state == 1)
        heatB_hold = 10;

    switch (req_heat_mode) {
    case 0:                                         /* 0x7124 */
        if (heatB_hold == 0)
            flags28 |= F28_HEATA_SLOT;              /* A fires once B has been off 10 ticks */
        flags28 |= F28_TURN_A;
        if (req_heatA_sp != 0)
            heatA_req = 2;
        else
            heatA_req = 0;
        break;

    case 1:                                         /* 0x7146 */
    case 2:                                         /* 0x71D6 */
        if (flags28 & F28_TURN_A) {
            if (heatB_hold == 0)
                flags28 |= F28_HEATA_SLOT;
            if (req_heatA_sp == 0)
                heatA_req = 0;
            if (heatA_req != 0 && heatA_state != 2 && heatA_state != 3)
                break;                              /* A still has windows */
            if (heatB_demand() == 1) {              /* hand over to B */
                flags28 &= ~F28_TURN_A;
                heatB_req = 2;
            } else if (heatA_state == 1) {
                heatA_req = (req_heat_mode == 1) ? 3 : 2;
            }
        } else {
            if (heatA_hold == 0)
                flags28 |= F28_HEATB_SLOT;
            if (req_heatB_sp == 0)
                heatB_req = 0;
            if (heatB_req != 0 && heatB_state != 2 && heatB_state != 3)
                break;
            if (heatA_demand() == 1) {              /* hand over to A */
                flags28 |= F28_TURN_A;
                heatA_req = (req_heat_mode == 1) ? 3 : 2;
            } else if (heatB_state == 1) {
                heatB_req = 2;
            }
        }
        break;

    case 3:                                         /* 0x713A */
        if (heatA_hold == 0)
            flags28 |= F28_HEATB_SLOT;
        flags28 &= ~F28_TURN_A;
        if (req_heatB_sp != 0)
            heatB_req = 2;
        else
            heatB_req = 0;
        break;

    case 4:                                         /* 0x7250 */
    case 5:                                         /* 0x7260 */
        flags28 |= F28_HEATA_SLOT | F28_HEATB_SLOT;
        heatA_req = (req_heatA_sp != 0) ? 2 : 0;
        heatB_req = (req_heatB_sp != 0) ? 2 : 0;
        break;
    }

    INTCONbits.GIE = 0;
    if (req_heat_mode == 4)
        ioflags |= IO_HEAT_BOTH_A;
    else
        ioflags &= ~IO_HEAT_BOTH_A;
    if (req_heat_mode == 5)
        flags26 |= F26_HEAT_BOTH_B;
    else
        flags26 &= ~F26_HEAT_BOTH_B;
    INTCONbits.GIE = 1;
}

/* 0x72BC: heater B (steam) power and state, then the valves. */
void heatB_ctrl(void)
{
    uint8_t err;

    /* power */
    if (heatB_demand() == 0 || !(flags28 & F28_HEATB_SLOT)) {
        heatB_power = 0;
    } else {
        err = (uint8_t)(temp_steam - req_heatB_sp);
        if ((test_timer != 0 && test_mode == 4) ||
            req_heatB_sp == SP_MAX || req_heatB_sp == SP_FIXED_100) {
            /* test mode 4 and specials: full power, 0x100 for 0xFD */
            heatB_power = (req_heatB_sp == SP_FIXED_100) ? 0x100 : 0x140;
        } else if (err > 0x6C) {
            heatB_power = 0x140;
        } else if (flags1d & F1D_BIT2) {
            heatB_power = threshold_power(heatB_thresholds2, err);
        } else {
            heatB_power = threshold_power(heatB_thresholds, err);
        }
    }

    /* state: 0 idle, 1 heating, 2 at temperature, 3 fault */
    if (alarms2 & ALM2_HEATB_FAULT)
        heatB_state = 3;
    else if (req_heatB_sp == 0 || !(flags28 & F28_HEATB_SLOT))
        heatB_state = 0;

    switch (heatB_state) {
    case 0:
    case 2:
    case 3:
        if (req_heatB_sp == 0 || (alarms2 & ALM2_HEATB_FAULT))
            break;
        if (temp_steam > req_heatB_sp + 3 ||
            req_heatB_sp == SP_MAX || req_heatB_sp == SP_FIXED_100) {
            if (flags28 & F28_HEATB_SLOT)
                heatB_state = 1;
        } else {
            heatB_state = 2;
        }
        break;
    case 1:
        out_loads |= OUT_HEATB;
        if (req_heatB_sp >= temp_steam &&
            req_heatB_sp != SP_MAX && req_heatB_sp != SP_FIXED_100)
            heatB_state = 2;
        break;
    }

    if (req_heatB_sp != heatB_last_sp && heatB_last_sp == 0xFF)
        heatflags |= HF_RELOAD_B;
    heatB_last_sp = req_heatB_sp;

    /* valves: never without the grounds container, nor without the tank
     * (except in a test mode) */
    if (!(sensors & SNS_TANK_OUT) || test_timer != 0) {
        if (!(sensors & SNS_GROUNDS_OUT)) {
            if (req_valves & VALVE_EV1)
                out_loads |= OUT_EV1;
            if (req_valves & VALVE_EV2)
                out_loads2 |= OUT2_EV2;
        }
    }
}

/* 0x7464: heater A (coffee) power and state.
 *
 * While brewing (state 7 step 0x0B, or flags25.7) with heater A alone, and
 * the block within [sp-16, sp+8], the power is fed forward from the flow
 * (brew_pwr_idx, see brew_power_adapt) instead of regulated. */
void heatA_ctrl(void)
{
    uint8_t sp = req_heatA_sp;
    uint8_t err;

    if (!(alarms & ALM_HEATA_FAULT) && (flags28 & F28_HEATA_SLOT) &&
        ((mstate == 7 && mstep == 0x0B) || (flags25 & F25_BREWING)) &&
        req_heat_mode == 0 && reb8 == 0 &&
        sp != 0 && sp != SP_MAX && sp != SP_FIXED_40 && sp != SP_FIXED_A0 && sp != SP_FIXED_100 &&
        temp_coffee >= sp - 16 && temp_coffee <= sp + 8) {
        /* 0x7502: feed-forward */
        heatA_regul = 0;
        heatA_state = 1;
        if (r01f & F1F_HEATA_EN) {
            out_loads |= OUT_HEATA;
            heatA_power = brew_power[brew_pwr_idx];
        } else {
            heatA_power = 0;
        }
    } else {
        /* 0x7540: regulation */
        heatA_regul = 1;
        if (heatA_demand() == 0 || !(flags28 & F28_HEATA_SLOT)) {
            heatA_power = 0;
        } else {
            err = (uint8_t)(temp_coffee - sp);
            if ((test_timer != 0 && test_mode == 4) || sp == SP_MAX ||
                sp == SP_FIXED_40 || sp == SP_FIXED_A0 || sp == SP_FIXED_100) {
                if (sp == SP_FIXED_40)
                    heatA_power = 0x040;
                else if (sp == SP_FIXED_A0)
                    heatA_power = 0x0A0;
                else if (sp == SP_FIXED_100)
                    heatA_power = 0x100;
                else
                    heatA_power = 0x140;
            } else if (err > 0x72) {
                heatA_power = 0x140;
            } else {
                heatA_power = threshold_power(heatA_thresholds, err);
            }
        }

        /* state: 0 idle, 1 heating, 2 at temperature, 3 fault */
        if (alarms & ALM_HEATA_FAULT)
            heatA_state = 3;
        else if (sp == 0 || !(flags28 & F28_HEATA_SLOT) || !(r01f & F1F_HEATA_EN))
            heatA_state = 0;

        switch (heatA_state) {
        case 0:
        case 2:
        case 3:
            if (sp == 0 || (alarms & ALM_HEATA_FAULT))
                break;
            if (reb8 != 0 || !(r01f & F1F_HEATA_EN))
                break;
            if (temp_coffee > sp + 3 || sp == SP_FIXED_40 || sp == SP_FIXED_A0 ||
                sp == SP_FIXED_100 || sp == SP_MAX) {
                if (flags28 & F28_HEATA_SLOT)
                    heatA_state = 1;
            } else {
                heatA_state = 2;
            }
            break;
        case 1:
            out_loads |= OUT_HEATA;
            if (sp >= temp_coffee && sp != SP_FIXED_40 && sp != SP_FIXED_A0 &&
                sp != SP_FIXED_100 && sp != SP_MAX)
                heatA_state = 2;
            break;
        }
    }

    if (sp != heatA_last_sp && heatA_last_sp == 0xFF)
        heatflags |= HF_RELOAD_A;
    heatA_last_sp = sp;
}

/* 0x7768: adapt heater A's feed-forward power while brewing.
 *
 * Active in state 7, 0 < step < 0x0E. During the brew itself (step 0x0B or
 * flags25.7), every 20 x 100 ms once flow_start_delay (60, counted down by
 * timebase) has run out, the flow of the last window
 * (flow_win, counted by counters_update) gives a power index, corrected by
 * the temperature slope and the temperature itself. The average index of the
 * first three windows (flow_avg) picks the starting power of the next brew. */
void brew_power_adapt(void)
{
    uint8_t i;

    if (mstate != 7 || mstep >= 0x0E || mstep == 0) {
        /* 0x7950: not brewing, prepare the next brew */
        flow_win_timer = 20;
        flow_start_delay = 60;
        if ((flags21 & F21_BIT4) || flow_avg >= 4)
            brew_pwr_idx = 9;
        else
            brew_pwr_idx = 3;
        flow_win = 0;
        ree1 = 0;
        flow_sum = 0;
        return;
    }

    if (!((mstate == 7 && mstep == 0x0B) || (flags25 & F25_BREWING))) {
        flow_win_timer = 20;                        /* 0x7948 */
        flow_win = 0;
        return;
    }

    if (!(tickflags & TICK_100MS) || flow_win_timer == 0)
        return;
    if (--flow_win_timer != 0)
        return;
    flow_win_timer = 20;

    if (flow_start_delay == 0) {
        /* power index from the flow of this window */
        if (flow_win > 0x11) {
            brew_pwr_idx = 9;
        } else if (flow_win < 3) {
            brew_pwr_idx = 0;
        } else {
            for (i = 0; flow_thresholds[i] < flow_win; i++)
                ;
            brew_pwr_idx = i;
        }

        /* correct by the temperature slope (code change over 2 s, signed:
         * positive = getting colder) */
        if (temp_coffee_slope > 0) {
            if (temp_coffee_slope >= 4)
                brew_pwr_idx = (brew_pwr_idx < 6) ? brew_pwr_idx + 3 : 9;
            else if (temp_coffee_slope >= 2)
                brew_pwr_idx = (brew_pwr_idx < 7) ? brew_pwr_idx + 2 : 9;
            else
                brew_pwr_idx = (brew_pwr_idx < 8) ? brew_pwr_idx + 1 : 9;
        } else if (temp_coffee_slope < 0) {
            if (temp_coffee_slope <= -4)
                brew_pwr_idx = (brew_pwr_idx > 3) ? brew_pwr_idx - 3 : 0;
            else if (temp_coffee_slope <= -2)
                brew_pwr_idx = (brew_pwr_idx > 2) ? brew_pwr_idx - 2 : 0;
            else
                brew_pwr_idx = (brew_pwr_idx > 1) ? brew_pwr_idx - 1 : 0;
        }

        /* stable temperature (slope -1..1): nudge towards the band 0x74..0x7B */
        if (req_heatA_sp != 0 && req_heatA_sp != SP_FIXED_40 && req_heatA_sp != SP_FIXED_A0 &&
            req_heatA_sp != SP_FIXED_100 && req_heatA_sp != SP_MAX &&
            temp_coffee_slope >= -1 && temp_coffee_slope < 2) {
            if (temp_coffee <= 0x74)                /* hot */
                brew_pwr_idx = (brew_pwr_idx > 1) ? brew_pwr_idx - 1 : 0;
            else if (temp_coffee > 0x7B)            /* cold */
                brew_pwr_idx = (brew_pwr_idx < 8) ? brew_pwr_idx + 1 : 9;
        }

        /* average of the first three windows */
        if (ree1 < 3) {
            ree1++;
            flow_sum += brew_pwr_idx;
        } else {
            flow_avg = flow_sum / 3;
        }
    }
    flow_win = 0;
}
