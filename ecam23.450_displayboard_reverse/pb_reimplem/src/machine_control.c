/*
 * machine_control.c - user and machine control layer of the power board
 * (0x10C0 machine_control, 0x3096 milk_cycle_end, 0x30BA encoder_poll).
 *
 * Called once per pass by state_control (0x331C). It turns the display keys,
 * the encoder, the alarms and the temperatures into changes of the machine
 * state `mstate` and sub-state `mstep`; state_control and the unit drivers
 * then run the sequences. Recipes are the programmed quantities of record A
 * (flowmeter pulses) and the taste -> grind tables inlined below.
 *
 * Temperatures are NTC codes: a higher code is colder.
 *
 * Key bits (keys = held, key_edges = newly pressed, keys_count = number held):
 *   0 one cup, 1 two cups, 2 hot water / OK, 3 P / menu, 4 on/off,
 *   6 cappuccino, 7 rinse / ESC.  keys_hi_edges bit 1 = encoder push.
 */
#include "pb.h"

#define KEY_1CUP   0x01
#define KEY_2CUP   0x02
#define KEY_OK     0x04
#define KEY_MENU   0x08
#define KEY_ONOFF  0x10
#define KEY_CAPPU  0x40
#define KEY_ESC    0x80

/* The firmware compares the NTC codes as signed 16 bit values after zero
 * extension, which is the same as an unsigned 8 bit compare. */

/* "Rinse at start": set when the coffee thermoblock is cold. The original
 * test is (t > 0x8E && eco) || (t > 0x8E && !eco): the energy saving bit
 * does not matter. */
static void set_start_rinse(void)
{
    if (temp_coffee > 0x8e)
        flags21 |= 0x08;
    else
        flags21 &= ~0x08;
}

static void machine_run(void);
static void container_removed(void);
static void energy_saving(void);
static void encoder_poll(void);
static void milk_cycle_end(void);

/* programmed quantity of a drink (drink = 0, 2, 4, 6, 8), NULL otherwise */
static volatile uint16_t *drink_qty(uint8_t d)
{
    switch (d) {
    case 0: return &qty_my;
    case 2: return &qty_espresso;
    case 4: return &qty_standard;
    case 6: return &qty_long;
    case 8: return &qty_extralong;
    }
    return 0;
}

/* 0x10C0 */
void machine_control(void)
{
    encoder_poll();

    /* ---- first start: language selection (state 0x0D) */
    if (mstate == 0x0d && !(alarms & 0x40)) {
        if (mstep == 0 || mstep == 1) {
            if ((keys & KEY_OK) && keys_count == 1 && mstep != 0) {
                /* OK held at sub 1: confirm after 30 ticks of 100 ms */
                if (lang_cycle_timer2 != 0) {
                    lang_cycle_timer = 30;          /* freeze the preview */
                    if (tickflags & 0x08)
                        lang_cycle_timer2--;
                    if (lang_cycle_timer2 == 0)
                        mstep = 2;
                }
            } else {
                lang_cycle_timer2 = 30;
            }
            /* cycle the language shown (timer decremented elsewhere) */
            if (lang_cycle_timer == 0) {
                lang_cycle_timer = 30;
                lang_preview++;
                if (disp_languages < lang_preview)  /* note: > count, not >= */
                    lang_preview = 0;
            }
            if ((key_edges & KEY_OK) && keys_count == 1 && mstep == 0)
                mstep = 1;
        } else if (mstep == 3) {
            /* store the language */
            if (language & 0x10) {                  /* a language was installed before */
                mstate = saved_mstate;
                mstep = saved_mstep;
            } else {
                mstate = (settings2 & 0x01) ? 0x0e : 0;  /* circuit fill pending */
                mstep = 0;
            }
            language &= 0xf0;
            language |= lang_preview | 0x10;
            settings = (language & 0x40) ? 0x1d : 0x0d;
            ee_save_req_c3 = 5;
            ee_save_req_c0 = 5;
        }
    } else {
        lang_cycle_timer2 = 30;
    }

    /* ---- on/off key (alone) or remote on/off request */
    if (((key_edges & KEY_ONOFF) && keys_count == 1) || (flags26 & 0x10)) {
        if (alarms & 0x40) {                        /* fault */
            if (mstate == 0 || mstate == 2)
                mstate = 7;
            else
                mstate = 0;
            if (mstate == 7)
                mstep = 0;
            else if (mstate == 0)
                mstep = 2;
        } else if (mstate == 0x0d) {
            if (language & 0x10) {
                mstate = saved_mstate;
                mstep = saved_mstep;
            }
        } else if (mstate == 2) {
            /* already turning off */
        } else if (mstate == 0) {
            if (mstep == 2) {                       /* standby: switch on */
                if (settings2 & 0x01) {
                    mstate = 0x0e;                  /* first start circuit fill */
                    mstep = 0;
                } else {
                    mstate = 1;
                    mstep = 0;
                    set_start_rinse();
                }
            }
        } else {
            /* switch off: flags21.3 = rinse, flags26.7 = rinse at switch-off */
            flags21 |= 0x08;
            flags26 &= ~0x80;
            if (mstate == 7 && mstep < 0x0e && mstep != 0) {
                step_timer = 30;
                flags21 &= ~0x08;
                if (mstep == 3)
                    flags26 |= 0x80;
                mstep = 0;
            } else if (mstate == 1) {
                flags21 &= ~0x08;
                if (mstep < 2 || mstep == 7)
                    flags26 |= 0x80;
                mstep = 0;
            } else if (mstate == 0x0e) {
                flags21 &= ~0x08;
                mstep = 7;
            } else {
                if (!(r01f & 0x04) || (alarms & 0x01))
                    flags21 &= ~0x08;
                if ((mstate == 8 && (mstep == 1 || mstep == 7)) ||
                    (mstate == 7 && mstep == 0x0e))
                    flags26 |= 0x80;
                mstep = 0;
            }
            mstate = 2;
        }
    }

    /* ---- auto-start: disabled while the display clock is not valid */
    if (!(flags28 & 0x01) && !(settings & 0x01)) {
        settings |= 0x01;
        ee_save_req_c3 = 5;
    }
    if ((!(settings & 0x01) && mstate == 0 && mstep == 2 &&
         set_autostart_h == disp_hour && set_autostart_m == disp_min && disp_sec < 11) ||
        (flags26 & 0x04)) {
        mstate = 1;
        mstep = 0;
        set_start_rinse();
    }

    if (mstate == 0 || (mstate == 8 && mstep == 9) || (mstate == 7 && mstep == 0x10)) {
        gateflags2 &= ~0x10;
        r01f &= ~0xc0;
    }

    /* ---- ready */
    if (mstate == 7 && mstep == 0) {
        brew_phase = 0;
        cappu_phase = 0;
        flags1d &= ~0x01;
        r01e &= ~0x40;
        flags25 &= ~0x02;
        r01f &= ~0xc0;
        rec4 = 0;
        refc = 0;
        r096 = 0;
        if (sensor_edges & 0x20)
            sensor_events |= 0x08;
    }
    if (!(mstate == 7 && mstep == 0)) {
        ready_timer = 0;
        sensor_events &= ~0x08;
    }

    /* ---- standby */
    if (mstate == 0) {
        flags21 &= ~0x40;
        flags28 &= ~0x40;
        flags25 &= ~0x06;
        r01f &= ~0x0c;
        gateflags2 &= ~0x40;
        alarms2 &= ~0x80;
        heatflags &= ~0x13;
        reff = 0;
        refe = 0;
        refa = 0;
        standby_flag = 1;
        flags28 |= 0x02;
    } else if (mstate == 7) {
        flags28 &= ~0x02;
    }

    if (mstate == 7 && mstep == 0) {
        if (sensors & 0x20) {
            if (ready_countdown != 0 && (tickflags & 0x04))
                ready_countdown--;
        } else {
            ready_countdown = 100;
        }
    }

    if (!(settings & 0x10)) {
        if (mstate != 1)
            flags1d &= ~0x04;
    } else {                                        /* energy saving */
        flags1d &= ~0x04;
        heatflags |= 0x10;
    }
    if (mstate != 1 && mstate != 8)
        heatflags &= ~0x01;
    if (mstate == 7 && mstep == 0) {
        if (!(sensors & 0x20) && (settings & 0x10))
            heatflags &= ~0x02;
    } else {
        heatflags &= ~0x02;
    }

    /* ---- the rest needs the water tank and the grounds container */
    if ((sensors & 0x10) || (sensors & 0x08))
        container_removed();
    else
        machine_run();

    energy_saving();
}

/* 0x147A..0x267E: machine_control with the water tank and the grounds
 * container in place */
static void machine_run(void)
{
    uint16_t qty;
    volatile uint16_t *slot;

    if ((mstate == 7 && mstep == 0x10) || (mstate == 0x0a && mstep > 1) ||
        (mstate == 8 && mstep == 9) || (mstate == 1 && mstep == 8) ||
        (mstate == 0x0c && mstep == 4))
        refa = 10;

    /* ---- circuit fill (0x0E) */
    if (mstate == 0x0e) {
        if (mstep == 5) {
            if (settings2 & 0x01) {                 /* first start: done */
                settings2 &= ~0x01;
                ee_save_req_c0 = 5;
                mstate = 0;
                mstep = 2;
            } else {
                if (gateflags2 & 0x40) {            /* water filter installed */
                    settings |= 0x80;
                    water_since_filter = 0;
                    gateflags2 &= ~0x40;
                    if (stat_filter != 0xff)
                        stat_filter++;
                    ee_save_req_c3 = 5;
                    red9 = 5;
                }
                mstate = 7;
                mstep = 0;
            }
        } else if (mstep == 0) {
            if (saved_mstate == 0 && saved_mstep == 2 && !(settings2 & 0x01)) {
                mstate = 1;
                mstep = 0;
            }
        } else if (mstep == 1) {
            if (saved_mstate == 0 && saved_mstep == 2 && !(settings2 & 0x01)) {
                mstate = 1;
                mstep = 0;
            } else if (alarms & 0x01) {
                mstep = 0;
            } else if ((sensors & 0x01) && (key_edges & KEY_OK) && keys_count == 1) {
                mstep = 2;
            }
        } else if (mstep == 3) {
            /* checked every pass: back to 0 until 180 pulses were pumped */
            if (pump_cnt_l >= 0xb4)
                mstep++;
            else
                mstep = 0;
        }
    }

    /* ---- ready: reheat when the thermoblocks have cooled down */
    if (mstate == 7 && mstep == 0 && !(alarms & 0x40) &&
        !(pump_state == 1 && (out_loads & 0x08))) {
        if (temp_coffee > ((settings & 0x10) ? 0xde : 0xa2)) {
            mstate = 1;
            mstep = 9;
            r01f |= 0x08;
        }
        if (!(settings & 0x10) && temp_steam > 0x8e) {
            mstate = 1;
            mstep = 9;
            r01f |= 0x08;
        }
    }

    if ((mstate == 7 && mstep == 0) ||
        (mstate == 7 && mstep > 0x0d && mstep < 0x11) ||
        (mstate == 1 && mstep > 6 && mstep < 9) ||
        (mstate == 8 && mstep == 7)) {
        if (!(r01f & 0x08) && temp_coffee <= 0x66)
            r01f |= 0x08;
    }
    if ((r01f & 0x08) && pump_state == 1 && (out_loads & 0x08) && pump_cnt_l >= 0x14)
        r01f &= ~0x08;

    if (mstate == 1 && mstep == 4)
        reba = 10;

    /* ---- coffee */
    if (brew_phase == 1 || brew_phase == 2) {
        /* long press on the cup key: programming the quantity */
        if (!((keys & (KEY_1CUP | KEY_2CUP)) && keys_count == 1 && (flags21 & 0x02) &&
              (drink == 0 || (flags1d & 0x01))))
            long_press_ms = 0;
        if ((tickflags & 0x08) && long_press_ms != 0) {
            long_press_ms--;
            if (long_press_ms == 0)
                flags28 |= 0x04;                    /* programming mode */
        }
    }

    switch (brew_phase) {
    case 0:                                         /* wait for a cup key */
        if ((key_edges & (KEY_1CUP | KEY_2CUP)) && keys_count == 1 &&
            !(alarms & 0x40) && !(flags26 & 0x20) && mstate == 7 && mstep == 0 &&
            !(alarms & 0x01) && !(alarms & 0x02)) {
            mstep++;
            brew_phase++;
            if (temp_coffee > 0x8d && (settings & 0x10))
                r01f |= 0x40;                       /* preheat first */
            flags28 &= ~0x04;
            if (key_edges & KEY_1CUP) {
                flags21 |= 0x02;
                cups = 0;
            } else {
                flags21 &= ~0x02;
                cups = 1;
            }
            if ((settings & 0x10) && (r01f & 0x40))
                preheat_delay = 20;
            else
                preheat_delay = 0;
            long_press_ms = 0x50;
            wait_flags |= 0x80;
            flags21 |= 0x80;
            sensor_events |= 0x30;
            flags21 &= ~0x40;
            flags25 &= ~0x06;
        }
        break;

    case 1:                                         /* compute the recipe */
        if (preheat_delay != 0)
            break;
        brew_phase++;
        if (r01f & 0x40)
            mstep++;
        else
            mstep = 4;
        slot = drink_qty(drink);
        if (flags21 & 0x02) {                       /* one cup */
            if (slot)
                target_qty = *slot;
            switch (taste) {
            case 0x10: grind_1cup = 0x28; break;
            case 0x20: grind_1cup = 0x2f; break;
            case 0x30: grind_1cup = 0x38; break;
            case 0x40: grind_1cup = 0x3e; break;
            case 0x50: grind_1cup = 0x44; break;
            }
        } else {                                    /* two cups */
            if (slot)
                target_qty_total = *slot * 2 + 10;
            switch (taste) {
            case 0x10: grind_2cup = 0x3f; break;
            case 0x20: grind_2cup = 0x43; break;
            case 0x30: grind_2cup = 0x48; break;
            case 0x40: grind_2cup = 0x4b; break;
            case 0x50: grind_2cup = 0x4f; break;
            }
        }
        break;

    case 2:                                         /* brewing */
        if (mstate == 7 && mstep < 0x0e && mstep != 0 && (flags21 & 0x40)) {
            flags21 |= 0x80;
            flags21 &= ~0x40;
        } else if (mstate == 7 && mstep < 0x0e && mstep != 0) {
            int key = (((key_edges & (KEY_1CUP | KEY_2CUP)) ||
                        ((key_edges & KEY_CAPPU) && (flags1d & 0x01))) && keys_count == 1);
            int dosing = (mstate == 7 && mstep == 0x0b && pump_state == 1 && (out_loads & 0x08));
            if (key || ((flags28 & 0x04) && dosing && pump_cnt_l >= 0x187)) {
                if ((flags28 & 0x04) && dosing) {
                    /* programming: store the measured quantity (40..390 pulses) */
                    mstep++;
                    if (pump_cnt_l >= 0x187)
                        qty = 0x186;
                    else if (pump_cnt_l < 0x28)
                        qty = 0x28;
                    else
                        qty = pump_cnt_l;
                    if (flags1d & 0x01) {
                        qty_cappu_coffee = qty;
                    } else {
                        slot = drink_qty(drink);
                        if (slot)
                            *slot = qty;
                    }
                    ee_save_req_c0 = 5;
                } else if ((flags28 & 0x04) || mstep < 0x0c) {
                    /* stop the brew */
                    flags25 |= 0x02;
                    if (mstep < 4) {
                        mstep = 0x0e;
                    } else {
                        if (mstep < 7)
                            flags25 |= 0x04;
                        mstep = 0x0c;
                    }
                }
            }
        }
        if ((flags28 & 0x04) && ((alarms & 0x40) || (alarms & 0x10)))
            flags28 &= ~0x04;
        break;

    case 3:                                         /* second cup */
        cups = 0;
        brew_phase--;
        mstate = 7;
        mstep = 5;
        step_timer = 10;
        flags21 |= 0x80;
        flags21 &= ~0x40;
        flags25 &= ~0x06;
        if (flags1d & 0x10)
            flags28 |= 0x04;
        else
            flags28 &= ~0x04;
        break;
    }

    if (rf07 == 0 && (flags21 & 0x40) && mstate == 7) {
        mstep = 0x0e;
        flags21 &= ~0x40;
    }

    /* ---- alarms.5 = no coffee (stroke >= 0xF2 pulses: nothing ground) and
     * alarms2.5 = "add less coffee" (short stroke < 0xC9: too much ground
     * coffee). They abort the brew (sub 0x0E); each has a 30 tick timer that
     * holds it back from the display (spi_build_reply). */
    if ((flags21 & 0x80) || mstate == 0) {
        alarms &= ~0x20;
        alarms2 &= ~0x20;
    }
    if (keys_hi_edges | key_edges)
        alarms2 &= ~0x20;
    if (mstate == 7 && mstep < 0x0e && mstep != 0 && ((alarms & 0x20) || (alarms2 & 0x20)))
        mstep = 0x0e;
    if (!(alarms2 & 0x20))
        less_coffee_timer = 30;
    if (!(alarms & 0x20))
        beans_alarm_timer = 30;
    if (mstate != 7) {
        if ((alarms2 & 0x20) && less_coffee_timer != 0)
            less_coffee_timer = 0;
        if ((alarms & 0x20) && beans_alarm_timer != 0)
            beans_alarm_timer = 0;
    }

    if (mstate == 7 && mstep == 0x0b && pump_state == 1 && (out_loads & 0x08))
        r01f |= 0x04;

    /* flags25.7: a cup key pressed at the end of the brew (sub 0x0D) while
     * there is still water: pour the second part */
    if (mstate == 7 && mstep == 0x0d &&
        ((keys & (KEY_1CUP | KEY_2CUP)) || ((keys & KEY_CAPPU) && (flags1d & 0x01))) &&
        keys_count == 1 && !(flags28 & 0x04) && !(flags25 & 0x02) && nowater_cnt_l < 0xb5)
        flags25 |= 0x80;
    else
        flags25 &= ~0x80;

    if (mstate != 7 || mstep > 0x0d || mstep == 0)
        flags21 &= ~0x40;

    /* ---- milk / cappuccino (0x0A): key, or gateflags2.5 = milk quantity reached */
    if ((((key_edges & KEY_CAPPU) && keys_count == 1) || (gateflags2 & 0x20)) &&
        !(alarms & 0x10) && !(alarms & 0x40) && !(flags26 & 0x20) && !(alarms & 0x02)) {
        if (mstate == 7 && mstep == 0 && (key_edges & KEY_CAPPU) && keys_count == 1 &&
            !(alarms & 0x01)) {
            mstate = 0x0a;
            flags1d &= ~0x12;
            gateflags2 &= ~0x20;
            flags1d |= 0x01;                        /* coffee after the milk */
            cappu_toggle_win = 0;
            if ((sensors & 0x20) && ((settings & 0x10) || (heatflags & 0x10))) {
                mstep = 1;
                flags1d |= 0x10;                    /* programming allowed */
                prog_press_timer = 0x50;
                cappu_toggle_win = 0x14;
                if (key_edges & KEY_CAPPU)
                    milk_prog_slot = 0;
            } else {
                mstep = 0;
                step_timer = 50;
            }
        } else if (mstep != 0 && mstate == 0x0a &&
                   (((key_edges & KEY_CAPPU) && milk_prog_slot == 0) || (gateflags2 & 0x20))) {
            if (mstep == 1 && (key_edges & KEY_CAPPU) && keys_count == 1 && cappu_toggle_win != 0) {
                /* pressed again quickly: cappuccino <-> frothed milk only */
                flags1d ^= 0x01;
                cappu_toggle_win = 0x14;
                flags1d &= ~0x10;
                if (flags1d & 0x01) {
                    flags1d |= 0x10;
                    prog_press_timer = 0x50;
                }
            } else if (mstep < 3) {
                milk_cycle_end();
            } else if (mstep < 5) {
                if (flags1d & 0x10) {
                    /* programming: store the milk time (uptime_100ms is reused as
                     * the milk counter, cleared at sub 3), 0x32..0x960 */
                    if (uptime_100ms >= 0x32 && uptime_100ms < 0x961) {
                        if (milk_prog_slot == 0)
                            qty_milk_0 = uptime_100ms;
                        else if (milk_prog_slot == 0x40)
                            qty_milk_1 = uptime_100ms;
                        else if (milk_prog_slot == 0x80)
                            qty_milk_2 = uptime_100ms;
                        ee_save_req_c0 = 5;
                    }
                    gateflags2 &= ~0x20;
                } else {
                    flags1d &= ~0x10;
                }
                mstep = 6;
            } else if (mstep == 6) {
                milk_cycle_end();
            }
        }
    }

    if (mstate == 0x0a) {
        if (prog_press_timer != 0) {
            if (keys_count != 1 || (!(keys & KEY_CAPPU) && milk_prog_slot == 0) ||
                milk_prog_slot == 0x40 || milk_prog_slot == 0x80)
                flags1d &= ~0x10;                   /* released before the long press */
        }
        if (mstep == 2 && step_timer == 0)
            flags1d |= 0x20;
        if (mstep == 3) {
            if (step_timer != 0) {
                uptime_100ms = 0;
                milk_timer = 120;
            } else if ((flags1d & 0x10) && uptime_100ms >= 0x960) {
                gateflags2 |= 0x20;                 /* programming: maximum reached */
            }
        }

        /* abort: steam not ready, no water, or grind too fine */
        if (!((sensors & 0x20) || mstep == 0) ||
            ((alarms & 0x01) && nowater_cnt_l >= 0xb5) ||
            (alarms & 0x10)) {
            if (sensors & 0x20)
                milk_cycle_end();
            else if (mstep < 3)
                milk_cycle_end();
            else if (step_timer != 0 && mstep == 3)
                milk_cycle_end();
            else
                mstep = 6;
            flags1d &= ~0x10;
        } else if (mstep == 5) {
            if ((key_edges & KEY_CAPPU) && keys_count == 1) {
                flags1d |= 0x02;
            } else if (!((keys & KEY_CAPPU) && keys_count == 1)) {
                flags1d &= ~0x02;
                milk_end_timer = 30;
            }
            if ((flags1d & 0x02) && milk_end_timer != 0 && (tickflags & 0x08))
                milk_end_timer--;
        }

        /* toggle window over: prepare the coffee part of the cappuccino */
        if (cappu_toggle_win == 0 && (flags1d & 0x01)) {
            if (cappu_phase == 0) {
                cappu_phase = (settings & 0x10) ? 3 : 4;
                target_qty = qty_cappu_coffee;
                switch (taste) {
                case 0x10: grind_1cup = 0x28; break;
                case 0x20: grind_1cup = 0x2f; break;
                case 0x30: grind_1cup = 0x38; break;
                case 0x40: grind_1cup = 0x3e; break;
                case 0x50: grind_1cup = 0x44; break;
                }
                flags21 |= 0x02;
                sensor_events |= 0x30;
                wait_flags |= 0x80;
            } else if (mstep == 6 && cappu_phase == 3) {
                cappu_phase = 4;
            }
        }
    }

    /* ---- hot water (0x0B) */
    if (mstate == 0x0b) {
        if (!((keys & KEY_OK) && keys_count == 1) && prog_press_timer != 0)
            flags1d &= ~0x10;
        if (mstep == 2) {
            if (rec5 != 0 && (tickflags & 0x08))
                rec5--;
            if ((flags1d & 0x10) && pump_cnt_l >= 0x3e9 && pump_state == 1 && (out_loads & 0x08))
                heatflags |= 0x08;                  /* programming: maximum reached */
        }
        if (mstep < 5) {
            if (((alarms & 0x01) && nowater_cnt_l >= 0xb5) || (!(sensors & 0x01) && mstep != 0)) {
                flags1d &= ~0x10;                   /* no water or spout removed */
                mstep = 4;
                rebd = 0;
            }
        }
        if (((key_edges & KEY_OK) && keys_count == 1 && mstep != 0) || (heatflags & 0x08)) {
            mstep = 3;                              /* stop */
            if (flags1d & 0x10) {
                flags1d &= ~0x10;
                heatflags &= ~0x08;
                qty_hotwater = (pump_cnt_l >= 0x3e9) ? 0x3e8 : pump_cnt_l;
                ee_save_req_c0 = 5;
            }
        }
    }

    /* The original also tests (OK && grind too fine && one key) here, which
     * can never add anything to the plain OK test. */
    if (key_edges & KEY_OK) {
        if (((mstate == 7 && mstep == 0) || (mstate == 1 && mstep == 9)) &&
            !(alarms & 0x01) && !(alarms & 0x40) && !(flags26 & 0x20)) {
            mstate = 0x0b;
            flags1d &= ~0x10;
            heatflags &= ~0x88;
            rec5 = 0;
            if ((sensors & 0x01) && !(sensors & 0x20) &&
                ((settings & 0x10) || (heatflags & 0x10))) {
                mstep = 1;
                flags1d |= 0x10;
                prog_press_timer = 0x50;
                if (temp_steam < 0x4e)
                    heatflags |= 0x80;
            } else {
                mstep = 0;
                step_timer = 50;
            }
        }
    }

    /* ---- cleaning (0x0C), started by sensor_edges.0 in ready */
    if ((sensor_edges & 0x01) && mstate == 7 && mstep == 0 && (sensors & 0x20) &&
        ready_countdown == 0 && ((settings & 0x10) || (heatflags & 0x10)) &&
        !(alarms & 0x01) && !(alarms & 0x10) && !(alarms & 0x40) && !(flags26 & 0x20)) {
        mstate = 0x0c;
        mstep = 0;
        clean_ticks = 0;
    }
    if (mstate == 0x0c && mstep < 3) {
        if ((tickflags & 0x08) && mstep == 2 && clean_ticks != 0xff)
            clean_ticks++;
        if (!((sensors & 0x20) && (sensors & 0x01)) || clean_ticks > 0xc7 ||
            ((alarms & 0x01) && nowater_cnt_l >= 0xb5) || (alarms & 0x10))
            mstep = 3;
    }
    if (mstate == 0x0c) {
        if (clean_ticks > 0x31)
            milk_timer = 0;
    } else if (mstate == 7 && mstep == 0 && !(sensors & 0x20)) {
        milk_timer = 0;
    } else if (mstate == 0) {
        milk_timer = 0;
    }

    /* ---- rinse (8) */
    if ((key_edges & KEY_ESC) && keys_count == 1 && !(flags26 & 0x20) &&
        !(alarms & 0x01) && !(alarms & 0x40) && mstate == 7 && mstep == 0) {
        mstate = 8;
        mstep = 0;
        flags21 |= 0x08;
    } else if (mstate == 8 && mstep < 7 && (key_edges & KEY_ESC) && keys_count == 1) {
        mstep = 7;                                  /* stop */
    }

    /* ---- descaling (4), requested from the menu (flags28.6) */
    if (flags28 & 0x40) {
        saved_mstate = mstate;
        saved_mstep = mstep;
        mstate = 4;
        mstep = 0;
        alarms2 |= 0x80;                            /* descaling in progress */
        descale_timer = 30;
        sensor_events &= ~0x01;
        flags28 &= ~0x40;
    }
    if (mstate == 4) {
        if (mstep == 1 || mstep == 4) {
            /* flags1d.3 = go on (spout in place and OK) */
            if (!(sensors & 0x01))
                flags1d &= ~0x08;
            else if (((key_edges & KEY_OK) && keys_count == 1 && !(alarms & 0x01)) ||
                     (alarms & 0x10))
                flags1d |= 0x08;
        } else if (mstep == 5) {
            flags1d &= ~0x08;
            if ((key_edges & KEY_OK) && keys_count == 1) {
                alarms2 &= ~0x80;
                flags1d |= 0x08;
            }
        } else if (mstep != 2) {
            flags1d &= ~0x08;
        }
    } else {
        flags1d &= ~0x08;
    }

    /* ---- pump pulse mode (ioflags.6, period / on cycles) by state */
    {
        uint8_t req = 0;

        if (mstate == 0x0b) {
            if (mstep == 1) {
                req = 1;
                pump_period = 0x98;
                pump_on_cycles = 2;
            } else if (temp_coffee > 0x5e &&
                       temp_steam > ((heatflags & 0x80) ? 0x4e : 0x5e)) {
                req = 1;
                pump_period = 5;
                pump_on_cycles = 2;
            }
        } else if (mstate == 1 || mstate == 8) {
            if (mstate == 1 || ((r01f & 0x80) && (settings & 0x10))) {
                if (reba == 0)
                    req = 1;
                pump_period = 0x32;
                pump_on_cycles = 0x14;
            }
        } else if (mstate == 0x0a) {
            if (mstep != 1) {
                req = 1;
                pump_period = 0x31;
                pump_on_cycles = 4;
            } else if (!(r01f & 0x08)) {
                req = 1;
                pump_period = 0x98;
                pump_on_cycles = 2;
            }
        } else if (mstate == 0x0c) {
            req = 1;
            if (mstep < 2) {
                pump_period = 0x98;
                pump_on_cycles = 2;
            } else {
                pump_period = 0x96;
                pump_on_cycles = 0x32;
            }
        } else if (mstate == 5) {
            if (mstep == 1) {
                if (!(r01f & 0x08)) {
                    req = 1;
                    pump_period = 0x98;
                    pump_on_cycles = 2;
                }
            } else if (mstep == 2) {
                req = 1;
                pump_period = 0x2f;
                pump_on_cycles = 2;
            }
        }
        di();
        if (req == 1)
            ioflags |= 0x40;
        else
            ioflags &= ~0x40;
        ei();
    }

    if (keys_count != 0)
        activity_timer = 120;

    /* ---- grinder adaptation. sensor_events.5: brew done, learn the stroke
     * (bu_pos when the brew unit stopped on the coffee cake). */
    if ((sensor_events & 0x20) && ((mstate == 7 && mstep == 7) || (alarms2 & 0x20))) {
        sensor_events &= ~0x20;
        if (!(alarms & 0x20) && !(flags21 & 0x10) && !(alarms & 0x40))
            grind_history_update(bu_pos);
    }
    /* sensor_events.4: compute the grinder dose before grinding */
    if ((sensor_events & 0x10) &&
        ((mstate == 7 && mstep == 4) || (mstate == 0x0a && cappu_phase == 4))) {
        sensor_events &= ~0x10;
        if (!(flags21 & 0x10))                      /* not pre-ground coffee */
            grind_dose_compute();
    }
    /* sensor_events.6: first warm-up, learn the full brew unit stroke */
    if ((sensor_events & 0x40) && mstate == 1 && mstep == 5) {
        sensor_events &= ~0x40;
        if (bu_stroke_ref == 0) {
            bu_stroke_ref = bu_pos;
            ee_save_req_c3 = 5;
        }
    }

    /* ---- clear "grind too fine" (alarms.4) */
    if (((key_edges & KEY_OK) && (sensors & 0x01) && !(sensors & 0x20) &&
         ((mstate == 7 && mstep == 0) || mstate == 0x0b || mstate == 0x0e)) ||
        ((keys_hi_edges & 0x02) && mstate == 7 && mstep == 0) ||
        (flags21 & 0x80) ||
        (mstate == 8 && mstep == 0) ||
        (mstate == 1 && mstep == 0) ||
        (mstate == 2 && mstep == 2)) {
        if (alarms & 0x10)
            r01e |= 0x80;
        alarms &= ~0x10;
        gateflags2 &= ~0x04;
    }

    /* ---- brew unit fault: OK + ESC held together resets it */
    if ((alarms & 0x40) && fault_class == 1) {
        if (fault_step < 5 && (keys & KEY_OK) && (keys & KEY_ESC) && keys_count == 2)
            flags25 |= 0x40;
        else
            flags25 &= ~0x40;
    }
    if ((alarms & 0x40) && fault_class == 1 && (fault_step == 1 || fault_step == 4)) {
        if (fault_step == 1)
            set_fault = 1;
        else if (fault_step == 4)
            set_fault = 0;
        ee_save_req_c3 = 5;                         /* every pass while there */
    }

    if (mstate == 0x0b && (sysflags & 0x01))        /* flow pulse during hot water */
        ee_save_req_c3 = 5;

    /* ---- ready: encoder push changes the taste, the encoder the drink */
    if (mstate == 7 && mstep == 0 && (keys_hi_edges & 0x02) && keys_count == 1 &&
        !(flags26 & 0x20) && energy_timer != 0) {
        taste += 0x10;
        if (taste > 0x50)
            taste = 0;
        if (taste == 0)
            flags21 |= 0x10;                        /* pre-ground coffee */
        else
            flags21 &= ~0x10;
        alarms &= ~0x20;
        alarms2 &= ~0x20;
    }
    if (mstate == 7 && mstep == 0) {
        if ((r01e & 0x08) && keys_count == 0 && !(flags26 & 0x20)) {
            drink += 2;
            if (drink > 8)
                drink = 0;
        } else if ((r01e & 0x10) && keys_count == 0 && !(flags26 & 0x20)) {
            if (drink == 0)
                drink = 8;
            else
                drink -= 2;
        }
    }

    menu_keys();

    /* the menu is only kept open in ready, until its timeout */
    if (!(mstate == 7 && mstep == 0 && menu_timeout != 0))
        flags26 &= ~0x20;
}

/* 0x2680: water tank or grounds container removed */
static void container_removed(void)
{
    if (mstate == 0x0e && mstep == 1)
        mstep = 0;
    if (mstate == 0x0b && mstep < 3) {             /* stop the hot water */
        mstep = 3;
        flags1d &= ~0x10;
    }
    if (mstate == 0x0a) {
        milk_cycle_end();
        flags1d &= ~0x10;
        r01f &= ~0x10;
    }
    if (mstate == 0x0c || mstate == 5) {
        mstate = 7;
        mstep = 0;
    }
    flags26 &= ~0x20;                               /* leave the menu */
}

/* 0x26CE: energy saving. energy_timer (60) counts down on the 1 s tick while
 * the machine sits idle in ready; 0 = energy saving active. */
static void energy_saving(void)
{
    if (!(settings & 0x10))
        return;
    if (mstate == 7 && mstep == 0 && !(alarms & 0x01) && !(alarms & 0x02) &&
        !(sensors & 0x10) && !(sensors & 0x20) && !(alarms & 0x10) &&
        !(keys_hi_edges | key_edges) && !(r01e & 0x08) && !(r01e & 0x10)) {
        if (energy_timer != 0 && (tickflags & 0x10))
            energy_timer--;
    } else {
        energy_timer = 60;
    }
}

/* 0x3096: end of a milk cycle, back to ready. With the coffee still to
 * pour (flags1d.0) the sub-state tells the display how far it went. */
static void milk_cycle_end(void)
{
    if (flags1d & 0x01) {
        if (cappu_phase > 3) {
            flags25 |= 0x02;
            flags25 |= 0x04;
            mstep = 0x0c;
        } else {
            flags25 |= 0x02;
            mstep = 0x0e;
        }
    } else {
        mstep = 0;
    }
    mstate = 7;
}

/* 0x30BA: encoder from the display position byte. r01e.3 = one step up
 * (clockwise), r01e.4 = one step down, for this pass only. */
static void encoder_poll(void)
{
    uint8_t delta;
    uint8_t down = 0;

    r01e &= ~0x18;
    enc_step = 1;
    if ((flags26 & 0x20) || mstate == 7)           /* same value either way */
        enc_step = 1;

    /* resynchronise once the display position has been still for 3 s */
    if ((tickflags & 0x08) && enc_activity != 0) {
        enc_activity--;
        if (enc_activity == 0)
            enc_last = disp_enc;
    }

    if (disp_enc >= enc_last) {
        delta = disp_enc - enc_last;
        /* A wrapped difference is "fixed" by adding 2 instead of negating it:
         * right for a one step wrap (0xFF -> 1), a two step wrap gives 0. */
        if (delta > 0x7e) {                         /* wrapped: going down */
            delta += 2;
            down = 0xff;
        }
    } else {
        delta = enc_last - disp_enc;
        if (delta > 0x7e)
            delta += 2;                             /* wrapped: going up */
        else
            down = 0xff;
    }
    if (delta >= enc_step) {
        enc_last = disp_enc;
        if (down == 0)
            r01e |= 0x08;
        else
            r01e |= 0x10;
    }
}
