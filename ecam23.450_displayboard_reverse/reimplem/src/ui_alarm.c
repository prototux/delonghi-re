/*
 * Alarm / warning overlay (0x0961 Elona).
 *
 * Called by the state handlers of ui_update() before they build their own
 * screen. Looks at the alarm bits the power board sends in the SPI frame
 * and, if one is active, selects the alarm message(s) and returns 1 so the
 * caller keeps them. Returns 0 when no alarm screen was selected.
 *
 * Beeps:
 *  - a change of pb_flags3 bits 0 or 5 always beeps (250 ms);
 *  - the first pass with an alarm beeps (misc.alarm_armed -> 0) and marks
 *    link.alarm_active;
 *  - the first pass without alarm after one beeps again and re-arms.
 *
 * Texts are those of language 0 of the v30 EEPROM image.
 * "p1" below means (pb_param1 & 0x1f), "state" means (pb_state & 0x3f).
 */
#include "hw.h"
#include "fw.h"

#define STATE   (pb_state & 0x3f)
#define P1      (pb_param1 & 0x1f)

/* Alarm-start beep: beep once when an alarm appears, remember it is up. */
static void alarm_start(void)
{
    if (misc.alarm_armed) {
        misc.alarm_armed = 0;
        beep = BEEP_LONG;
    }
    link.alarm_active = 1;
}

/* Same beep but without marking the alarm as active (used by two "soft"
 * warnings, EMPTY GROUNDS and ADD PRE-GROUND, that only beep in
 * state 7 / p1 0 and never produce the end-of-alarm beep themselves). */
static void alarm_beep_only(void)
{
    if (misc.alarm_armed) {
        misc.alarm_armed = 0;
        beep = BEEP_LONG;
    }
}

uint8_t ui_alarm(void)
{
    /* Any change of pb_flags3 bit 0 or bit 5 beeps. */
    if ((uint8_t)(pb_flags3 | 0xde) != last_pb3_alarm) {
        beep = BEEP_LONG;
        last_pb3_alarm = pb_flags3 | 0xde;
    }

    /* pb_flags4.6: machine fault class; details in pb_flags4.7, pb_flags5.6
     * and pb_b8_lo / pb_b8_hi. */
    if (pb_flags4 & 0x40) {
        if (pb_flags4 & 0x80)
            goto general_alarm;
        if (!(pb_flags5 & 0x40))
            return 1;                       /* keep whatever is displayed */

        if (pb_b8_lo == 2) {
            alarm_start();
            if (pb_b8_hi == 4) {
                line1_msg = 0x1f;           /* "INSERT INFUSER" */
                line2_msg = 0x20;           /* "ASSEMBLY"       */
            } else {
                line1_msg = 0x19;           /* "Please wait"    */
            }
            return 1;
        }
        if (pb_b8_lo != 1)
            goto general_alarm;

        alarm_start();
        if (pb_b8_hi == 5) {
            line1_msg = 0x1f;               /* "INSERT INFUSER" */
            line2_msg = 0x20;               /* "ASSEMBLY"       */
        } else if ((keys & KEY_HOTWATER) && (keys & KEY_CLEAN) && keys_count == 2) {
            line1_msg = 0x19;               /* "Please wait" while ESC+OK are held */
        } else {
            line1_msg = MSG_PRESS_ESC_OK;   /* ROM "PRESS ESC + OK" */
            led_on |= 0x03;                 /* light OK and ESC LEDs */
        }
        return 1;

general_alarm:
        alarm_start();
        line1_msg = 0x1e;                   /* "GENERAL ALARM!" */
        return 1;
    }

    /* Grounds container missing: pb_flags4.1 && pb_flags3.3 */
    if ((pb_flags4 & 0x02) && (pb_flags3 & 0x08)) {
        alarm_start();
        line1_msg = 0x16;                   /* "INSERT GROUNDS" */
        line2_msg = 0x17;                   /* "CONTAINER"      */
        return 1;
    }

    /* Grounds container full: grounds alarm (pb_flags4.1) with the container
     * in place (pb_flags3.3 clear), only shown when ready (state 7, p1 0).
     * Only beeps, does not set link.alarm_active. */
    if ((pb_flags4 & 0x02) && !(pb_flags3 & 0x08) && STATE == 0x07 && P1 == 0) {
        alarm_beep_only();
        line1_msg = 0x1c;                   /* "EMPTY GROUNDS" */
        line2_msg = 0x1d;                   /* "CONTAINER"     */
        return 1;
    }

    /* Water tank missing: pb_flags3.4 */
    if (pb_flags3 & 0x10) {
        alarm_start();
        line1_msg = 0x15;                   /* "INSERT TANK" (line 2 kept) */
        return 1;
    }

    /* Water tank empty: pb_flags4.0, unless fx.1 or the machine is in the
     * first steps of a cycle that tolerates it. */
    if ((pb_flags4 & 0x01) && !fx.b1) {
        if (!(STATE == 0x02 && P1 < 6) &&
            !(STATE == 0x07 && P1 >= 1 && P1 < 0x10) &&
            !(STATE == 0x0b && P1 < 6) &&
            !(STATE == 0x08 && P1 < 10) &&
            !(STATE == 0x01 && P1 == 5)) {
            alarm_start();
            line1_msg = 0x1b;               /* "FILL TANK" (line 2 kept) */
            return 1;
        }
    }

    /* Bean hopper empty: pb_flags4.5 in state 7 / p1 0. */
    if ((pb_flags4 & 0x20) && STATE == 0x07 && P1 == 0) {
        alarm_beep_only();
        if ((pb_param2 & 0x70) == 0) {
            line1_msg = 0x35;               /* "ADD PRE-GROUND" */
            line2_msg = 0x36;               /* "COFFEE"         */
        } else {
            alarm_start();                  /* armed already cleared: only marks active */
            line1_msg = 0x33;               /* "FILL BEANS" */
            line2_msg = 0x34;               /* "CONTAINER"  */
        }
        return 1;
    }

    /* Too much coffee: pb_flags5.5 in state 7 / p1 0. */
    if ((pb_flags5 & 0x20) && STATE == 0x07 && P1 == 0) {
        alarm_start();
        line1_msg = 0x21;                   /* "LESS COFFEE" (line 2 kept) */
        return 1;
    }

    /* Grind too fine / water spout: pb_flags4.4 outside states 1, 3, 4.
     * The two texts alternate: service_update() reloads tmr_cb (50 ms
     * units) to 60 when it reaches 0 while ui.b5 is set, so each pair is
     * shown for 1.5 s. */
    if ((pb_flags4 & 0x10) && STATE != 0x04 && STATE != 0x03 && STATE != 0x01) {
        alarm_start();
        led_on = 0x01;                      /* OK LED only */
        ui.b5 = 1;                          /* service_update() holds tmr_cb */
        if (tmr_cb >= 0x1e) {
            line1_msg = 0x22;               /* "GROUND TOO FINE" */
            line2_msg = 0x23;               /* "ADJUST MILL"     */
        } else {
            line1_msg = 0x41;               /* "INSERT WATER" */
            line2_msg = 0x42;               /* "SPOUT"        */
        }
        return 1;
    }

    /* No alarm. Leave the alarm state untouched (no end beep, no re-arm)
     * while pb_flags4.2 is set in state 7 / p1 0 without pb_param1.7, or
     * while pb_flags4.3 is set. */
    if ((pb_flags4 & 0x04) && STATE == 0x07 && P1 == 0 && !(pb_param1 & 0x80))
        return 0;
    if (pb_flags4 & 0x08)
        return 0;

    if (link.alarm_active) {                /* alarm just cleared: beep */
        link.alarm_active = 0;
        beep = BEEP_LONG;
    }
    misc.alarm_armed = 1;
    return 0;
}
