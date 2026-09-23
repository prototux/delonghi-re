# Symbol proposals from the "fsm" analysis (f_3186, f_803e).
# See docs/pb_notes/fsm.md for the evidence.

FUNCS = {
    0x3186: ('state_control', 'per-tick machine supervisor: power-up key combos, test modes, calls the '
                              'process engine f_10c0, per-state actuator demands + step sequencing, '
                              'actuator drivers, auto-off, eco level, test timers'),
    0x803e: ('monitor_faults', 'alarm/fault supervisor: brew unit motor watchdog, NTC range, grounds, '
                               'descale/filter counters, tank, beans/less coffee'),
}

RAM = {
    # machine state
    0x03C: ('mstate', 'machine state = display pb_state (0,1,2,4,6,7,8,0x0A-0x0F); dispatch 0x41D6'),
    0x038: ('mstep', 'sub-state / step inside mstate = display pb_param1 bits 0-4; tables 0x36B8, 0x3BE8'),
    0xE73: ('saved_mstate', 'mstate saved when entering descaling / brew unit recovery (0x81CC, 0x402C)'),
    0xE72: ('saved_mstep', 'mstep saved with saved_mstate, restored at 0x41AE'),
    # keys (written by f_6208, used here)
    0x011: ('keys', 'display key bitmap (SPI byte 1): 1=1cup 2=2cups 4=hotwater/OK 8=menu 0x10=onoff 0x40=cappu 0x80=rinse/ESC (0x6236)'),
    0x012: ('keys2', 'display byte7 & 3: bit1 = encoder push (0x623A)'),
    0x043: ('keys_pressed', 'rising edges of keys (0x6224)'),
    0x044: ('keys2_pressed', 'rising edges of keys2 (0x6234)'),
    0x02D: ('keys_count', 'number of keys held incl. encoder push (0x62DE)'),
    # sensors / alarms
    0x013: ('sensors', 'debounced inputs = display flags3: b0 spout present, b1/b2 brew unit limit switches, '
                       'b3 grounds container missing, b4 tank missing, b6 tank empty (-> alarms.0) (0x625A)'),
    0x018: ('alarms', 'display flags4: b0 tank empty, b1 grounds full/missing, b2 descale, b3 filter, '
                      'b4 ground too fine, b5 beans empty, b6 fault, b7 coffee NTC fault (0x8230-0x83EE)'),
    0x019: ('alarms2', 'b4 steam NTC fault, b5 less coffee, b6 brew unit fault, b7 grounds counter overflow; '
                       'bits 5-7 go to display flags5 (0x83A4, 0x80B6)'),
    0x039: ('fault_class', 'display flags5 bits 0-1: 1/2 = brew unit fault (motor), 3 = sensor fault (0x80F6, 0x83CC)'),
    0xE85: ('fault_code', 'display flags5 bits 2-4: step of the fault recovery sequence (0x8110)'),
    # actuator demands (cleared every tick at 0x3188..0x31B4, consumed by f_7e58..f_7768)
    0x022: ('act_req', 'b0 grinder, b1 pump, b2 dose valve (amount act_dose), b3 purge valve, '
                       'b5 step done (advance), b6 step abort/condition missing (0x3188, 0x415E)'),
    0x031: ('heat1_sp', 'coffee thermoblock setpoint (compared to temp_coffee; 0 off, 0xFF full) (0x394E)'),
    0x033: ('heat2_sp', 'steam thermoblock setpoint (compared to temp_steam) (0x3878)'),
    0x035: ('heat_mode', 'heater arbitration mode 1/2/3/5 for f_7106 (0x3490)'),
    0x032: ('heat2_keepwarm', 'steam thermoblock keep-warm target in ready (0x40 / 0x30 eco) (0x3762)'),
    0x034: ('grind_dose_req', 'grinder amount request (copied from grind_dose 0xECC) (0x3B0C)'),
    0x030: ('valve_sel', 'valve selection for the dose/steam valves: 1 milk, 3 hot water/steam (0x3F9A)'),
    0x065: ('pump_amount', '16-bit (0x065/0x066) pump amount: 0xFFFF run, 0xFFFE run until condition, 0x52 short (0x3354)'),
    0x067: ('dose_amount', '16-bit (0x067/0x068) flowmeter dose for act_req.2: 0xFFFF/0xFFFE open (0x3B9A)'),
    0x0A4: ('step_timer', '16-bit (0x0A4/0x0A5) step countdown, 100 ms units (decremented in f_016a) (0x3BDC)'),
    # temperatures (ADC module owns them)
    0xE5F: ('temp_coffee', 'coffee thermoblock temperature (ADC derived, bigger = hotter; valid 0x13..0xFC) (0x83B6)'),
    0xE61: ('temp_steam', 'steam thermoblock temperature (valid 0x05..0xFC) (0x83CE)'),
    # settings (EEPROM module owns them)
    0x0C0: ('set_temperature', 'coffee temperature setting 0..3 -> table 0x1058 (76 72 6E 6A) (0x3936)'),
    0x0C1: ('set_autooff', 'auto-off setting 0..4 -> table 0x1030 (90,180,360,720,1080 x10 s) (0x4298)'),
    0x0C2: ('settings', 'b0 auto-start, b2 beep, b3 cup light, b4 energy saving, b7 filter (see f_4d16)'),
    0x0B4: ('set_hardness', 'water hardness 0..3 -> 32-bit descale threshold table 0x1020 (0x8258)'),
    # timers / counters
    0x01C: ('ticks', 'one-pass ticks: b2 10 ms, b3 100 ms, b4 1 s, b5 10 s (f_016a)'),
    0x0AA: ('autooff_timer', '16-bit (0x0AA/0x0AB) auto-off countdown, 10 s units (0x42CA)'),
    0xEEC: ('ready_idle', 'time in ready (state 7 step 0), 10 s units, saturating (0x4356)'),
    0xE65: ('eco_level', 'energy-saving level 0..4 from ready_idle via table 0x108A (0x43C8)'),
    0xEF2: ('eco_timer', 'eco keep-warm timer, 10 s units, reloaded 120 (0x4452)'),
    0x09E: ('ready_timer', '16-bit (0x09E/0x09F) ready keep-warm cycle timer, 10 ms units, reload 4500 (0x3726)'),
    0xEF8: ('test_timer', 'factory test mode timeout, seconds (60) (0x31CC)'),
    0xE88: ('test_mode', '1..5 -> display state 0x21..0x25 (see f_4d16 0x4D26) (0x31D2)'),
    0xE86: ('test_param', 'test mode parameter -> display param1 (0x3224)'),
    0x0C9: ('grounds_count', 'coffees since the grounds container was emptied; >0x8B -> grounds alarm (0x8206)'),
    0x0A8: ('grounds_timer', '16-bit (0x0A8/0x0A9) 72 h countdown (25920 x 10 s) once grounds present (0x81E6)'),
    0xEBE: ('grounds_out_timer', '100 ms: container removed >5 s resets grounds_count (0x8244)'),
    0x0C5: ('water_since_descale', '32-bit (0x0C5..0x0C8) water counter vs hardness threshold -> alarms.2 (0x828A)'),
    0x0CE: ('descale_count', 'descaling cycles done (0x82DA)'),
    0x0D6: ('water_since_filter', '32-bit (0x0D6..0x0D9) >= 100000 -> alarms.3 (0x82E2)'),
    0xED0: ('motor_run_timer', 'brew unit motor running time, 100 ms units (0x8096)'),
    0x03E: ('motor_cmd', 'brew unit motor command (1/2 move, 4/5 other) (0x8078)'),
    0x03D: ('motor_phase', 'brew unit motor phase 0..3 selects the limit switch checked (0x8116)'),
    0x06D: ('brew_measure', '16-bit (0x06D/0x06E) brew unit travel/compaction measure: <0xB4 -> recovery, '
                            '0xC9..0xF1 less coffee, >=0xF2 beans empty (0x8386)'),
    0x0BC: ('brew_ref', '16-bit (0x0BC/0x0BD) reference travel; 0 = unknown (0x812E)'),
    0x025: ('flags25', 'b0 power-up key combos pending (set in f_3146), b5 100 ms from ISR, b6/b7 process flags'),
    0x021: ('flags21', 'b1 two cups, b3 rinse pending (auto-off / hot restart), b4 pre-ground selected'),
    0x026: ('flags26', 'b3 SPI frame received, b7 turned off during warm-up'),
    0x01D: ('flags1d', 'b0 cappuccino (coffee after milk), b4 programming quantity'),
    0xECC: ('grind_dose', 'grinder dose setting copied to grind_dose_req'),
    0x0E7: ('hotwater_dose', '16-bit (0x0E7/0x0E8) hot water amount'),
    0x092: ('coffee_dose_2cups', '16-bit (0x092/0x093) water dose when flags21.1 (two cups)'),
    0x094: ('coffee_dose_1cup', '16-bit (0x094/0x095) water dose for one cup'),
    0xE83: ('cappu_phase', 'coffee phase counter of a cappuccino (0x3E62)'),
}
