/*
 * Brew unit motor (0x7980..0x7B8E).
 *
 * The brew unit is moved by a universal motor through two triacs: up (RB2,
 * out_loads.1) and down (RB5, out_loads.0), plus RD6 (out_loads.6) for full
 * power once the soft start is over. Its position bu_pos counts motor
 * encoder pulses (counters_update), 0 at the lower limit switch.
 *
 * Request req_bu_target (cleared by state_control every tick):
 *   0xFFFF  up to the upper limit switch
 *   0xFFFE  down to the lower limit switch (home)
 *   other   that position, +-4 counts
 *   0       stop
 *
 * States (bu_state):
 *   0 idle, 1 moving up, 2 moving down,
 *   4 / 5 stopping after up / down (run-on while bu_runon != 0),
 *   3 done (6 is also "done" for step_sequencer but never set here).
 *
 * The timers bu_delay_up, bu_delay_down, bu_softstart, bu_runon and
 * bu_idle_delay are loaded by state_control and counted down by timebase.
 */
#include "pb.h"
#include "units.h"

/* 0x7980 */
void bu_motor(void)
{
    /* stop request, or tank / grounds container removed: cut the move */
    if (req_bu_target == 0 || (sensors & SNS_GROUNDS_OUT) || (sensors & SNS_TANK_OUT)) {
        if (bu_state == 1) {
            /* always true here: the compiler kept the whole condition */
            if ((sensors & SNS_TANK_OUT) || (sensors & SNS_GROUNDS_OUT) || req_bu_target == 0)
                ioflags |= IO_BU_ABORTED;
            bu_state = 4;
        } else if (bu_state == 2) {
            if ((sensors & SNS_TANK_OUT) || (sensors & SNS_GROUNDS_OUT) || req_bu_target == 0)
                ioflags |= IO_BU_ABORTED;
            bu_state = 5;
        } else if (bu_state != 4 && bu_state != 5) {
            bu_state = 0;
        }
    }

    switch (bu_state) {
    case 0:                                         /* 0x79D4: idle */
        ioflags &= ~IO_BU_ABORTED;
        if ((sensors & SNS_TANK_OUT) || (sensors & SNS_GROUNDS_OUT))
            break;
        if (bu_idle_delay != 0)
            break;

        if (req_bu_target == BU_TO_TOP) {
            if (sensors & SNS_BU_TOP) {
                bu_state = 3;
            } else {
                bu_state = 1;
                bu_target_l = req_bu_target;
            }
        } else if (req_bu_target == BU_TO_BOTTOM) {
            if (sensors & SNS_BU_BOTTOM) {
                bu_state = 3;
                bu_pos = 0;
            } else {
                bu_state = 2;
                bu_target_l = req_bu_target;
            }
        } else if (req_bu_target != 0) {
            if ((uint16_t)(req_bu_target + 4) < bu_pos) {
                bu_state = 2;
                bu_target_l = req_bu_target;
            } else if ((uint16_t)(bu_pos + 4) < req_bu_target) {
                bu_state = 1;
                bu_target_l = req_bu_target;
            } else {
                bu_state = 3;                       /* already there */
            }
        }

        /* 0x7A66: zone, from the limit switch the move starts on */
        if (bu_state == 1)
            bu_zone = (sensors & SNS_BU_BOTTOM) ? 2 : 0;
        else if (bu_state == 2)
            bu_zone = (sensors & SNS_BU_TOP) ? 3 : 1;
        break;

    case 1:                                         /* 0x7A8E: moving up */
        if (bu_delay_up != 0)
            break;
        out_loads |= OUT_BU_UP;
        if (bu_softstart == 0)
            out_loads |= OUT_BU_FULL;
        if (sensors & SNS_BU_TOP) {
            bu_state = 4;
            if (bu_target_l != BU_TO_TOP) {         /* limit hit before the target */
                alarms2 |= ALM2_BU_LIMIT;
                fault_class = 3;
            }
        } else if (bu_pos >= bu_target_l && bu_target_l != BU_TO_TOP) {
            bu_state = 4;
        }
        break;

    case 2:                                         /* 0x7ACC: moving down */
        if (bu_delay_down != 0)
            break;
        out_loads |= OUT_BU_DOWN;
        if (bu_softstart == 0)
            out_loads |= OUT_BU_FULL;
        if (sensors & SNS_BU_BOTTOM) {
            bu_pos = 0;
            bu_state = 5;
            if (bu_target_l != BU_TO_BOTTOM) {
                alarms2 |= ALM2_BU_LIMIT;
                fault_class = 3;
            }
        } else if (bu_target_l >= bu_pos && bu_target_l != BU_TO_BOTTOM) {
            bu_state = 5;
        }
        break;

    case 3:                                         /* 0x7B5C: done */
        /* sic: tests every wait bit but the brew unit's own */
        if ((wait_snap & ~0x02) == 0)
            bu_state = 0;
        break;

    case 4:                                         /* 0x7B1C: stopping */
    case 5:
        if (bu_runon != 0) {                        /* keep driving a little */
            if (bu_state == 4)
                out_loads |= OUT_BU_UP;
            else
                out_loads |= OUT_BU_DOWN;
            break;
        }
        if (req_bu_target == 0 || (sensors & SNS_TANK_OUT) ||
            (sensors & SNS_GROUNDS_OUT) || (ioflags & IO_BU_ABORTED) ||
            req_bu_target != bu_target_l)
            bu_state = 0;
        else
            bu_state = 3;
        break;
    }

    if (!(out_loads & OUT_BU_UP) && !(out_loads & OUT_BU_DOWN))
        bu_idle = 40;
}
