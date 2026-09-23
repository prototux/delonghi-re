# Symbols for the ECAM 23.450 power board firmware (pic18dis.py).
# Merged from the per-area analyses in tools/pb_sym/*.py (docs/pb_notes/*.md).

FUNCTIONS = {
    0x0018: 'startup',
    0x0040: 'timers_init',
    0x0158: 'zc_watch_init',
    0x016a: 'timebase',
    0x04aa: 'mains_set_50hz',
    0x04c2: 'mains_set_60hz',
    0x04da: 'isr_tmr0',
    0x05ca: 'isr_tmr2',
    0x06bc: 'isr_ccp1_zc',
    0x0980: 'ee_load',
    0x0b3a: 'ee_save_task',
    0x0ce0: 'crc16',
    0x0d7a: 'ee_write',
    0x0d9a: 'ee_read',
    0x0da6: 'adc_init',
    0x0dd8: 'adc_task',
    0x0eae: 'isr_adc',
    0x0eba: 'sdiv32',
    0x0f70: 'mul32',
    0x0ff6: 'nop_hook',
    0x0ff8: 'loop_count',
    0x10c0: 'machine_control',
    0x2718: 'grind_dose_compute',
    0x2be6: 'grind_history_update',
    0x2c8e: 'bin_to_bcd',
    0x2cb8: 'menu_item_open',
    0x2dee: 'menu_item_apply',
    0x3002: 'menu_time_inc',
    0x3044: 'menu_time_dec',
    0x3096: 'milk_cycle_end',
    0x30ba: 'encoder_poll',
    0x3146: 'state_vars_init',
    0x3186: 'state_control',
    0x451a: 'recA_defaults',
    0x4598: 'recA_pack',
    0x4666: 'recA_unpack',
    0x4734: 'recB_defaults',
    0x4794: 'recB_pack',
    0x47e2: 'recB_unpack',
    0x4830: 'recC_defaults',
    0x4870: 'recC_pack',
    0x4902: 'recC_unpack',
    0x4998: 'power_task',
    0x4acc: 'comms_init',
    0x4af4: 'comms_update',
    0x4d16: 'spi_build_reply',
    0x51ea: 'svc_reply_60',
    0x5288: 'svc_reply_70',
    0x536c: 'svc_reply_80',
    0x53f2: 'svc_reply_81',
    0x545c: 'svc_read_params',
    0x554a: 'svc_reply_f0',
    0x55c8: 'svc_write_param',
    0x566e: 'pack_io_snapshot',
    0x5704: 'recipe_code',
    0x583c: 'param_get',
    0x5cdc: 'param_set',
    0x5f7a: 'checksum',
    0x5fbe: 'isr_spi',
    0x604c: 'isr_uart_tx',
    0x6076: 'isr_uart_rx',
    0x6100: 'main',
    0x6158: 'hw_init',
    0x61a8: 'inputs_clear',
    0x61b6: 'initial_state',
    0x6208: 'inputs_task',
    0x6302: 'outputs_task',
    0x636a: 'wdt_kick',
    0x6386: 'test1_nop',
    0x6388: 'test5_select',
    0x63cc: 'test2_load',
    0x64f8: 'test4_auto',
    0x65c0: 'test3_remote',
    0x6832: 'counters_update',
    0x6b6e: 'progress_update',
    0x6fce: 'isr',
    0x7106: 'heat_power_mgr',
    0x72bc: 'heatB_ctrl',
    0x7464: 'heatA_ctrl',
    0x76de: 'heatB_demand',
    0x7716: 'heatA_demand',
    0x7768: 'brew_power_adapt',
    0x7980: 'bu_motor',
    0x7b90: 'pump_ctrl',
    0x7dd2: 'grinder_ctrl',
    0x7e58: 'wait_snapshot',
    0x7e86: 'step_sequencer',
    0x803e: 'monitor_faults',
    0x84bc: 'sdiv8',
    0x8518: 'sdiv16',
    0x8562: 'mul16',
    0x857e: 'shl32',
    0x8594: 'neg32',
    0x85a8: 'mul32',
    0x85bc: 'divmod32',
    0x85d2: 'memclr',
}

LABELS = {
}

# RAM: 12 bit address -> name  (comment: source area and meaning)
RAM = {
    0x000: 'tmp0',  # [hw] compiler temporary (r000-r00e saved by ISR)
    0x00f: 'adc_last',  # [hw] last ADRESH (isr_adc 0x0EB2)
    0x010: 'adc_nsamples',  # [hw] samples accumulated per channel, 32 then average (0x0DF6)
    0x011: 'keys',  # [hw,fsm,process] display key bitmap (byte1) previous/current
    0x012: 'keys_hi',  # [hw,fsm] display byte7 & 3 (knob push) previous/current
    0x013: 'sensors',  # [comms,hw,fsm] sensor flags sent as SPI tx[6] unchanged
    0x018: 'alarms',  # [comms,fsm] alarm flags sent as SPI tx[7] (bit5 masked by rf06)
    0x019: 'alarms2',  # [comms,fsm] bits 4-7: tx[7].7 = bit4; tx[8] bits 5-7 = bits 5-7 (bit5 masked by rf05)
    0x01b: 'sysflags',  # [hw] bit0 flow pulse (RA6 edge), 1 UART toggle, 2 started (800ms after boot), 3 adc_done, 4 rotation pulse (RC1 edg
    0x01c: 'tickflags',  # [hw,fsm] bit0 10ms from TMR2, 2 10ms tick, 3 100ms, 4 1s, 5 10s, 1 UART frame ready, 6 crc scratch, 7 heater1 fire latc
    0x01d: 'flags1d',  # [fsm] b0 cappuccino (coffee after milk), b4 programming quantity
    0x020: 'heatflags',  # [hw] bit5/bit6 force re-load heater power setpoints
    0x021: 'flags21',  # [hw,fsm] bit0 motor-up gate (RB2) enable, bit5 motor-down gate (RB5), bit2 heater1 enabled (from r047.1)
    0x022: 'wait_flags',  # [units,fsm] .0 grinder .1 brew unit .2 pump .3 heater A wait, .5 step fwd, .6 step back, .7 end-of-brew counters
    0x023: 'ioflags',  # [hw] bit1 RA6 (flow) debounced level, bit2 RC1 debounced level, bit5 heater2 fire latch, bit7 heater1 alt mode, bit
    0x024: 'sensor_events',  # [hw] bit1 sensor5 went 0, bit2 sensor4 (tank) went 0
    0x025: 'flags25',  # [hw,fsm] bit3 mains freq decided, bit4 50Hz, bit5 100ms mains tick (from ZC), bit0 init
    0x026: 'flags26',  # [hw,fsm] bit0 heater2 alt mode, bit3 SPI frame complete; bits1,2,4 wake reason events (power_task)
    0x027: 'gateflags2',  # [hw] bit1 heater2 enabled (from r047.7)
    0x028: 'flags28',  # [hw,units] bit7 capture edge polarity (1=rising), bit0 display clock valid
    0x02a: 'out_loads',  # [hw,units] load requests: 0 motor down(RB5) 1 motor up(RB2) 2 heater1(RD1) 3 pump(RD4) 4 RD2 load 5 heater2(RD7) 6 RD6 7 
    0x02b: 'out_loads2',  # [hw,units] bit0 RD3 load
    0x02c: 'adc_chan',  # [hw] current ADC channel index 0..1 (table 0x1000)
    0x02d: 'keys_count',  # [hw,fsm,process] number of display keys held
    0x02e: 'pump_period',  # [hw] period for pulse mode
    0x02f: 'pump_on_cycles',  # [hw] on part for pulse mode
    0x030: 'req_valves',  # [units,fsm] valve request: bit0 EV1, bit1 EV2 (f_72bc copies to r02a.7 / r02b.0)
    0x031: 'req_heatA_sp',  # [units,fsm] coffee heater A setpoint (NTC code; 0xFF max, 0xFD=0x100, 0xFA=0xA0, 0xF8 fixed power) (f_7464, f_7716)
    0x032: 'heat2_keepwarm',  # [fsm] steam thermoblock keep-warm target in ready (0x40 / 0x30 eco) (0x3762)
    0x033: 'req_heatB_sp',  # [units,fsm] steam heater B setpoint, same encoding (f_72bc, f_76de)
    0x034: 'req_grind',  # [units,fsm] grinder run length in r01c.3 ticks, 0 aborts (f_7dd2)
    0x035: 'req_heat_mode',  # [units,fsm] heater power mode 0 A only, 1/2 alternate, 3 B only, 4/5 both (f_7106)
    0x037: 'pump_state',  # [units] pump: 0 idle, 1 running, 4 stop, 2 done (f_7b90)
    0x038: 'mstep',  # [comms,fsm] sub-state (SPI tx[2] bits 0-4)
    0x039: 'fault_class',  # [comms,fsm] brew unit fault class (SPI tx[8] bits 0-1)
    0x03a: 'heatA_state',  # [units] heater A: 0 idle, 1 heating, 2 at temp, 3 fault (f_7464)
    0x03b: 'heatB_state',  # [units] heater B: 0 idle, 1 heating, 2 at temp, 3 fault (r019.4) (f_72bc)
    0x03c: 'mstate',  # [comms,fsm] internal machine state = display state number 0x00-0x0F (SPI tx[1])
    0x03d: 'bu_zone',  # [units,fsm] brew unit zone: 0/2 entering up, 1/3 entering down, from the limit switches (f_7980)
    0x03e: 'bu_state',  # [units,fsm] brew unit: 0 idle, 1 up, 2 down, 4/5 stop with run-on, 3/6 done (f_7980)
    0x03f: 'grind_state',  # [units] grinder: 0 idle, 1 running, 4 stop, 2 done (f_7dd2)
    0x040: 'loop_tasks',  # [hw] main loop task counter checked by wdt_kick
    0x042: 'ee_flags',  # [hw] save requests: bit5 settings(B) bit1 recipes(A) bit3 counters(C); busy bits 4/0/2
    0x043: 'key_edges',  # [hw,fsm,process] newly pressed display keys
    0x044: 'keys_hi_edges',  # [hw,fsm,process] newly pressed byte7 bits
    0x045: 'sensor_edges',  # [hw] sensor bits that just became 1
    0x046: 'portd_tmp',  # [hw] PORTD read-modify-write temp
    0x047: 'portd_req',  # [hw] PORTD image requested by outputs_task (bits1..7)
    0x049: 'ee_write_timer',  # [hw] 10ms units between EEPROM byte writes (3)
    0x04a: 'zc_watchdog',  # [hw] 10ms units without ZC before mains_lost (8)
    0x04c: 'startup_timer',  # [hw] 10ms units before sysflags.2 started (80)
    0x04d: 'uart_rx_to',  # [comms] UART inter-byte timeout, 2 x 10 ms (f_6076, f_016a)
    0x04e: 'uart_tx_to',  # [comms] UART busy hold after a reply, 2 x 10 ms (f_604c, f_016a)
    0x04f: 'sensor_debounce',  # [hw] identical samples count (5)
    0x050: 'pump_pulse_cnt',  # [hw] half cycle counter for r047.4 pulse mode
    0x051: 'ac_sample_timer',  # [hw] 1ms countdown to RB0/RB1 sampling
    0x052: 'adc_start_timer',  # [hw] ms before next conversion (10)
    0x054: 'spi_resync_timer',  # [comms,hw] 1 ms countdown (TMR2 ISR f_05ca): 15 while a frame is incomplete; at 0 the SSP is re-initialised
    0x056: 'div_10ms',  # [hw] TMR2 ms counter for the 10ms tick
    0x057: 'mains_100ms_cnt',  # [hw] half cycle counter for 100ms tick
    0x058: 'zc_ticks',  # [hw] 200us ticks since ZC (saturating); motor gates pulse at 10 (2ms)
    0x059: 'gate_timer',  # [hw] 200us countdown from ZC (10): RD1/RD7 released at 3, RD2/RD4 at 0
    0x05a: 'fire_timer',  # [hw] 200us countdown to heater burst firing
    0x05b: 'bu_target_l',  # [units] latched brew unit target (f_7980)
    0x05c: 'bu_target_h',  # [units] latched brew unit target high
    0x05d: 'heatA_power',  # [hw,units] 16 bit: half cycles on per 320 (window 3.2s @50Hz)
    0x05e: 'heatA_pwr_h',  # [units] heater A power high
    0x05f: 'heater1_power_cur',  # [hw] latched heater1 power for this window
    0x061: 'heatB_power',  # [hw,units] 16 bit heater2 half cycles per 320
    0x062: 'heatB_pwr_h',  # [units] heater B power high
    0x063: 'heater2_power_cur',  # [hw] latched heater2 power
    0x065: 'req_bu_target',  # [units,fsm] brew unit target low: 0xFFFF up to upper limit, 0xFFFE down/home, else position (f_7980)
    0x066: 'req_bu_target_h',  # [units] brew unit target high
    0x067: 'req_pump_vol',  # [units,fsm] pump volume in flowmeter pulses, 0xFFFF = unlimited (f_7b90)
    0x068: 'req_pump_vol_h',  # [units] pump volume high
    0x069: 'tmp_word_l',  # [units] compiler scratch word (shared auto area): builds r065/r067 from test bytes (f_65c0@6626), also used by the service replies
    0x06a: 'tmp_word_h',  # [units] scratch word high
    0x06b: 'pump_cnt_l',  # [units] flow pulses since pump start (f_6832, compared in f_7b90)
    0x06c: 'pump_cnt_h',  # [units] flow pulse count high
    0x06d: 'bu_pos',  # [units,fsm] brew unit position in motor sensor pulses, 0 at the lower limit (f_6832@r01b.4, f_7980)
    0x06e: 'bu_pos_h',  # [units] brew unit position high
    0x06f: 'heater1_window',  # [hw] half cycle index in the 320 window
    0x071: 'heater2_window',  # [hw] heater2 half cycle index
    0x08c: 'stroke_diff',  # [process] scratch: bu_stroke_ref - last stroke (f_2be6)
    0x090: 'crc_lo',  # [hw] CRC16 result low
    0x091: 'crc_hi',  # [hw] CRC16 result high
    0x092: 'target_qty',  # [fsm,process] 16-bit (0x092/0x093) water dose when flags21.1 (two cups)
    0x094: 'target_qty_total',  # [fsm,process] 16-bit (0x094/0x095) water dose for one cup
    0x098: 'nowater_cnt_l',  # [units] pulses pumped while r018.0 (no water); pump allowed while < 0xB5 (f_6832, f_7b90)
    0x099: 'nowater_cnt_h',  # [units] high
    0x09a: 'zc_period',  # [hw] 16 bit period between capture edges (us)
    0x09e: 'ready_timer',  # [fsm] 16-bit (0x09E/0x09F) ready keep-warm cycle timer, 10 ms units, reload 4500 (0x3726)
    0x0a0: 'ccpr_now',  # [hw] CCPR1 at this edge
    0x0a2: 'uptime_100ms',  # [hw] 16 bit saturating 100 ms counter; cleared at milk step 3, it measures the milk quantity (f_10c0@1d2c)
    0x0a4: 'step_timer',  # [units,fsm,process] auto self-test step timer, reloaded 20/10/30 (f_64f8)
    0x0a5: 'test_timer_h',  # [units] high
    0x0a6: 'ccpr_prev',  # [hw] CCPR1 at previous valid edge
    0x0a8: 'grounds_timer',  # [fsm] 16-bit (0x0A8/0x0A9) 72 h countdown (25920 x 10 s) once grounds present (0x81E6)
    0x0aa: 'autooff_time',  # [hw,fsm] 16 bit, 10s units, from table 0x1030 [90,180,360,720,1080]
    0x0ac: 'adc_sum0',  # [hw] 16 bit sum of AN0 samples
    0x0ae: 'adc_sum1',  # [hw] 16 bit sum of AN1 samples
    0x0b4: 'set_hardness',  # [hw,fsm,process] record B byte0 (default 3)
    0x0b5: 'grind_hist_a',  # [hw,process] record B byte1 (default 0x15)
    0x0b6: 'set_b2',  # [hw] record B byte2 (default 0x15)
    0x0b7: 'set_b3',  # [hw] record B byte3 (default 0x50)
    0x0b8: 'grind_hist_b',  # [hw,process] record B byte4 (default 0x43)
    0x0b9: 'set_b5',  # [hw] record B byte5 (default 0x43)
    0x0ba: 'grind_hist_c',  # [hw,process] record B byte6 (default 0x36)
    0x0bb: 'set_b7',  # [hw] record B byte7 (default 0x36)
    0x0bc: 'bu_stroke_ref',  # [hw,fsm,process] record B bytes 8-9: learned empty brew unit stroke in bu_pos pulses (0 = not learned; overtravel fault at +7, f_803e@812c)
    0x0be: 'grind_center',  # [hw,process] record B byte10 (default 0x50)
    0x0bf: 'set_fault',  # [hw] record B byte11: nonzero at boot -> fault state (initial_state), default 0
    0x0c0: 'set_temperature',  # [hw,fsm,process] record B byte12 (default 1)
    0x0c1: 'set_autooff',  # [hw,fsm,process] auto-off index 0..4 (15min,30min,1h,2h,3h), default 3
    0x0c2: 'settings',  # [comms,hw,fsm,process] settings bits: 0 auto-start off, 2 beep, 3 cup light, 4 energy saving, 7 filter (param 0x3F)
    0x0c3: 'set_autostart_h',  # [hw,process] auto-start hour (binary)
    0x0c4: 'set_autostart_m',  # [hw,process] auto-start minute
    0x0c5: 'water_since_descale',  # [hw,units,fsm] 32 bit counter (image 1004680)
    0x0c9: 'grounds_count',  # [hw,units,fsm] byte counter (image 0x32)
    0x0ca: 'cnt_ca',  # [hw,units] byte counter (image 0xFE)
    0x0cb: 'stat_coffee',  # [comms,hw,units] 16 bit coffee counter (param 0x67, display stats 0x1A)
    0x0cd: 'cnt_e',  # [hw] byte (image 0)
    0x0ce: 'stat_descale',  # [comms,hw,fsm] descaling counter (param 0x69, stats 0x1B)
    0x0cf: 'stat_water',  # [comms,hw,units] 32 bit water counter, shown / 2000 (param 0x6A, stats 0x1C)
    0x0d3: 'stat_milk',  # [comms,hw,units] 16 bit milk counter (param 0x6B, stats 0x1E)
    0x0d5: 'stat_filter',  # [comms,hw,process] filter counter (param 0x6C, stats 0x1D)
    0x0d6: 'water_since_filter',  # [hw,units,fsm] 32 bit counter (image 0)
    0x0da: 'language',  # [comms,hw,process] language index (param 0x00); tx[5] bits 0-3
    0x0db: 'settings2',  # [comms,hw] param 0x01: bit1 = 24 h clock
    0x0dc: 'qty_my',  # [hw,process] record A word (default 60, image 390)
    0x0de: 'qty_espresso',  # [hw,process] default 85
    0x0e0: 'qty_standard',  # [hw,process] default 120
    0x0e2: 'qty_long',  # [hw,process] default 190
    0x0e4: 'qty_extralong',  # [hw,process] default 250
    0x0e6: 'qty5_b',  # [hw] byte, default 150
    0x0e7: 'qty_hotwater',  # [hw,fsm,process] default 700
    0x0e9: 'qty_cappu_coffee',  # [hw,process] default 160
    0x0eb: 'qty_milk_0',  # [hw,process] default 160
    0x0ed: 'qty9',  # [hw] default 120
    0x0ef: 'qty_milk_1',  # [hw,process] default 180
    0x0f1: 'qty11',  # [hw] default 120
    0x0f3: 'qty_milk_2',  # [hw,process] default 450
    0x0f5: 'scratch_f5',  # compiler scratch (shared auto area): last stroke r06d/e for f_2be6, comms key count, EEPROM locals
    0x0f6: 'tx_param1',  # [comms] scratch: SPI tx[2] (f_4d16); also generic temp
    0x0f7: 'tx_state',  # [comms] scratch: SPI tx[1] machine state being built (f_4d16); also generic temp
    0x0f8: 'tx_param2',  # [comms] scratch: SPI tx[3] (f_4d16); also generic temp
    0xe4c: 'io_snapshot',  # [comms] 7 bytes 0xE4C..0xE52: input/output bits packed for UART cmd 0x60/0x80 (f_566e)
    0xe53: 'grind_avg',  # [process] weighted average of the histories (f_2718)
    0xe54: 'milk_prog_slot',  # [process] milk quantity slot 0/0x40/0x80 (f_10c0 milk)
    0xe55: 'cups',  # [comms,process] cups of the current drink: 0 = one, 1 = two (tx param1 bit5)
    0xe56: 'drink',  # [comms,process] selected drink 0,2,4,6,8 (tx param2 bits 1-3)
    0xe57: 'grind_1cup',  # [process] grind/dose param 1 cup from taste: 0x28,0x2f,0x38,0x3e,0x44 (f_10c0@1810, used f_2718@2828)
    0xe58: 'grind_2cup',  # [process] grind/dose param 2 cups from taste: 0x3f,0x43,0x48,0x4b,0x4f (f_10c0@18c8, used f_2718@28d8)
    0xe59: 'flow_win',  # [units] flow pulses in the current f_7768 window (f_6832)
    0xe5a: 'enc_step',  # [process] encoder step threshold, = 1 (f_30ba)
    0xe5b: 'test_cmd',  # [comms,units] 4 bytes 0xE5B..0xE5E written by UART cmd 0x80 (remote load test)
    0xe5c: 'test_arg0',  # [units] UART 0x80 b1 (setpoint argument) (f_65c0)
    0xe5d: 'test_arg1',  # [units] UART 0x80 b2 (high byte of word argument) (f_65c0)
    0xe5e: 'test_arg2',  # [units] UART 0x80 b3 (low byte / byte argument) (f_65c0)
    0xe5f: 'temp_coffee',  # [hw,fsm] 255 - avg(AN1) (coffee thermoblock NTC, used by heater1 control f_7464)
    0xe60: 'heatA_regul',  # [units] 0 = brew feed-forward power, 1 = closed-loop regulation (f_7464)
    0xe61: 'temp_steam',  # [hw,fsm] 255 - avg(AN0) (steam/2nd thermoblock NTC, used by heater2 control f_72bc)
    0xe62: 'ee_idx',  # [hw] byte index in record being saved
    0xe63: 'taste',  # [comms,process] taste field already shifted (tx param2 bits 4-6), 0 while r021.4
    0xe65: 'eco_level',  # [fsm] energy-saving level 0..4 from ready_idle via table 0x108A (0x43C8)
    0xe66: 'ee_copy',  # [hw] copy index 0/1 (load and save)
    0xe67: 'brew_pwr_idx',  # [units] heater A power index 0..9 during brewing, table 0x1044 (f_7768)
    0xe68: 'flow_avg',  # [units] average flow over 3 windows = re69/3 (f_7768)
    0xe69: 'flow_sum',  # [units] sum of flow windows (f_7768)
    0xe6a: 'lang_preview',  # [process] language shown during first start, cycles modulo redf (f_10c0 state 0x0d)
    0xe6b: 'menu_level',  # [process] menu level 0 = list, >0 inside an item
    0xe6c: 'menu_item',  # [comms,process] menu item index 0..15 when r026.5 (menu) is set; mapped to states 0x10-0x29
    0xe70: 'disp_eecfg',  # [comms] display EEPROM config byte (SPI rx[8], 0x65)
    0xe71: 'test_echo',  # [comms,units] SPI tx[3] in test mode 3 (electric test step)
    0xe72: 'saved_mstep',  # [fsm,process] mstep saved with saved_mstate, restored at 0x41AE
    0xe73: 'saved_mstate',  # [fsm,process] mstate saved when entering descaling / brew unit recovery (0x81CC, 0x402C)
    0xe76: 'sensor_sample',  # [hw] previous raw sensor sample
    0xe79: 'progress',  # [comms,units] progress 0..100 (SPI tx[9])
    0xe7a: 'flow_watchdog',  # [units] flow watchdog: 100 when off, 30 once >= 13 pulses (f_7b90)
    0xe7b: 'ac_sample_delay',  # [hw] ms after ZC to sample RB0/RB1 (5 @50Hz, 4 @60Hz)
    0xe7c: 'halfcycles_100ms',  # [hw] half cycles per 100ms (10 / 12)
    0xe7d: 'burst_fire_delay',  # [hw] TMR0 ticks after ZC to fire heaters before next ZC (45=9ms / 38=7.6ms)
    0xe7f: 'wait_snap',  # [units] snapshot of wait flags: .0 grind .1 BU .2 pump .3 A .4 B(r023.3) (f_7e58)
    0xe80: 'disp_keys',  # [comms] key bitmap from the display (SPI rx[1]), cleared on link loss
    0xe81: 'disp_keys_hi',  # [comms] SPI rx[7] & 3 (bit1 = encoder push), cleared on link loss
    0xe83: 'cappu_phase',  # [units,fsm,process] incremented when r01d.7 & BU done or r01d.6 & grinder done (f_7e86)
    0xe84: 'brew_phase',  # [process] coffee dispatcher: 0 wait key, 1 compute recipe, 2 brewing, 3 second cup (f_10c0@1698, INCF @170e/@1768, DECF 
    0xe85: 'fault_step',  # [comms,fsm,process] brew unit fault sub-code (SPI tx[8] bits 2-4)
    0xe86: 'test_step',  # [comms,units,fsm] SPI tx[2] in test modes
    0xe88: 'test_mode',  # [comms,fsm] test mode number: display state = 0x20 + test_mode (1..5)
    0xe89: 'standby_flag',  # [process] set to 1 in standby
    0xe8a: 'wake_reason',  # [hw] 1 ON key, 2 auto-start time, 3 other
    0xe8b: 'disp_id',  # [comms] SPI rx[3] (constant 0x14 from the display)
    0xe8e: 'disp_hour',  # [comms] RTC hour from the display, binary (SPI rx[4])
    0xe8f: 'disp_min',  # [comms] RTC minute (SPI rx[5])
    0xe90: 'disp_sec',  # [comms] RTC second (SPI rx[6])
    0xe91: 'uart_dest',  # [comms] request byte 3: 0x0F = power board, 0xF0 = display-info block (cmd 0x95)
    0xe92: 'ac_inputs',  # [hw] RB0|RB1 sampled at re7b ms after ZC
    0xe93: 'ac_toggle',  # [hw] RB0/RB1 changed since last half cycle (AC present)
    0xe96: 'bu_delay_down',  # [units] start delay before motor down (f_7980)
    0xe97: 'bu_delay_up',  # [units] start delay before motor up (f_7980)
    0xe99: 'progress_hold',  # [units] progress refresh hold timer = 50 (f_6b6e)
    0xe9a: 'ready_countdown',  # [process] 100, counts down while r013.5; cleaning allowed at 0 (f_10c0 ready)
    0xe9b: 'heatB_hold',  # [units] heater B hold timer = 10 while heating (f_7106)
    0xe9c: 'heatA_hold',  # [units] heater A hold timer = 10 while heating (f_7106)
    0xe9e: 'bu_softstart',  # [units] soft start, gates r02a.6 full power (f_7980)
    0xe9f: 'bu_runon',  # [units] run-on after stop (f_7980)
    0xea0: 'wake_timer',  # [hw] 100ms units before power-up after a wake event (30)
    0xea2: 'zc_cnt50',  # [hw] consecutive half periods > 9171us
    0xea3: 'zc_cnt60',  # [hw] consecutive half periods < 9171us
    0xea5: 'disp_enc',  # [comms] encoder position from the display (SPI rx[2])
    0xea6: 'enc_last',  # [process] last encoder position used by f_30ba; delta vs disp_enc (0xEA5)
    0xea7: 'heatA_req',  # [hw,units] windows of alternate firing left
    0xea8: 'heatB_req',  # [hw,units] idem heater2
    0xea9: 'spi_idx',  # [comms] SPI byte index (f_5fbe), cleared by f_4af4 and on SSPOV/resync
    0xeaa: 'spi_last',  # [comms] last SPI index (=10), set when 0xB0 received (f_5fbe@5ff2)
    0xeab: 'zc_valid_cnt',  # [hw] edges counted before forcing 50Hz (199)
    0xeac: 'uart_rx_idx',  # [comms] UART rx index (f_6076)
    0xead: 'uart_rx_len',  # [comms] UART rx length byte (< 0x19)
    0xeae: 'uart_tx_idx',  # [comms] UART tx index (f_604c)
    0xeaf: 'uart_tx_len',  # [comms] UART tx length (len+1)
    0xeb0: 'zc_lost_cnt',  # [hw] bad-period counter before mains_lost (5)
    0xeb1: 'zc_ok_cnt',  # [hw] good periods needed to clear mains_lost (5)
    0xeb6: 'clean_ticks',  # [process] cleaning tick counter: >0xc7 -> sub 3, >0x31 clears rf00 (f_10c0 state 0x0c)
    0xeb7: 'preheat_delay',  # [process] 20: preheat delay before brewing with energy saving (f_10c0 re84==0)
    0xebc: 'enc_activity',  # [comms] set to 30 when the display encoder position changes (f_4af4@4b9a)
    0xebe: 'grounds_out_timer',  # [fsm] 100 ms: container removed >5 s resets grounds_count (0x8244)
    0xebf: 'milk_end_timer',  # [process] 30 at milk sub 5 (f_10c0)
    0xec0: 'ee_save_req_c0',  # [comms,process] set to 5 when a parameter 0x00-0x0E is written (save request, block 0xDA..)
    0xec1: 'flow_win_timer',  # [units] f_7768 window, 20 r01c.3 ticks
    0xec2: 'flow_start_delay',  # [units] f_7768 start delay, 60 ticks
    0xec3: 'ee_save_req_c3',  # [comms,process] set to 5 when a parameter 0x32-0x41 is written (save request, block 0xB4..)
    0xec6: 'lang_cycle_timer',  # [process] 30-tick timer for the language preview (f_10c0 state 0x0d)
    0xec7: 'lang_cycle_timer2',  # [process] 30-tick timer paired with rec6 (f_10c0 state 0x0d)
    0xec8: 'flow_watchdog2',  # [units] companion of re7a (f_7b90)
    0xec9: 'bu_idle',  # [units] =40 when motor off (f_7980)
    0xeca: 'active_timer',  # [hw] 100ms units the main relay stays on (reloaded 100)
    0xecc: 'grind_dose',  # [fsm,process] grinder dose setting copied to grind_dose_req
    0xecd: 'grind_dose_hi',  # [process] upper bound for recc (f_2718)
    0xece: 'grind_dose_lo',  # [process] lower bound for recc (f_2718)
    0xed0: 'motor_run_timer',  # [fsm] brew unit motor running time, 100 ms units (0x8096)
    0xed1: 'cappu_toggle_win',  # [process] window (0x14) where pressing cappu again toggles r01d.0 (f_10c0 milk)
    0xed2: 'grind_ticks',  # [units] grinder ticks elapsed (f_7dd2)
    0xed4: 'long_press_ms',  # [process] long-press timer 0x50 on a cup key; expiry with key held -> r028.2 programming mode (f_10c0 re84==0)
    0xed5: 'prog_press_timer',  # [process] 0x50 long-press timer for milk/hot water programming (f_10c0 milk sub1, hot water sub1)
    0xed7: 'link_timeout',  # [comms,hw] display link watchdog: 50 on each valid frame, -1 per r01c.3 tick; at 0 keys are cleared (f_4af4@4be4)
    0xedc: 'test_key_sel',  # [units] load-test selection guard, 0 lets keys act (f_63cc)
    0xede: 'temp_coffee_slope',  # [hw,units] temp_an1 change over 2 s
    0xedf: 'disp_languages',  # [comms] number of languages in the display EEPROM (SPI rx[9])
    0xee0: 'menu_value_max',  # [process] max of menu_value for the item (f_2cb8)
    0xee3: 'ac_inputs_prev',  # [hw] previous ac_inputs
    0xee4: 'temp_an1_prev',  # [hw] temp_an1 2 s ago
    0xee6: 'heatA_last_sp',  # [units] previous heater A setpoint (r020.6 = was 0xFF) (f_7464)
    0xee7: 'heatB_last_sp',  # [units] previous heater B setpoint (r020.5 = was 0xFF) (f_72bc)
    0xee8: 'div_10s',  # [hw] seconds per 10 s tick
    0xee9: 'div_1s',  # [hw] 100ms ticks per second
    0xeec: 'ready_idle',  # [fsm] time in ready (state 7 step 0), 10 s units, saturating (0x4356)
    0xef2: 'eco_timer',  # [fsm] eco keep-warm timer, 10 s units, reloaded 120 (0x4452)
    0xef4: 'descale_timer',  # [process] 30 at descaling start
    0xef5: 'bu_idle_delay',  # [units] idle delay (f_7980)
    0xef6: 'energy_timer',  # [process] 60, ticks down while idle in ready; 0 = energy saving active (flags1.6)
    0xef8: 'test_timer',  # [comms,fsm] test mode active while != 0; UART cmd 0x80 sets 5
    0xefd: 'menu_timeout',  # [process] 120, exits the menu at 0
    0xf00: 'milk_timer',  # [process] 120 at milk sub 3; also flags1.5 (f_10c0)
    0xf02: 'activity_timer',  # [process] 120 whenever a key is held
    0xf05: 'less_coffee_timer',  # [process] 30-tick hold of alarms2.5 LESS COFFEE (f_10c0 sub 0x0e, f_4d16)
    0xf06: 'beans_alarm_timer',  # [process] 30-tick hold of alarms.5 no coffee (f_10c0 sub 0x0e, f_4d16)
    0xf0a: 'menu_value',  # [comms,process] value being edited in the menu (SPI tx[2]) / stats sub-page
    0xf0b: 'menu_minutes',  # [comms,process] second menu value (minutes for clock items, SPI tx[3] as BCD)
    0xf0c: 'ee_factory',  # [comms,hw] 10 bytes: data EEPROM 0xF6..0xFF copied at boot (f_0980@0b14), read by UART cmd 0xF0
    0xf16: 'spi_rx',  # [comms] SPI frame from the display, 11 bytes 0xF16..0xF20 (f_5fbe)
    0xf21: 'spi_tx',  # [comms] SPI frame to the display, 11 bytes 0xF21..0xF2B (built by f_4d16)
    0xf2c: 'uart_buf',  # [comms] UART frame buffer (rx and tx), 0x0A header in, 0xA0 header out
    0xf45: 'ee_buf',  # [hw] record buffer (29 bytes)
}

# (first, last, name) flash byte ranges holding constant data
DATA_RANGES = [
    (0x1000, 0x10bf, 'const tables (see docs/powerboard.md)'),
]
