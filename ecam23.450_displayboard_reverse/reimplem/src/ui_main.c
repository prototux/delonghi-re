/*
 * Main user interface state machine (original: MAINLOOP_MAIN_LOGIC, 0x0AC6).
 *
 * The display board has no idea what the machine is doing on its own: every
 * SPI frame from the power board carries a machine state (pb_state & 0x3F),
 * two parameters (pb_param1, pb_param2) and flag bytes. ui_update() maps that
 * to two message IDs (line1_msg / line2_msg), the LEDs, the 10 char "field"
 * overlay (clock, numbers, progress bar) and the backlight, then lets
 * display_refresh() push the result to the LCD.
 *
 * Machine states (inferred from the messages each one shows; EEPROM text is
 * the English language set, language 0):
 *
 *   0x00  standby / off        clock, "INSERT TANK", "Self-diagnosis"...
 *   0x01  warming up           "Heating up / Please wait" or "Rinsing"
 *   0x02  turning off          "Turning off / Please wait"
 *   0x04  descaling            "Add descaler / Confirm?", "Descaling underway", ...
 *   0x07  ready / brewing      selected drink + taste, "1 ESPRESSO COFFEE" + progress bar
 *   0x08  rinsing              "Rinsing" (+ progress bar)
 *   0x0A  milk drinks          "Cappuccino" / "Frothed milk", "INSERT MILK CONTAINER"
 *   0x0B  hot water            "Hot water", "INSERT WATER SPOUT"
 *   0x0C  cleaning             "Cleaning" (+ progress bar)
 *   0x0D  first start          "Press OK to / install ENGLISH", "ENGLISH installed"
 *   0x0E  hot water prompt     "Hot water / Confirm?", "INSERT WATER SPOUT"
 *   0x0F  heating              "Heating up" / "Please wait"
 *   0x11..0x1F, 0x26..0x29     settings menu, handled by ui_menu()
 *   0x21  display/button test  "DISPLAY TEST MODE", "BUTTON <n>"
 *   0x22  load test            "LOAD TEST MODE", "HEATER ON", "PUMP ON", ...
 *   0x23  electric test steps  LEDs, backlight, cup light, LCD patterns
 *   0x24  electric test        "ELECTRIC TEST MODE"
 *   0x25  energy saving        "ENERGY SAVING" + '*' marker
 *   other (0x03, 0x05, 0x06, 0x09, 0x10, 0x20, >= 0x2A): blank screen
 *
 * Most handlers first call ui_alarm(): if an alarm screen is up it owns the
 * display and the handler does nothing else.
 */
#include "hw.h"
#include "fw.h"

/* pb_state bits 0-5: machine state; pb_param1 bits 0-4: sub-state */
#define PB_STATE     (pb_state & 0x3F)
#define PB_SUB       (pb_param1 & 0x1F)

/* Field overlay characters */
#define CH_BAR_EMPTY 0x5F   /* '_' */
#define CH_BAR_FULL  0xFF   /* full block in the ST7036 font */

static void field_fill(uint8_t c)
{
    for (uint8_t i = 0; i < 10; i++)
        field[i] = c;
}

/* Original code sets its loop index to 0x0C on the first mismatch */
static uint8_t field_differs(void)
{
    for (uint8_t i = 0; i < 10; i++)
        if (field[i] != field_shadow[i])
            return 1;
    return 0;
}

/* Shared tails of the original handlers */
static void show(uint8_t l1, uint8_t l2)
{
    line1_msg = l1;
    line2_msg = l2;
}

/* L_0C8C / L_0C8E: a question on line 2, OK LED on */
static void ask(uint8_t l1, uint8_t l2)
{
    show(l1, l2);
    led_on = 0x01;
}

/* L_0CF8: drink being prepared, "Preparation underway" scrolling on line 2 */
static void preparing(uint8_t l1)
{
    show(l1, 0x4A);                 /* "Preparation underway" */
    ui.scroll = 1;
    scroll_len = 0x28;              /* two EEPROM records: 0x4A + 0x4B ("...") */
}

/* Taste (param2 bits 4-6): 1..5 -> "Extra-mild".."Extra-strong taste",
 * 6 -> "Pre-ground", 7 -> "Program quantity" */
static uint8_t taste_msg(void)
{
    return (uint8_t)(((pb_param2 & 0x70) >> 4) + 0x0B);
}

/* ------------------------------------------------------------------------- */
/* 0x0B31 BGT2_1: state 0x00, standby                                        */
/* ------------------------------------------------------------------------- */
static void ui_state_standby(void)
{
    fx.b1 = 0;
    disp.standby = 1;
    if (dim_timer == 0)
        disp.backlight_pwm = 0;             /* backlight off after the timeout */

    if (pb_flags3 & 0x08) {
        dim_timer = 10;
        disp.backlight_pwm = 1;
        show(0x16, 0x17);                   /* "INSERT GROUNDS / CONTAINER" */
        return;
    }
    if (pb_flags3 & 0x10) {
        dim_timer = 10;
        disp.backlight_pwm = 1;
        line1_msg = 0x15;                   /* "INSERT TANK" */
        return;
    }
    if (ui.clock_valid && keys_count) {     /* key press wakes the backlight */
        dim_timer = 10;
        disp.backlight_pwm = 1;
        return;
    }
    if (PB_SUB < 2) {
        if (ui_alarm())
            return;
        line1_msg = 0x13;                   /* "Self-diagnosis" */
        led_on = 0xFF;
        return;
    }
    if (!ui.clock_valid)
        return;

    /* Show the time */
    edit_hour = rtc_hour;
    edit_min = rtc_min;
    format_time(1);                         /* blinking colon */
    tick.field_active = 1;
    field_cmd = (pb_flags1 & 0x02) ? 0x07 : 0x06;   /* 24 h: no AM/PM, shift right */
}

/* ------------------------------------------------------------------------- */
/* 0x0B83 BGT2_2: states 0x01 (warming up) and 0x08 (rinsing)                */
/* ------------------------------------------------------------------------- */
static void ui_state_warmup(void)
{
    if (ui_alarm())
        return;

    if (PB_STATE == 0x08) {
        fx.b1 = 1;
        line1_msg = 0x1A;                   /* "Rinsing" */
        if (PB_SUB >= 5)
            misc.progress = 1;
        else
            line2_msg = 0x19;               /* "Please wait" */
        return;
    }

    fx.b1 = (PB_SUB < 8);
    ui.b2 = 0;
    if (PB_SUB == 5 && (pb_param2 & 0x80))
        ui.b2 = 1;

    if (!ui.b2) {
        show(0x18, 0x19);                   /* "Heating up / Please wait" */
    } else {
        misc.progress = 1;
        line1_msg = 0x1A;                   /* "Rinsing" */
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0BAC BGT2_3: state 0x02, turning off                                    */
/* ------------------------------------------------------------------------- */
static void ui_state_turning_off(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 1;
    show(0x2C, 0x19);                       /* "Turning off / Please wait" */
}

/* ------------------------------------------------------------------------- */
/* 0x0C5B BGT2_5: state 0x04, descaling                                      */
/* ------------------------------------------------------------------------- */
static void ui_state_descaling(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 1;

    if (!(pb_flags3 & 0x01)) {
        show(0x2D, 0x2E);                   /* "INSERT WATER / SPOUT" */
        return;
    }

    switch (PB_SUB) {
    case 0:
        line1_msg = 0x19;                   /* "Please wait" */
        break;
    case 1:                                 /* 0x0C65 */
        if (pb_param2 & 0x08) {
            show(0x26, 0x27);               /* "Descaling / underway" */
        } else if (!(pb_flags5 & 0x80)) {
            ask(0x25, 0x44);                /* "Add descaler / Confirm?" */
        } else {
            ui.b5 = 1;                      /* holds tmr_cb (see service_update) */
            if (tmr_cb >= 0x1E)
                ask(0x25, 0x44);            /* "Add descaler / Confirm?" */
            else
                ask(0x01, 0x50);            /* "EMPTY THE / DRIP TRAY" */
        }
        break;
    case 2:
        show(0x26, 0x27);                   /* "Descaling / underway" */
        break;
    case 3:
        if (pb_param2 & 0x08) {
            show(0x26, 0x27);               /* "Descaling / underway" */
        } else {
            /* the original writes line 2 twice (0x44 then 0x1B) */
            line1_msg = 0x1A;               /* "Rinsing" */
            line2_msg = 0x44;
            line2_msg = 0x1B;               /* "FILL TANK" */
        }
        break;
    case 4:
        if (pb_param2 & 0x08)
            line1_msg = 0x1A;               /* "Rinsing" */
        else
            ask(0x1A, 0x44);                /* "Rinsing / Confirm?" */
        break;
    case 5:
        ask(0x29, 0x44);                    /* "Rinsing complete / Confirm?" */
        break;
    default:
        break;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0BB3 BGT2_6: state 0x07, ready / brewing coffee                         */
/* ------------------------------------------------------------------------- */
static void ui_state_coffee(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 0;

    if (PB_SUB == 0) {
        /* Ready: selected drink (param2 bits 1-3) and taste (bits 4-6) */
        switch (pb_param2 & 0x0E) {
        case 0x00: line1_msg = 0x2A; break; /* "MY COFFEE" */
        case 0x02: line1_msg = 0x56; break; /* "ESPRESSO COFFEE" */
        case 0x04: line1_msg = 0x60; break; /* "STANDARD COFFEE" */
        case 0x06: line1_msg = 0x61; break; /* "LONG COFFEE" */
        case 0x08: line1_msg = 0x62; break; /* "EXTRA LONG COFFEE" */
        default:   break;
        }
        if (pb_param2 & 0x40)
            line2_msg = 0x14;               /* "Hot water" */

        /* link.b0 is never set, so the second condition is dead code */
        if ((pb_param2 & 0x70) || link.b0)
            line2_msg = taste_msg();
        else
            line2_msg = 0x11;               /* "Pre-ground" */

        /* Maintenance reminders, alternating with the 1 Hz blink */
        if (link.blink_1hz && (pb_flags4 & 0x04) && !(pb_flags1 & 0x20))
            line1_msg = 0x30;               /* "DESCALE" */
        if (!link.blink_1hz && (pb_flags4 & 0x08) && !(pb_flags1 & 0x20))
            line2_msg = 0x43;               /* "REPLACE FILTER" */
        if (pb_flags1 & 0x40)
            line2_msg = 0x53;               /* "Energy Saving" */
        if ((pb_flags1 & 0x20) && misc.blink_800ms)
            line2_msg = 0x3C;               /* "Press CLEAN button" */
        return;
    }

    /* 0x0C0B: brewing */
    if (PB_SUB >= 0x0E || (pb_param2 & 0x01)) {
        misc.progress = 1;
        line1_msg = 0x19;                   /* "Please wait" */
        return;
    }

    if (pb_param1 & 0x40) {                 /* cappuccino */
        if (pb_param2 & 0x80) {
            show(0x40, 0x12);               /* "Coffee for Cappucc. / Program quantity" */
            misc.progress = 0;
        } else {
            line1_msg = 0x3B;               /* "Cappuccino" */
            misc.progress = 1;
        }
        return;
    }

    if (PB_SUB >= 4 && !(pb_param2 & 0x01))
        misc.progress = 1;

    /* "1 ESPRESSO COFFEE" .. "2 EXTRA LONG COFFEES": param2 bits 1-3 select
     * the drink, param1 bit 5 means two cups */
    line1_msg = (uint8_t)((pb_param2 & 0x0E) + 0x02);
    if (pb_param1 & 0x20)
        line1_msg++;

    if (pb_param2 & 0x80) {                 /* programming the quantity */
        line2_msg = 0x12;                   /* "Program quantity" */
        misc.progress = 0;
        return;
    }
    if (PB_SUB < 4)
        line2_msg = (pb_param2 & 0x70) ? taste_msg() : 0x11;   /* taste / "Pre-ground" */
}

/* ------------------------------------------------------------------------- */
/* 0x0CB1 BGT2_7: state 0x0A, milk drinks                                    */
/* ------------------------------------------------------------------------- */
static void ui_state_milk(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 1;

    if (PB_SUB == 0) {
        if (!(pb_flags2 & 0x20))
            show(0x18, 0x19);               /* "Heating up / Please wait" */
        else
            show(0x3D, 0x3E);               /* "INSERT MILK / CONTAINER" */
        return;
    }
    if (PB_SUB == 1) {
        preparing((pb_param1 & 0x40) ? 0x3B : 0x2B);  /* "Cappuccino" / "Frothed milk" */
        return;
    }
    if (pb_param2 & 0x80) {
        show(0x3F, 0x12);                   /* "Milk for Cappuccino / Program quantity" */
        misc.progress = 0;
        return;
    }
    line1_msg = (pb_param1 & 0x40) ? 0x3B : 0x2B;
    misc.progress = 1;                      /* set again at 0x0D49 when PB_SUB >= 2 */
}

/* ------------------------------------------------------------------------- */
/* 0x0CDF BGT2_8: state 0x0B, hot water                                      */
/* ------------------------------------------------------------------------- */
static void ui_state_hot_water(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 0;

    if (PB_SUB == 0) {
        if (!(pb_flags3 & 0x01)) {
            show(0x2D, 0x2E);               /* "INSERT WATER / SPOUT" */
        } else {
            line2_msg = 0x19;               /* "Please wait" */
            line1_msg = 0x18;               /* "Heating up" */
        }
        return;
    }
    if (PB_SUB == 1) {
        preparing(0x14);                    /* "Hot water" */
        return;
    }
    misc.progress = 1;
    line1_msg = 0x14;                       /* "Hot water" */
    if (pb_param2 & 0x80) {
        line2_msg = 0x12;                   /* "Program quantity" */
        misc.progress = 0;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0D09 BGT2_9: state 0x0C, cleaning                                       */
/* ------------------------------------------------------------------------- */
static void ui_state_cleaning(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 1;

    if (PB_SUB == 1) {
        show(0x18, 0x19);                   /* "Heating up / Please wait" */
    } else {
        line1_msg = 0x2F;                   /* "Cleaning" */
        misc.progress = 1;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0AE0 BGT2_10: state 0x0D, first start: language installation           */
/* ------------------------------------------------------------------------- */
static void ui_state_install_language(void)
{
    /* Unlike the other states, an alarm only wins if pb_flags4 bit 6 is set;
     * otherwise the alarm messages are overwritten below. */
    if (ui_alarm() && (pb_flags4 & 0x40))
        return;
    fx.b1 = 0;

    if (PB_SUB == 0 || PB_SUB == 1)
        ask(0x38, 0x39);                    /* "Press OK to / install ENGLISH" */
    else if (PB_SUB == 2)
        line1_msg = 0x3A;                   /* "ENGLISH installed" */
    /* the language shown comes from pb_param2 (see link_update) */
}

/* ------------------------------------------------------------------------- */
/* 0x0AFB BGT2_11: state 0x0E, hot water prompt                              */
/* ------------------------------------------------------------------------- */
static void ui_state_hot_water_prompt(void)
{
    if (ui_alarm())
        return;
    fx.b1 = 0;

    switch (PB_SUB) {
    case 0:
    case 2:
        line1_msg = 0x19;                   /* "Please wait" */
        break;
    case 1:
        if (pb_flags3 & 0x01)
            ask(0x14, 0x44);                /* "Hot water / Confirm?" */
        else
            ask(0x2D, 0x2E);                /* "INSERT WATER / SPOUT" */
        break;
    default:
        break;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0B1B BGT2_12: state 0x0F, heating (no alarm check)                      */
/* ------------------------------------------------------------------------- */
static void ui_state_heating(void)
{
    fx.b1 = 0;

    switch (PB_SUB) {
    case 0:
    case 2:
        line1_msg = 0x19;                   /* "Please wait" */
        break;
    case 1:
        line1_msg = 0x18;                   /* "Heating up" */
        break;
    default:
        break;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0D20 BGT2_14: state 0x21, display and button test                       */
/* ------------------------------------------------------------------------- */
static void ui_state_display_test(void)
{
    if (pb_param2 != 0) {
        led_on = 0xFF;
        line2_msg = MSG_ALL_BLOCKS;         /* line 1 stays blank */
        return;
    }

    if (keys_count == 0) {
        /* The encoder moves the progress bar in steps of 10 (0..100).
         * link_update() does not overwrite pb_b9 while in this state. */
        line1_msg = MSG_DISPLAY_TEST;
        tick.field_active = 1;
        if (tick.enc_ccw) {
            tick.enc_ccw = 0;
            pb_b9 -= 10;
            if (pb_b9 < 10)                 /* tested after the subtraction */
                pb_b9 = 0;
        } else if (tick.enc_cw) {
            tick.enc_cw = 0;
            pb_b9 += 10;
            if (pb_b9 >= 0x65)
                pb_b9 = 0x64;
        } else {
            return;
        }
        misc.progress = 1;
        return;
    }

    /* A key is held: "BUTTON" + its number at column 7 of line 2 */
    field_fill(' ');
    line2_msg = MSG_BUTTON;
    tick.field_active = 1;
    field_cmd = 0x47;
    if      (keys & KEY_ONOFF)    field[1] = '1';
    else if (keys & KEY_MENU)     field[1] = '2';
    else if (keys & KEY_CLEAN)    field[1] = '3';
    else if (keys & KEY_1CUP)     field[1] = '4';
    else if (keys & KEY_2CUPS)    field[1] = '5';
    else if (keys & KEY_HOTWATER) field[1] = '6';
    else if (keys & KEY_ENC_PUSH) field[1] = '7';
    else if (keys & KEY_CAPPU)    field[1] = '8';
}

/* Load test helper: a key held alone */
static uint8_t only_key(uint8_t k)
{
    return (keys & k) && keys_count == 1;
}

/* ------------------------------------------------------------------------- */
/* 0x0D81 BGT2_15: state 0x22, load test                                     */
/* ------------------------------------------------------------------------- */
static void ui_state_load_test(void)
{
    /* Beep when limit switch bits (pb_flags3 bits 0, 5) change */
    if ((uint8_t)(pb_flags3 | 0xDE) != last_pb_flags3) {
        beep = BEEP_LONG;
        last_pb_flags3 = pb_flags3 | 0xDE;
    }

    if (pb_param2 != 0) {
        show(MSG_ALL_BLOCKS, MSG_ALL_BLOCKS);
        return;
    }

    if (pb_param1 < 3) {                    /* full byte, not masked */
        line1_msg = MSG_LOAD_TEST;
    } else if (pb_param1 == 3) {
        /* keys switch one load each, only when held alone */
        if      (only_key(KEY_MENU))     line1_msg = MSG_HEATER_ON;
        else if (only_key(KEY_CLEAN))    line1_msg = MSG_GRINDER_ON;
        else if (only_key(KEY_HOTWATER)) line1_msg = MSG_PUMP_ON;
        else if (only_key(KEY_1CUP))     line1_msg = MSG_EV1_ON;
        else if (only_key(KEY_ENC_PUSH)) line1_msg = MSG_EV2_ON;
        else if (only_key(KEY_CAPPU))    line1_msg = MSG_VAPORIZER_ON;
        else if (only_key(KEY_ONOFF))    show(MSG_EV1_ON, MSG_EV2_ON);
        else                             line1_msg = MSG_LOAD_TEST;
    } else if (pb_param1 == 4 || pb_param1 == 5) {
        /* brewing unit motor, with its limit switches */
        if (pb_flags3 & 0x02)
            line1_msg = MSG_LIMIT_UP;
        else if (pb_flags3 & 0x04)
            line1_msg = MSG_LIMIT_DOWN;
        else if (only_key(KEY_2CUPS))
            line1_msg = (pb_param1 == 4) ? MSG_MOTOR_DOWN : MSG_MOTOR_UP;
        else
            line1_msg = MSG_LOAD_TEST;
    } else if (pb_param1 == 6) {
        line1_msg = MSG_VAPORIZER_ON;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0E02 BGT2_16: state 0x23, electric test steps (param2 = step)           */
/* ------------------------------------------------------------------------- */
static void ui_state_electric_step(void)
{
    disp.backlight_pwm = 0;

    switch (pb_param2) {
    case 0x00: led_on = 0x00; break;
    case 0x01: led_on = 0x01; break;        /* OK LED */
    case 0x02: led_on = 0x02; break;        /* ESC LED */
    case 0x03:
        led_on = 0x00;
        disp.backlight_pwm = 1;             /* backlight */
        break;
    case 0x04:
        CUPLIGHT_N = 0;                     /* cup light on until the next SPI frame */
        disp.backlight_pwm = 0;
        break;
    case 0x05:
        disp.backlight_pwm = 1;
        show(MSG_ALL_GLYPH0, MSG_ALL_GLYPH0);
        break;
    case 0x06:
        disp.backlight_pwm = 1;
        show(MSG_ALL_0x17, MSG_ALL_0x17);
        break;
    case 0xFF:
        led_on = 0xFF;
        disp.backlight_pwm = 1;
        break;
    default:
        break;
    }
    if (pb_param2 & 0x02)                   /* also true for steps 2, 3, 6, 0xFF */
        show(MSG_ALL_BLOCKS, MSG_ALL_BLOCKS);
}

/* ------------------------------------------------------------------------- */
/* 0x0E4C BGT2_18: state 0x25, energy saving                                 */
/* ------------------------------------------------------------------------- */
static void ui_state_energy_saving(void)
{
    line1_msg = MSG_ENERGY_SAVING;
    led_on |= 0x03;
    field_fill(' ');

    switch (pb_param1) {
    case 0:
        if (!(pb_flags1 & 0x10))
            return;
        /* fall through */
    case 1:
        field[1] = '*';
        tick.field_active = 1;
        field_cmd = 0x48;
        break;
    case 2:
        field[1] = ' ';
        tick.field_active = 1;
        field_cmd = 0x48;
        break;
    case 3:
        led_on = 0x00;
        show(MSG_BLANK, MSG_BLANK);
        break;
    default:
        break;
    }
}

/* ------------------------------------------------------------------------- */
/* 0x0EC6: push everything to the LCD                                        */
/* ------------------------------------------------------------------------- */
static void ui_output(void)
{
    display_refresh();

    /* Field overlay (10 chars at field_cmd), only between line refreshes */
    if (misc.progress && !fx.lcd_busy) {
        /* Progress bar on line 2 from column 5: one block per 10% */
        fx.field_clear = 0;
        field_fill(CH_BAR_EMPTY);
        for (uint8_t i = 0; i < 10; i++)
            if (pb_b9 > (uint8_t)(i * 10))
                field[i] = CH_BAR_FULL;
        field_cmd = 0x45;
        if (field_differs())
            lcd_write_field(field_cmd);
    } else if (tick.field_active && !fx.lcd_busy) {
        fx.field_clear = 0;
        if (field_differs())
            lcd_write_field(field_cmd);
    } else {
        field_fill(' ');
        for (uint8_t i = 0; i < 10; i++)
            field_shadow[i] = ' ';
        if (!fx.field_clear) {              /* blank it on the LCD only once */
            fx.field_clear = 1;
            lcd_write_field(field_cmd);
        }
    }

    /* Language changed: redraw everything once the screen is stable */
    if (last_language != language &&
        line1_shown == line1_msg && line2_shown == line2_msg) {
        last_language = language;
        tmr_c7 = 0x32;
        tmr_c8 = 0x32;
        field_fill(' ');
        line1_shown = MSG_NONE;
        line2_shown = MSG_NONE;
    }

    /* Every 15 s of stable screen, re-initialise the LCD (without reset) in
     * case it glitched, and redraw */
    if (line1_shown == line1_msg && line2_shown == line2_msg &&
        !tick.field_active && !misc.progress && tmr_cd == 0) {
        tmr_cd = 0x1E;
        tmr_c7 = 0x32;
        tmr_c8 = 0x32;
        lcd_init(0xFF);
        field_fill(' ');
        line1_shown = MSG_NONE;
        line2_shown = MSG_NONE;
    }

    /* Redraw each line every 2.5 s while nothing changes */
    if (line1_shown == line1_msg && !tick.field_active && !misc.progress) {
        if (tmr_c7 == 0) {
            tmr_c7 = 0x32;
            line1_shown = MSG_NONE;
        }
    } else {
        tmr_c7 = 0x32;
    }
    if (line2_shown == line2_msg && !tick.field_active && !misc.progress) {
        if (tmr_c8 == 0) {
            tmr_c8 = 0x32;
            line2_shown = MSG_NONE;
        }
    } else {
        tmr_c8 = 0x32;
    }

    /* Backlight: left alone in standby (param1 >= 2) once tmr_c9 expired and
     * during the electric test, otherwise handed to the timer1 PWM */
    if (PB_STATE == 0x00 && PB_SUB >= 2 && tmr_c9 == 0)
        return;
    if (PB_STATE == 0x23)
        return;
    disp.backlight_pwm = 1;
}

/* ------------------------------------------------------------------------- */
/* 0x0AC6 MAINLOOP_MAIN_LOGIC                                                */
/* ------------------------------------------------------------------------- */
void ui_update(void)
{
    line1_msg = MSG_BLANK;
    line2_msg = MSG_BLANK;
    ui.scroll = 0;
    ui.b5 = 0;
    disp.standby = 0;
    field_cmd = 0x45;

    if (uart_timeout) {                     /* service mode */
        line1_msg = MSG_UART_MODE;
        ui_output();
        return;
    }
    if (ui.link_lost) {                     /* no power board: blank screen */
        ui_output();
        return;
    }

    tick.field_active = 0;
    misc.progress = 0;
    led_on = 0;
    led_blink = 0;

    switch (PB_STATE) {                     /* jump table at 0x0E98 */
    case 0x00: ui_state_standby();             break;
    case 0x01:
    case 0x08: ui_state_warmup();              break;
    case 0x02: ui_state_turning_off();         break;
    case 0x04: ui_state_descaling();           break;
    case 0x07: ui_state_coffee();              break;
    case 0x0A: ui_state_milk();                break;
    case 0x0B: ui_state_hot_water();           break;
    case 0x0C: ui_state_cleaning();            break;
    case 0x0D: ui_state_install_language();    break;
    case 0x0E: ui_state_hot_water_prompt();    break;
    case 0x0F: ui_state_heating();             break;
    case 0x21: ui_state_display_test();        break;
    case 0x22: ui_state_load_test();           break;
    case 0x23: ui_state_electric_step();       break;
    case 0x24: line1_msg = MSG_ELECTRIC_TEST;  break;  /* 0x0DFF BGT2_17 */
    case 0x25: ui_state_energy_saving();       break;
    default:
        if ((PB_STATE >= 0x11 && PB_STATE <= 0x1F) ||
            (PB_STATE >= 0x26 && PB_STATE <= 0x29))
            ui_menu();                      /* 0x0D1A */
        break;
    }

    ui_output();
}
