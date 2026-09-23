/*
 * menu.c - user menu of the power board: the P key menu handling of
 * machine_control (0x241C-0x2666) and its helpers 0x2CB8 menu_item_open,
 * 0x2DEE menu_item_apply, 0x3002 menu_time_inc, 0x3044 menu_time_dec,
 * plus 0x2C8E bin_to_bcd (used by the SPI reply).
 *
 * flags26.5 = menu open, flags26.6 = editing the value of `menu_item`.
 * menu_value / menu_minutes are sent to the display (SPI tx[2] / tx[3]).
 *
 * Items: 0 rinse, 1 descale, 2 clock, 3 auto-off time (set_autooff 0..4),
 * 4 auto-start on/off, 5 temperature (set_temperature 0..3), 6 energy saving,
 * 7 water hardness (set_hardness 0..3), 8 language, 9 water filter,
 * 0x0A filter replace, 0x0B beep, 0x0C cup light, 0x0D factory defaults,
 * 0x0E value 0..4 (not stored), 0x0F auto-start time (entered from item 4).
 *
 * r01e.5 = clock items: editing the minutes (hours first).
 */
#include "pb.h"

#define KEY_OK     0x04
#define KEY_MENU   0x08
#define KEY_ESC    0x80

/* 0x108F: non zero = item skipped by the encoder. Only item 0 (rinse) is
 * hidden: the byte is the last one of the table before (0x1080..0x108E). */
static const uint8_t menu_hidden[15] = {
    0xff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

/* 0x241C: P / ESC / OK keys and encoder while the menu is open (part of
 * machine_control) */
void menu_keys(void)
{
    if (((key_edges & KEY_MENU) || (key_edges & KEY_ESC)) && keys_count == 1) {
        if (flags26 & 0x20) {
            /* ESC while setting the auto-start time: back to item 4 */
            if (menu_item == 0x0f && menu_level == 1 && (key_edges & KEY_ESC)) {
                menu_item = 4;
                flags26 &= ~0x40;
            }
            if (key_edges & KEY_ESC) {
                if (menu_level != 0) {
                    menu_level--;
                    flags26 &= ~0x40;
                } else {
                    flags26 &= ~0x20;               /* leave the menu */
                }
            }
        } else if (mstate == 7 && mstep == 0 && (key_edges & KEY_MENU) && !(alarms & 0x40)) {
            /* enter the menu */
            flags26 |= 0x20;
            flags28 &= ~0x40;
            flags26 &= ~0x40;
            menu_item = 1;
            menu_level = 0;
            menu_timeout = 120;
            if (flags28 & 0x01) {                   /* clock valid */
                menu_value = disp_hour;
                menu_minutes = disp_min;
            } else {
                menu_value = 0;
                menu_minutes = 0;
            }
        }
        return;
    }

    if (((r01e & 0x08) || (r01e & 0x10)) && (flags26 & 0x20)) {
        /* encoder */
        menu_timeout = 120;
        if (flags26 & 0x40) {
            reb5 = 0x14;
            if (r01e & 0x08) {
                if (menu_item == 2 || menu_item == 0x0f)
                    menu_time_inc((r01e & 0x20) ? 0 : 0xff);
                else {
                    menu_value++;
                    if (menu_value_max < menu_value)
                        menu_value = 0;
                }
            } else if (r01e & 0x10) {
                if (menu_item == 2 || menu_item == 0x0f)
                    menu_time_dec((r01e & 0x20) ? 0 : 0xff);
                else if (menu_value == 0)
                    menu_value = menu_value_max;
                else
                    menu_value--;
            }
        } else if (r01e & 0x08) {
            do {
                menu_item++;
                if (menu_item > 0x0e)
                    menu_item = 0;
            } while (menu_hidden[menu_item] != 0);
        } else if (r01e & 0x10) {
            do {
                if (menu_item == 0)
                    menu_item = 0x0e;
                else
                    menu_item--;
            } while (menu_hidden[menu_item] != 0);
        }
        return;
    }

    if ((key_edges & KEY_OK) && keys_count == 1 && (flags26 & 0x20)) {
        if (menu_item == 0 && menu_level == 1) {
            if (!(alarms & 0x01)) {                 /* rinse */
                mstate = 8;
                mstep = 0;
                flags21 |= 0x08;
                sensor_events &= ~0x01;
                flags26 &= ~0x20;
            }
        } else if (menu_item == 1 && menu_level == 1) {
            flags28 |= 0x40;                        /* start descaling */
            flags26 &= ~0x20;
        } else if (menu_item == 4 && menu_level == 1) {
            if (menu_value == 0) {                  /* auto-start off */
                settings |= 0x01;
                ee_save_req_c3 = 5;
                menu_level--;
                flags26 &= ~0x40;
            } else {                                /* on: set the time */
                menu_item = 0x0f;
                menu_value = set_autostart_h;
                menu_minutes = set_autostart_m;
                r01e &= ~0x20;
            }
        } else {
            menu_timeout = 120;
            if (flags26 & 0x40) {
                menu_item_apply();
                /* clock items: OK on the hours goes on with the minutes */
                if ((menu_item == 2 || menu_item == 0x0f) && (r01e & 0x20))
                    return;
                if (menu_level != 0) {
                    menu_level--;
                    if (menu_item == 0x0f)
                        menu_item = 4;
                    flags26 &= ~0x40;
                }
            } else {
                menu_item_open();
            }
        }
    }
}

/* 0x2CB8: open an item: load its value and range, start editing */
void menu_item_open(void)
{
    switch (menu_item) {
    case 0:
    case 1:
    case 0x0a:
    case 0x0d:
        menu_value = 0;
        menu_value_max = 0;
        break;
    case 8:
        menu_value = language & 0x0f;
        menu_value_max = disp_languages;
        break;
    case 2:
        if (flags28 & 0x01) {
            menu_value = disp_hour;
            menu_minutes = disp_min;
        } else {
            menu_value = 0;
            menu_minutes = 0;
        }
        menu_value_max = 0;
        menu_level++;
        flags26 |= 0x40;
        r01e &= ~0x20;                              /* hours first */
        return;
    case 4:
        /* note: 1 when settings.0 is set, i.e. auto-start disabled */
        menu_value = (settings & 0x01) ? 1 : 0;
        menu_value_max = 1;
        break;
    case 5:
        menu_value = set_temperature;
        menu_value_max = 3;
        break;
    case 3:
        menu_value = set_autooff;
        menu_value_max = 4;
        break;
    case 7:
        menu_value = set_hardness;
        menu_value_max = 3;
        break;
    case 0x0b:
        menu_value = (settings & 0x04) ? 1 : 0;
        menu_value_max = 1;
        break;
    case 0x0c:
        menu_value = (settings & 0x08) ? 1 : 0;
        menu_value_max = 1;
        break;
    case 9:
        menu_value = (settings & 0x80) ? 1 : 0;
        menu_value_max = 1;
        break;
    case 0x0e:
        menu_value = 0;
        menu_value_max = 4;
        break;
    case 6:
        menu_value = (settings & 0x10) ? 1 : 0;
        menu_value_max = 1;
        break;
    default:
        return;
    }
    menu_level++;
    flags26 |= 0x40;
}

/* On/off items: the stored bit flips when the value confirmed is the one
 * menu_item_open loaded (set and 1 -> clear, clear and 0 -> set). */
static void apply_bit(uint8_t mask)
{
    if ((settings & mask) && menu_value == 1)
        settings &= ~mask;
    else if (!(settings & mask) && menu_value == 0)
        settings |= mask;
    ee_save_req_c3 = 5;
}

/* 0x2F20: filter install / replace go through the circuit fill state */
static void start_circuit_fill(void)
{
    mstate = 0x0e;
    mstep = 0;
    saved_mstate = mstate;
    saved_mstep = mstep;
}

/* 0x2DEE: OK on an item being edited: store the value */
void menu_item_apply(void)
{
    switch (menu_item) {
    case 8:                                         /* language */
        lang_preview = menu_value;
        language &= 0xf0;
        language |= lang_preview | 0x10;
        ee_save_req_c0 = 5;
        break;
    case 5:
        ee_save_req_c3 = 5;
        set_temperature = menu_value;
        break;
    case 3:
        ee_save_req_c3 = 5;
        set_autooff = menu_value;
        break;
    case 2:
    case 0x0f:
        if (r01e & 0x20) {                          /* minutes done */
            if (menu_item == 0x0f) {
                ee_save_req_c3 = 5;
                set_autostart_h = menu_value;
                set_autostart_m = menu_minutes;
                settings &= ~0x01;                  /* auto-start on */
            }
            /* item 2: the new time goes to the display in the SPI reply */
            r01e &= ~0x20;
        } else {
            menu_timeout = 120;
            r01e |= 0x20;                           /* now the minutes */
        }
        break;
    case 7:
        ee_save_req_c3 = 5;
        set_hardness = menu_value;
        break;
    case 0x0d:                                      /* factory defaults */
        if (menu_value != 0)
            break;
        flags26 &= ~0x20;
        set_hardness = 3;
        set_temperature = 1;
        set_autooff = 3;
        if (settings & 0x80) {                      /* keep the filter bit */
            settings = (language & 0x40) ? 0x1d : 0x0d;
            settings |= 0x80;
        } else {
            settings = (language & 0x40) ? 0x1d : 0x0d;
        }
        set_autostart_h = 0;
        set_autostart_m = 0;
        recA_defaults(0);
        ee_save_req_c3 = 5;
        ee_save_req_c0 = 5;
        break;
    case 9:                                         /* water filter */
        if (menu_level != 1)
            break;
        if (menu_value == 0) {
            if (!(settings & 0x80))
                gateflags2 |= 0x40;                 /* install: set at the end of the fill */
            start_circuit_fill();
        } else {
            settings &= ~0x80;                      /* remove */
            ee_save_req_c3 = 5;
        }
        break;
    case 0x0a:                                      /* filter replaced */
        red9 = 5;
        water_since_filter = 0;
        if (stat_filter != 0xff)
            stat_filter++;
        start_circuit_fill();
        break;
    case 0x0b:
        apply_bit(0x04);                            /* beep */
        break;
    case 0x0c:
        apply_bit(0x08);                            /* cup light */
        break;
    case 6:
        apply_bit(0x10);                            /* energy saving */
        break;
    }
}

/* 0x3002: arg 0 = minutes 0..59, 0xFF = hours 0..23, 0x80 = hours 0..24 */
void menu_time_inc(uint8_t which)
{
    if (which == 0) {
        if (menu_minutes < 0x3b)
            menu_minutes++;
        else
            menu_minutes = 0;
    } else if (which == 0xff) {
        if (menu_value < 0x17)
            menu_value++;
        else
            menu_value = 0;
    } else if (which == 0x80) {
        if (menu_value < 0x18)
            menu_value++;
        else
            menu_value = 0;
    }
}

/* 0x3044: same arguments, decrement with wrap */
void menu_time_dec(uint8_t which)
{
    if (which == 0) {
        if (menu_minutes != 0)
            menu_minutes--;
        else
            menu_minutes = 0x3b;
    } else if (which == 0xff) {
        if (menu_value != 0)
            menu_value--;
        else
            menu_value = 0x17;
    } else if (which == 0x80) {
        if (menu_value != 0)
            menu_value--;
        else
            menu_value = 0x18;
    }
}

/* 0x2C8E: binary to packed BCD (0..99). The divide helper sdiv8 is
 * entered here with no sign, so this is an unsigned divide. */
uint8_t bin_to_bcd(uint8_t v)
{
    return (uint8_t)(((v / 10) << 4) + v % 10);
}
