# Power board symbols proposed by the "process" analysis (see docs/pb_notes/process.md)
# Area: f_10c0 (machine control: keys -> state/sub-state, recipes, menu) and its callees.

RAM = {
    # user input as seen by the control logic
    0x043: ('keys_new', 'newly pressed keys, display tx_keys order: b0 1cup b1 2cups b2 hotwater/OK b3 P b4 on/off b6 cappu b7 rinse/ESC (f_10c0@119e on/off)'),
    0x011: ('keys_held', 'keys currently held, same bit order as keys_new (f_10c0@10d8, @1b3c)'),
    0x044: ('keys_hi_new', 'edges of display byte7 bits, b1 = encoder push (f_10c0@22d4 taste)'),
    0x02D: ('keys_held_count', 'number of keys held; "key alone" tests are DECF r02d,w == 0 (f_10c0@10dc...)'),

    # encoder (f_30ba)
    0xEA6: ('enc_last', 'last encoder position used by f_30ba; delta vs disp_enc (0xEA5)'),
    0xE5A: ('enc_step', 'encoder step threshold, = 1 (f_30ba)'),

    # brew / recipe
    0xE84: ('brew_phase', 'coffee dispatcher: 0 wait key, 1 compute recipe, 2 brewing, 3 second cup (f_10c0@1698, INCF @170e/@1768, DECF @1a46)'),
    0xE83: ('milk_phase', 'cappuccino/milk sequencing counter, 3/4 after milk -> coffee; >3 sets r025.2 in f_3096 (f_10c0@1df6, f_3096@309e)'),
    0xE55: ('cups_2', '0 = 1 cup, 1 = 2 cups for the current brew (f_10c0 re84==0 branch)'),
    0xE56: ('drink_sel', 'selected drink 0,2,4,6,8 = MY/ESPRESSO/STANDARD/LONG/EXTRA LONG; encoder CW +2 wrap>8->0, CCW -2 (f_10c0@178c..17c8)'),
    0xE63: ('taste', 'aroma 0x00(pre-ground),0x10..0x50; encoder push +0x10, wrap >0x50 -> 0 (f_10c0@22d4, tables @17da, @1892)'),
    0xE57: ('grind_1cup', 'grind/dose param 1 cup from taste: 0x28,0x2f,0x38,0x3e,0x44 (f_10c0@1810, used f_2718@2828)'),
    0xE58: ('grind_2cup', 'grind/dose param 2 cups from taste: 0x3f,0x43,0x48,0x4b,0x4f (f_10c0@18c8, used f_2718@28d8)'),
    0x092: ('target_qty', '16-bit (0x092/0x093) target water, flowmeter pulses, from programmed qty per drink (f_10c0@1782..17d2, milk: r0e9 @1dfa)'),
    0x094: ('target_qty_2cup', '16-bit (0x094/0x095) 2-cup target = qty*2+10 (f_10c0@1886)'),
    0x0DC: ('qty_my', '16-bit programmed water qty for drink 0 (MY), pulses (f_10c0@1782)'),
    0x0DE: ('qty_espresso', '16-bit programmed qty drink 2 (f_10c0@1796)'),
    0x0E0: ('qty_standard', '16-bit programmed qty drink 4 (f_10c0@17aa)'),
    0x0E2: ('qty_long', '16-bit programmed qty drink 6 (f_10c0@17be)'),
    0x0E4: ('qty_extralong', '16-bit programmed qty drink 8 (f_10c0@17d2)'),
    0x0E7: ('qty_hotwater', '16-bit programmed hot water qty (0x0E7/0x0E8), max 1000 (f_10c0@1f1c)'),
    0x0E9: ('qty_cappu_coffee', '16-bit coffee qty after milk (cappuccino) (f_10c0@1dfa)'),
    0x0EB: ('qty_milk_0', '16-bit programmed milk qty, re54 = 0 (f_10c0@1c84)'),
    0x0EF: ('qty_milk_1', '16-bit programmed milk qty, re54 = 0x40 (f_10c0@1c98)'),
    0x0F3: ('qty_milk_2', '16-bit programmed milk qty, re54 = 0x80 (f_10c0@1cac)'),
    0xED4: ('long_press_ms', 'long-press timer 0x50 on a cup key; expiry with key held -> r028.2 programming mode (f_10c0 re84==0)'),
    0xED5: ('prog_press_timer', '0x50 long-press timer for milk/hot water programming (f_10c0 milk sub1, hot water sub1)'),
    0xED1: ('cappu_toggle_win', 'window (0x14) where pressing cappu again toggles r01d.0 (f_10c0 milk)'),
    0xEB7: ('preheat_delay', '20: preheat delay before brewing with energy saving (f_10c0 re84==0)'),
    0xE9A: ('ready_countdown', '100, counts down while r013.5; cleaning allowed at 0 (f_10c0 ready)'),
    0xEB6: ('clean_ticks', 'cleaning tick counter: >0xc7 -> sub 3, >0x31 clears rf00 (f_10c0 state 0x0c)'),
    0xF00: ('milk_timer', '120 at milk sub 3; also flags1.5 (f_10c0)'),
    0xEBF: ('milk_end_timer', '30 at milk sub 5 (f_10c0)'),
    0xF05: ('beans_alarm_timer', '30-tick timer for beans-empty abort (f_10c0 sub 0x0e)'),
    0xF06: ('less_coffee_timer', '30-tick timer for "add less coffee" (f_10c0 sub 0x0e)'),

    # adaptive grinder (f_2be6 / f_2718)
    0x0BC: ('brew_time_ref', '16-bit reference brew time (0x0BC/0x0BD) stored at warm-up sub 5 on r024.6 (f_10c0@22a0)'),
    0x0F5: ('brew_time_last', '16-bit last brew time r06d/e (f_10c0@224a)'),
    0x08C: ('brew_time_diff', '16-bit r0bc - r0f5 (f_2be6)'),
    0x0B5: ('grind_hist_a', 'grind history (0x0B5/0x0B6) shifted by f_2be6'),
    0x0B8: ('grind_hist_b', 'grind history (0x0B8/0x0B9) <- recc (f_2be6@2c74)'),
    0x0BA: ('grind_hist_c', 'grind history (0x0BA/0x0BB) shifted by f_2be6'),
    0x0BE: ('grind_center', 'grind centre value, dose clamped to +-3 around it (f_2718); default 0x50 on r019.5'),
    0xE53: ('grind_avg', 'weighted average of the histories (f_2718)'),
    0xECC: ('grind_dose', 'computed grinder dose, clamped [recd, rece] (f_2718@2bac..2bde) -> r034 (f_3186@3e5a)'),
    0xECD: ('grind_dose_min', 'lower bound for recc (f_2718)'),
    0xECE: ('grind_dose_max', 'upper bound for recc (f_2718)'),

    # menu (f_10c0, f_2cb8, f_2dee, f_3002, f_3044)
    0xE6C: ('menu_item', 'menu item 0..0x0e (+0x0f auto-start time); skips items with table 0x108F[item]==0'),
    0xE6B: ('menu_level', 'menu level 0 = list, >0 inside an item'),
    0xEFD: ('menu_timeout', '120, exits the menu at 0'),
    0xF0A: ('menu_value', 'edited value / hours when editing a time (f_2cb8, f_3002)'),
    0xF0B: ('menu_minutes', 'minutes when editing a time (f_3002/f_3044)'),
    0xEE0: ('menu_value_max', 'max of menu_value for the item (f_2cb8)'),
    0xE54: ('milk_prog_slot', 'milk quantity slot 0/0x40/0x80 (f_10c0 milk)'),
    0xE6A: ('lang_preview', 'language shown during first start, cycles modulo redf (f_10c0 state 0x0d)'),
    0xEC6: ('lang_cycle_timer', '30-tick timer for the language preview (f_10c0 state 0x0d)'),
    0xEC7: ('lang_cycle_timer2', '30-tick timer paired with rec6 (f_10c0 state 0x0d)'),

    # settings (EEPROM, written by the menu)
    0x0C0: ('set_hardness', 'water hardness 0..3 (menu item 5)'),
    0x0C1: ('set_temperature', 'coffee temperature 0..4 (menu item 3)'),
    0x0B4: ('set_item7', 'menu item 7 value 0..3 (auto-off time?), default 3'),
    0x0C2: ('settings', 'b0 auto-start off, b2 beep, b3 cup light, b4 energy saving, b7 filter; default 0x0d/0x1d'),
    0x0C3: ('autostart_hour', 'auto-start hour (menu item 0x0f)'),
    0x0C4: ('autostart_min', 'auto-start minute (menu item 0x0f)'),
    0x0DA: ('language', 'b0..3 language, b4 installed, b6 (keeps energy default 0x1d)'),
    0x0D5: ('filter_count', 'filter installs/replacements counter (++ on install)'),
    0xEC3: ('ee_save_req_a', 'EEPROM save request countdown (=5) for settings'),
    0xEC0: ('ee_save_req_b', 'EEPROM save request countdown (=5) for quantities/settings'),

    # misc control
    0xE72: ('saved_substate', 'r038 saved before descaling / language, restored after'),
    0xE73: ('saved_state', 'r03c saved before descaling / language, restored after'),
    0xEF6: ('energy_timer', '60, ticks down while idle in ready; 0 = energy saving active (flags1.6)'),
    0xF02: ('activity_timer', '120 whenever a key is held'),
    0x0A4: ('state_timer', 'sub-state timer loaded 10/30/50 on transitions'),
    0xE85: ('fault_step', 'fault sub-step: ESC+OK reset allowed <5; 1 -> r0bf=1, 4 -> r0bf=0'),
    0xE89: ('standby_flag', 'set to 1 in standby'),
    0xEF4: ('descale_timer', '30 at descaling start'),
}

FUNCS = {
    0x10C0: ('machine_control', 'user/machine control: keys, encoder, menu, recipes -> r03c/r038 transitions; called from f_3186@331c'),
    0x30BA: ('encoder_poll', 'encoder delta disp_enc vs enc_last -> r01e.3 CW / r01e.4 CCW'),
    0x2CB8: ('menu_item_open', 'load menu_value / menu_value_max for menu_item'),
    0x2DEE: ('menu_item_apply', 'apply menu_value to the setting of menu_item, request EEPROM save'),
    0x3002: ('menu_time_inc', 'clock edit +1: hours (arg 0xff) 0..23 or minutes (arg 0) 0..59'),
    0x3044: ('menu_time_dec', 'clock edit -1: hours or minutes'),
    0x3096: ('milk_cycle_end', 'end of milk/cappuccino: back to ready, sub 0x0c/0x0e or 0'),
    0x2BE6: ('grind_history_update', 'update grind histories from brew-time difference'),
    0x2718: ('grind_dose_compute', 'adaptive grinder dose from histories, clamped'),
    0x0F70: ('mul32', '32-bit multiply (compiler helper)'),
    0x85A8: ('mul32_b', '32-bit multiply (compiler helper)'),
    0x85BC: ('div32', '32-bit divide, operand pointer in FSR0 (compiler helper)'),
    0x857E: ('shl32', 'shift left (compiler helper)'),
}
