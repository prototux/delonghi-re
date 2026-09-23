/*
 * 0x01F5 MAINLOOP_MAIN_LOGIC_SUB2: the settings menu.
 *
 * Called by ui_update() for machine states 0x11..0x1F and 0x26..0x29. The
 * power board drives the whole menu; this code only renders it:
 *
 *   pb_state bits 0-5  menu item (table below)
 *   pb_state bit 7     item is open (being edited / confirmed)
 *   pb_param1/2        value being edited (item specific)
 *
 * Line 1 gets the item title, line 2 / the field overlay the value.
 * Both LEDs (OK + ESC) are lit on every menu item.
 *
 *   state  item                title (EEPROM id)          open: shows
 *   0x11   clock               0x45 "Adjust time"         HH:MM (p1 = BCD hour, bit7 = editing
 *                                                         minutes, p2 = BCD minute); HOT WATER
 *                                                         alone (OK) stores it in the RTC
 *   0x12   language            0x46 "Set language"        0x38/0x39 "Press OK to / install
 *                                                         ENGLISH" in language p1 (preview)
 *   0x13   auto-start enable   0x47 "Auto-start"          p1 == 0 -> 0x55 "Disable?", else 0x54 "Enable?"
 *   0x14   descaling           0x48 "Descaling"           0x44 "Confirm?"
 *   0x15   temperature         0x49 "Set temperature"     4 char bar, p1 = 0..3
 *   0x16   auto-off            0x4D "Auto-off"            p1 = 0..4 -> 15 min, 30 min, 1 h, 2 h, 3 h
 *   0x17   water hardness      0x51 "Water hardness"      4 char bar, p1 = 0..3
 *   0x18   default values      0x57 "Default values"      0x44 "Confirm?"
 *   0x19   replace filter      0x58 "Replace filter"      0x44 "Confirm?"
 *   0x1A   statistics          0x5A "Statistics"          0x5B "Total coffee"    + p1:p2 (16 bit)
 *   0x1B   statistics          0x5A                       0x5D "Total descaling" + p1:p2
 *   0x1C   statistics          0x5A                       0x5E "Total water"     + p1:p2
 *   0x1D   statistics          0x5A                       0x5F "Total filter"    + p1:p2
 *   0x1E   statistics          0x5A                       0x5C "Total milk"      + p1:p2
 *   0x1F   install filter      0x63 "Install filter"      p1 == 0 -> 0x54 "Enable?", else 0x55 "Disable?"
 *   0x26   beep                0x59 "Beep"                idem; closed: '*' if pb_flags1.2
 *   0x27   energy saving       0x53 "Energy Saving"       idem; closed: '*' if pb_flags1.4
 *   0x28   cup lighting        0x37 "Cup lighting"        idem; closed: '*' if pb_flags1.3
 *   0x29   auto-start time     0x47 "Auto-start"          HH:MM (as clock, never stored)
 *   (0x1F closed: '*' if pb_flags1.7; 0x13 closed: glyph 0x10 at 0x4A unless pb_flags1.0)
 *
 * EEPROM texts are the English (language 0) ones.
 */
#include "hw.h"
#include "fw.h"

#define MSG_CONFIRM    0x44     /* "Confirm?" */
#define MSG_ENABLE     0x54     /* "Enable?"  */
#define MSG_DISABLE    0x55     /* "Disable?" */

static void field_blank(void)
{
    uint8_t i;
    for (i = 0; i < 10; i++)
        field[i] = ' ';
}

/* Show field[] at line 2, column 0 (0x02CB / 0x0425 tails) */
static void show_field(uint8_t pos)
{
    tick.field_active = 1;
    field_cmd = pos;
}

/*
 * Clock editing, shared by the clock (0x11) and the auto-start time (0x29):
 * pb_param1 bit 7 set means the minutes are being edited. The edited part
 * blinks only while the user is idle. Entering a part the first time sets
 * fx.b4 (b6/b7 are re-armed when the item is closed).
 */
static void edit_time(void)
{
    uint8_t mode;

    if (pb_param1 & 0x80) {                     /* editing minutes */
        if (fx.b6) {
            fx.b4 = 1;
            fx.b6 = 0;
        }
        mode = fx.idle ? 3 : 4;
    } else {                                    /* editing hours */
        if (fx.b7) {
            fx.b4 = 1;
            fx.b7 = 0;
        }
        mode = fx.idle ? 2 : 4;
    }
    format_time(mode);
}

/* Item closed on a time item: blank field, re-arm the edit flags */
static void time_closed(void)
{
    field_blank();
    tick.field_active = 1;
    field_cmd = 0x40;
    fx.b6 = 1;
    fx.b7 = 1;
}

/* 0x01F6 BGT_1: state 0x11, clock */
static void menu_clock(void)
{
    line1_msg = 0x45;                           /* "Adjust time" */
    if (!(pb_state & 0x80)) {
        time_closed();
        return;
    }

    rtc_hour  = pb_param1 & 0x7F;
    rtc_min   = pb_param2 & 0x7F;
    rtc_sec   = 0;
    edit_hour = pb_param1 & 0x7F;
    edit_min  = pb_param2 & 0x7F;

    if (pb_param1 & 0x80) {
        if (fx.b6) {
            fx.b4 = 1;
            fx.b6 = 0;
        }
        format_time(fx.idle ? 3 : 4);
        /* HOT WATER (= OK) held alone while on the minutes: store in the RTC */
        if ((keys & KEY_HOTWATER) && keys_count == 1) {
            ui.clock_valid = 1;
            i2c_buf[2] = rtc_hour;
            i2c_buf[1] = rtc_min;
            i2c_buf[0] = rtc_sec;
            i2c_buf[7] = 0;                     /* control register: OUT = 0 marks "set" */
            i2c_write_block(I2C_RTC, 0, 0);
        }
    } else {
        if (fx.b7) {
            fx.b4 = 1;
            fx.b7 = 0;
        }
        format_time(fx.idle ? 2 : 4);
    }
    show_field(0x40);
}

/* 0x026B BGT_2: state 0x12, language */
static void menu_language(void)
{
    line1_msg = 0x46;                           /* "Set language" */
    if (!(pb_state & 0x80))
        return;
    language  = pb_param1;                      /* preview in the selected language */
    line1_msg = 0x38;                           /* "Press OK to" */
    line2_msg = 0x39;                           /* "install ENGLISH" */
}

/* 0x027B BGT_3: state 0x13, auto-start on/off */
static void menu_autostart(void)
{
    line1_msg = 0x47;                           /* "Auto-start" */
    if (pb_state & 0x80) {
        line2_msg = pb_param1 ? MSG_ENABLE : MSG_DISABLE;
        return;
    }
    time_closed();                              /* (original sets b7 before b6) */
    if (pb_flags1 & 0x01)
        return;
    lcd_putc_at(0x4A, 0x10);                    /* indicator glyph, line 2 col 10 */
}

/* 0x02A3 BGT_17: state 0x29, auto-start time (no "open" check, never stored) */
static void menu_autostart_time(void)
{
    line1_msg = 0x47;                           /* "Auto-start" */
    edit_hour = pb_param1 & 0x7F;
    edit_min  = pb_param2 & 0x7F;
    edit_time();
    show_field(0x40);
}

/* 0x02CE BGT_4, 0x036B BGT_8, 0x0370 BGT_9: items that only ask "Confirm?" */
static void menu_confirm(uint8_t title)
{
    line1_msg = title;
    if (!(pb_state & 0x80))
        return;
    line2_msg = MSG_CONFIRM;
}

/*
 * 0x02D3 BGT_5 (temperature), 0x032A BGT_7 (water hardness): 4 character
 * level bar at line 2 col 8, glyph 0xFD = level reached, 0x6F = not reached.
 */
static void menu_level(uint8_t title)
{
    line1_msg = title;
    if (!(pb_state & 0x80))
        return;
    field_blank();
    tick.field_active = 1;
    field_cmd = 0x48;
    switch (pb_param1) {
    case 0: field[0] = 0xFD; field[1] = 0x6F; field[2] = 0x6F; field[3] = 0x6F; break;
    case 1: field[0] = 0xFD; field[1] = 0xFD; field[2] = 0x6F; field[3] = 0x6F; break;
    case 2: field[0] = 0xFD; field[1] = 0xFD; field[2] = 0xFD; field[3] = 0x6F; break;
    case 3: field[0] = 0xFD; field[1] = 0xFD; field[2] = 0xFD; field[3] = 0xFD; break;
    default: break;                             /* field stays blank */
    }
}

/*
 * 0x02E8 BGT_6: state 0x16, auto-off delay. Digits are written straight to
 * the LCD (line 2 col 0/1); line 2 text 0x00 "   minutes", 0x4E "  hour",
 * 0x4F "  hours" leaves those columns blank.
 */
static void menu_autooff(void)
{
    line1_msg = 0x4D;                           /* "Auto-off" */
    if (!(pb_state & 0x80))
        return;
    switch (pb_param1) {
    case 0:                                     /* 15 minutes */
        lcd_putc_at(0x40, '1');
        lcd_putc_at(0x41, '5');
        line2_msg = 0x00;                       /* "   minutes" */
        break;
    case 1:                                     /* 30 minutes */
        lcd_putc_at(0x40, '3');
        lcd_putc_at(0x41, '0');
        line2_msg = 0x00;
        break;
    case 2:                                     /* 1 hour */
        lcd_putc_at(0x40, '1');
        line2_msg = 0x4E;                       /* "  hour" */
        break;
    case 3:                                     /* 2 hours */
        lcd_putc_at(0x40, '2');
        line2_msg = 0x4F;                       /* "  hours" */
        break;
    case 4:                                     /* 3 hours */
        lcd_putc_at(0x40, '3');
        line2_msg = 0x4F;
        break;
    default:
        break;
    }
}

/*
 * 0x037A BGT_12, 0x0384 BGT_10, 0x039A BGT_11: statistics. The counter is
 * pb_param1:pb_param2 (big endian 16 bit), shown at line 2 col 15. The
 * original goes through ee_addr_hi/lo as scratch before loading `num`.
 */
static void menu_statistics(void)
{
    uint8_t label;

    line1_msg = 0x5A;                           /* "Statistics" */
    if (!(pb_state & 0x80))
        return;

    switch (pb_state & 0x3F) {
    case 0x1A: label = 0x5B; break;             /* "Total coffee" */
    case 0x1B: label = 0x5D; break;             /* "Total descaling" */
    case 0x1C: label = 0x5E; break;             /* "Total water" */
    case 0x1D: label = 0x5F; break;             /* "Total filter" */
    case 0x1E: label = 0x5C; break;             /* "Total milk" */
    default:   return;
    }

    line2_msg  = label;
    ee_addr_hi = pb_param1;
    ee_addr_lo = pb_param2;
    num = ((uint16_t)ee_addr_hi << 8) | ee_addr_lo;
    format_number();
    show_field(0x4F);
}

/*
 * 0x03C2 BGT_13, 0x03D9 BGT_14, 0x03F0 BGT_16, 0x0407 BGT_15: on/off
 * options. Closed: a '*' at line 2 col 9 when the option (a pb_flags1 bit)
 * is on. Open: 0x54 "Enable?" if p1 == 0, 0x55 "Disable?" otherwise
 * (note: the opposite of the auto-start item).
 */
static void menu_option(uint8_t title, uint8_t mask)
{
    line1_msg = title;
    if (pb_state & 0x80) {
        line2_msg = pb_param1 ? MSG_DISABLE : MSG_ENABLE;
        return;
    }
    field_blank();
    field[1] = (pb_flags1 & mask) ? '*' : ' ';
    show_field(0x48);
}

void ui_menu(void)
{
    uint8_t item = pb_state & 0x3F;

    if (item < 0x11 || item > 0x29 || (item >= 0x20 && item <= 0x25))
        return;

    led_on = 0x03;                              /* OK + ESC LEDs on every item */

    switch (item) {
    case 0x11: menu_clock();                     break;
    case 0x12: menu_language();                  break;
    case 0x13: menu_autostart();                 break;
    case 0x14: menu_confirm(0x48);               break; /* "Descaling" */
    case 0x15: menu_level(0x49);                 break; /* "Set temperature" */
    case 0x16: menu_autooff();                   break;
    case 0x17: menu_level(0x51);                 break; /* "Water hardness" */
    case 0x18: menu_confirm(0x57);               break; /* "Default values" */
    case 0x19: menu_confirm(0x58);               break; /* "Replace filter" */
    case 0x1A: case 0x1B: case 0x1C: case 0x1D: case 0x1E:
               menu_statistics();                break;
    case 0x1F: menu_option(0x63, 0x80);          break; /* "Install filter", pb_flags1.7 */
    case 0x26: menu_option(0x59, 0x04);          break; /* "Beep", pb_flags1.2 */
    case 0x27: menu_option(0x53, 0x10);          break; /* "Energy Saving", pb_flags1.4 */
    case 0x28: menu_option(0x37, 0x08);          break; /* "Cup lighting", pb_flags1.3 */
    case 0x29: menu_autostart_time();            break;
    }
}
