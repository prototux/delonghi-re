/*
 * Field formatting helpers: the 10 character "field" overlay (field[0..9])
 * used to show the clock and numbers on the LCD.
 */
#include "hw.h"
#include "fw.h"

static void field_clear_buf(void)
{
    uint8_t i;
    for (i = 0; i < 10; i++)
        field[i] = ' ';
}

/*
 * 0x1048 MAINLOOP_MAIN_LOGIC_SUB1
 *
 * Render edit_hour:edit_min (both BCD) as "HH:MM" into field[0..4], with an
 * "AM"/"PM" suffix in field[6..7] when the power board asks for 12 hour
 * display (pb_flags1 bit 1 clear).
 *
 * mode: 1 = blink the colon (1 Hz), 2 = blink the hours, 3 = blink the
 *       minutes (250 ms), anything else (the firmware uses 4) = no blinking.
 *
 * Note: in 12 hour mode edit_hour is converted in place (BCD 13..23 -> 1..11).
 */
void format_time(uint8_t mode)
{
    uint8_t suffix;

    field_clear_buf();

    if (!(pb_flags1 & 0x02)) {                  /* 12 hour display */
        if (edit_hour >= 0x12) {
            if (edit_hour == 0x21)              /* BCD "21" -> "09" */
                edit_hour = 0x09;
            else if (edit_hour == 0x20)         /* BCD "20" -> "08" */
                edit_hour = 0x08;
            else if (edit_hour >= 0x13)         /* 13..19 -> 01..07, 22..23 -> 10..11 */
                edit_hour += 0xEE;              /* i.e. -0x12 (BCD-safe for these values) */
            suffix = 'P';                       /* 12 stays 12 PM */
        } else {
            if (edit_hour == 0)
                edit_hour = 0x12;               /* 00 -> 12 AM */
            suffix = 'A';
        }
        field[6] = suffix;
        field[7] = 'M';
    }

    field[0] = (edit_hour >> 4)   | '0';
    field[1] = (edit_hour & 0x0F) | '0';
    field[2] = ':';
    field[3] = (edit_min >> 4)    | '0';
    field[4] = (edit_min & 0x0F)  | '0';

    if (mode == 2 && disp.blink_250ms_b) {
        field[0] = ' ';
        field[1] = ' ';
    }
    if (mode == 3 && disp.blink_250ms_b) {
        field[3] = ' ';
        field[4] = ' ';
    }
    if (mode == 1 && link.blink_1hz)
        field[2] = ' ';

    if (field[0] == '0')                        /* no leading zero on hours */
        field[0] = ' ';

    /* Character 0x10 of the ST7036 font: an indicator (meaning unknown,
     * maybe "auto-start armed"), shown unless pb_flags1 bit 0 is set. It
     * goes after the time in 24 h mode, after "AM/PM" in 12 h mode. */
    if (!(pb_flags1 & 0x01)) {
        if (pb_flags1 & 0x02)
            field[6] = 0x10;
        else
            field[9] = 0x10;
    }
}

/*
 * 0x116F Eliana
 *
 * Render `num` as a 5 digit decimal number in field[0..4]; leading zeros of
 * the first four digits are replaced by spaces. The original divides with
 * the 16 bit routine at 0x00C3 (Elise).
 */
void format_number(void)
{
    uint8_t i;

    field_clear_buf();

    field[0] = ((num / 10000) % 10) | '0';
    field[1] = ((num / 1000) % 10)  | '0';
    field[2] = ((num / 100) % 10)   | '0';
    field[3] = ((num / 10) % 10)    | '0';
    field[4] = (num % 10)           | '0';

    for (i = 0; i < 4 && field[i] == '0'; i++)
        field[i] = ' ';
}
