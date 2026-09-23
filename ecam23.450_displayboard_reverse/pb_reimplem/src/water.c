/*
 * Pump and grinder (0x7B90..0x7E56).
 *
 * Both follow the same unit pattern as the heaters and the brew unit:
 *   0 idle -> 1 running -> 4 stopping -> 2 done -> 0
 * "done" is held until the state logic stops waiting for the unit (its bit
 * in wait_snap), so step_sequencer can see it (0x7E86).
 *
 * Requests (cleared by state_control every tick):
 *   req_pump_vol  flowmeter pulses to pump, 0xFFFF = until the request stops
 *   req_grind     grinder run time in 100 ms ticks, 0 = stop
 */
#include "pb.h"
#include "units.h"

/* States in which the pump may run while the FILL TANK alarm is on, as long
 * as less than 0xB5 pulses were pumped dry (nowater_cnt_l). */
static uint8_t pump_dry_allowed_start(void)
{
    return (mstate == 0x0C && mstep < 3) ||
           (mstate == 0x0A && mstep < 5) ||
           (mstate == 4 && (mstep == 4 || mstep == 1)) ||
           (mstate == 0x0B && mstep < 3) ||
           mstate == 5;
}

static uint8_t pump_dry_allowed_run(void)
{
    return (mstate == 7 && mstep < 0x0E && mstep != 0) ||
           (mstate == 8 && mstep < 6) ||
           (mstate == 1 && mstep == 5) ||
           (mstate == 2 && mstep < 4) ||
           pump_dry_allowed_start();
}

/* 0x7B90: pump (RD4 triac, out_loads.3) */
void pump_ctrl(void)
{
    if (req_pump_vol == 0) {
        if (pump_state == 1)
            pump_state = 4;
        else if (pump_state != 4)
            pump_state = 0;
    }

    switch (pump_state) {
    case 0:                                         /* 0x7BAE: idle */
        if (req_pump_vol == 0)
            break;
        if ((sensors & SNS_TANK_OUT) && test_timer == 0)
            break;
        if (sensors & SNS_GROUNDS_OUT)
            break;
        if (req_pump_vol == PUMP_UNLIMITED &&
            (((alarms & ALM_NO_WATER) && !(flags25 & F25_BREWING)) ||
             ((alarms & ALM_BIT4) && test_timer == 0))) {
            /* 0x7BE4: unlimited pumping with an alarm: only dry-run cases */
            if (!(alarms & ALM_NO_WATER))
                break;
            if (nowater_cnt_l >= 0xB5)
                break;
            if (!pump_dry_allowed_start())
                break;
        }
        pump_state = 1;                             /* 0x7C46 */
        pump_cnt_l = 0;
        break;

    case 1:                                         /* 0x7C50: running */
        if (((sensors & SNS_TANK_OUT) && test_timer == 0) || (sensors & SNS_GROUNDS_OUT)) {
            /* tank or grounds container removed: pause while brewing
             * (state 7, step 1..0x0D), stop otherwise */
            if (!(mstate == 7 && mstep <= 0x0D && mstep != 0))
                pump_state = 4;
            break;
        }
        if ((alarms & ALM_BIT4) && test_timer == 0) {
            pump_state = 4;
            break;
        }
        if (alarms & ALM_NO_WATER) {
            if (!pump_dry_allowed_run()) {
                pump_state = 4;
                break;
            }
            /* 0x7D1C */
            if (nowater_cnt_l < 0xB5) {
                if (!(flags21 & F21_PUMP_INHIBIT))
                    out_loads |= OUT_PUMP;
            } else {
                pump_state = 4;
            }
            if (pump_cnt_l >= req_pump_vol)
                pump_state = 4;
            break;
        }
        /* 0x7D46: water present */
        if (req_pump_vol == PUMP_UNLIMITED) {
            out_loads |= OUT_PUMP;                  /* ignores flags21.6 */
            break;
        }
        if (test_timer != 0 || !(flags21 & F21_PUMP_INHIBIT))
            out_loads |= OUT_PUMP;
        if (pump_cnt_l >= req_pump_vol)
            pump_state = 4;
        break;

    case 4:                                         /* 0x7D6A: stopping */
        if (req_pump_vol != 0)
            pump_state = 2;
        else
            pump_state = 0;
        break;

    case 2:                                         /* 0x7D7A: done */
        /* sic: tests every wait bit but the pump's own */
        if ((wait_snap & ~0x04) == 0)
            pump_state = 0;
        break;
    }

    /* 0x7D9A: flow watchdog (checked by monitor_faults) */
    if (!(out_loads & OUT_PUMP)) {
        flow_watchdog = 100;
        flow_watchdog2 = flow_watchdog;
    } else if (pump_cnt_l >= 13) {
        if (mstate == 0x0E && !(settings2 & SET2_BIT0))
            flow_watchdog = 100;
        else
            flow_watchdog = 30;
    }
}

/* 0x7DD2: grinder (RD2 triac, out_loads.4) */
void grinder_ctrl(void)
{
    if (req_grind == 0) {
        if (grind_state == 1)
            grind_state = 4;
        else if (grind_state != 4)
            grind_state = 0;
    }

    switch (grind_state) {
    case 0:                                         /* 0x7DEE: idle */
        if (req_grind == 0 || (sensors & SNS_TANK_OUT) || (sensors & SNS_GROUNDS_OUT))
            break;
        grind_ticks = 0;
        grind_state = 1;
        break;

    case 1:                                         /* 0x7E02: running */
        if ((sensors & SNS_TANK_OUT) || (sensors & SNS_GROUNDS_OUT))
            break;                                  /* paused */
        out_loads |= OUT_GRINDER;
        if ((tickflags & TICK_100MS) && grind_ticks != 0xFF)
            grind_ticks++;
        if (grind_ticks >= req_grind)
            grind_state = 4;
        break;

    case 4:                                         /* 0x7E2A: stopping */
        if (req_grind != 0)
            grind_state = 2;
        else
            grind_state = 0;
        break;

    case 2:                                         /* 0x7E3A: done */
        /* sic: tests every wait bit but the grinder's own */
        if ((wait_snap & ~0x01) == 0)
            grind_state = 0;
        break;
    }
}
