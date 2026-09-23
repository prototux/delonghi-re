# Power board: hardware, drivers, EEPROM (area "hw")

Symbols: `tools/pb_sym/hw.py`. All addresses are in the v1.0 image.

## Clock, config, timers

- **Configuration:**
  - CONFIG1H=0x08: INTIO67 (internal oscillator, RA6/RA7 are I/O), no FCMEN/IESO.
  - CONFIG2L=0x16: power-up timer on, BOR on.
  - CONFIG2H=0x0F: WDT on, 1:128 postscaler (≈512 ms).
  - CONFIG3H=0x01: MCLR off (RE3 is an input), PORTB digital at reset.
  - CONFIG4L=0x81: LVP off, no extended instruction set.
- `hw_init` (0x6158) sets OSCCON=0x72 (8 MHz internal) and OSCTUNE=0x80 (INTSRC; the PLL bit is 0x40, so the PLL is off). That gives **Fosc = 8 MHz, Fcy = 2 MHz**. The capture thresholds confirm it: 10000 µs = one 50 Hz half period at 1 MHz.
- **TMR0** (T0CON=0xC0: 8 bit, 1:2, 1 MHz): the ISR adds 0x38 to TMR0L, so it fires every **200 µs** (`isr_tmr0`, 0x04DA).
- **TMR1** (T1CON=0x10: 1:2, 1 MHz): free-running time base for the **CCP1 capture** on RC2, the mains zero-cross (ZC).
- **TMR2** (T2CON=0x09 1:4 pre / 1:2 post, PR2=249): **1 ms** interrupt (`isr_tmr2`, 0x05CA).
- **TMR3** is disabled. `isr` has no low-priority vector: IPEN=0 and the reset jumps to 0x0018.
- **Watchdog:** `wdt_kick` (0x636A) only does CLRWDT when the main loop ran exactly the expected number of tasks (`loop_tasks` == 4 before the startup delay, 10 after). Each task does `loop_tasks++`, so a stuck task resets the chip after ~0.5 s.

## Time base (`timebase` 0x016A, called every main loop pass)

| flag | source | period |
|---|---|---|
| tickflags.0 → tickflags.2 | TMR2, `div_10ms` | 10 ms |
| mainsflags.5 → tickflags.3 | ZC: 10 half cycles (50 Hz) / 12 (60 Hz) | 100 ms, mains synchronous |
| tickflags.4 | 10 × 100 ms | 1 s |
| tickflags.5 | 10 × 1 s | 10 s |
| sysflags.2 "started" | `startup_timer` 80 × 10 ms | set once, 0.8 s after boot; the state machine only runs after that |

Each tick decrements a group of saturating countdowns. Their meaning belongs to the other areas; the group decides the unit:

- **10 ms:** r049, re9b..re9f, re96, re97, re99, r09c:r09d (16 bit).
- **100 ms:** reda, r0a4:r0a5 (16 bit), rec8 (flow timeout), rec9 (rotation timeout), red8, rebb, reb8, reb5, rec6, redc, **red7 = link_timeout** (reloaded to 50 on every valid SPI frame, so 5 s), red5, reba, reb9, rec2, reb4, red6, rec4, rebd, reb7, red3, red1. Also `uptime_100ms` (r0a2:a3), which counts up and saturates.
- **1 s:** rf02, rf03, rf07, ref5, ref9, refd, rf04, rf05, rf06, refc, refb, rf01, ref7, refa.
- **10 s:** ref3, reed, reea, reee, ref0.

Other checks run every 10 ms whether or not the machine has started:
- **Zero-cross watchdog `zc_watchdog`:** 8 × 10 ms without a ZC sets **sysflags.5 mains_lost**.
- **UART RX timeout:** `r04d`.
- **UART TX guard:** `r04e` clears sysflags.7.

## Pin map

TRIS at init: A=0xEF, B=0xD3, C=0x9F, D=0x01, E=0x0F. PORT at init: B=0x2C (RB2, RB3, RB5 high), C=0x40.

| Pin | Dir | Function | Evidence |
|---|---|---|---|
| RA0/AN0 | in | NTC 2 → `temp_an0` (steam / 2nd thermoblock) | ADC table 0x1000 = {0x00, 0x04}; used by heater 2 control f_72bc |
| RA1/AN1 | in | NTC 1 → `temp_an1` (coffee thermoblock) | used by heater 1 control f_7464, slope `temp_an1_slope` |
| RA2, RA3 | in | unused (digital) | ADCON1=0x0D |
| RA4 | out | unused, low | only cleared |
| RA5 | in | switch → sensors.5 (inverted) | inputs_task 0x6258 |
| RA6 | in | **flowmeter**: debounced 3 ms in isr_tmr2, each rising edge sets sysflags.0 and reloads rec8 | counted in f_6832 (clears sysflags.0, red9=30) |
| RA7 | in | **brew unit top limit switch** → sensors.1 (inverted) | motor code f_7980 stops the up move on sensors.1; display "LIMIT SWITCH UP" = flags3.1 |
| RB0 | in | AC-sensed switch → sensors.3 (display: **grounds container missing**) | sampled `ac_sample_delay` ms after each ZC; "active" = level changed since the previous half cycle |
| RB1 | in | AC-sensed switch → sensors.4 (display: **water tank missing**) | same |
| RB2 | out | **brew unit motor UP** triac gate (active low 200 µs pulse, 2 ms after each ZC) | isr_tmr0: `BCF PORTB,2` when zc_ticks==10 and gateflags.0; loads.1 set by f_7980 until sensors.1 |
| RB3 | out | **main relay / load and sensor supply** (high = on) | outputs_task: high while active_timer or wake_timer ≠ 0; inputs frozen when off; cleared in standby |
| RB4 | in | switch → sensors.6 (inverted) | inputs_task |
| RB5 | out | **brew unit motor DOWN** triac gate (as RB2) | loads.0, f_7980 until sensors.2 |
| RB6, RB7 | in | ICSP, unused | |
| RC0 | in | unused | |
| RC1 | in | **rotation pulse sensor**: debounced 3 ms, rising edge sets sysflags.4 and rec9=30 (3 s stall timeout) | counted in r06d:r06e by f_6832 while ioflags.0; the count is cleared by the motor code at bottom. Probably the grinder dosing sensor |
| RC2/CCP1 | in | **mains zero-cross** (both edges, TMR1 capture) | isr_ccp1_zc |
| RC3/SCK, RC4/SDI, RC5/SDO | SPI | slave to the display (SSPCON1=0x15: slave, no SS, CKP=1) | comms area |
| RC6/TX, RC7/RX | UART | 19200 baud (BRG16, SPBRG=103, BRGH), TX9 with 9th bit 1 | f_4acc, comms area |
| RD0 | in | unused input (always preserved) | |
| RD1 | out | **heater 1 triac** (coffee thermoblock), burst firing | power `heater1_power` set by f_7464 with temp_an1 |
| RD2 | out | triac load, gate 0–2 ms of each half cycle (loads.4) | f_7dd2: timed by r034, blocked by sensors.3/4 (valve or grinder?) |
| RD3 | out | static load (loads2.0) | set by f_72bc (steam path, valve?) |
| RD4 | out | **pump** triac, gate 0–2 ms each half cycle (loads.3); optional pulse mode (pump_period/pump_on_cycles) | f_7b90 runs it until a quantity target (r067:r068) |
| RD5 | out | static load (loads.7) | f_72bc (steam path) |
| RD6 | out | static load (loads.6) | f_7980: switched on with the motor after the re9e delay (motor aux relay/brake?) |
| RD7 | out | **heater 2 triac**, burst firing | `heater2_power` set by f_72bc with temp_an0 |
| RE0 | in | **water spout / hot water nozzle in place** → sensors.0 (inverted: present = RE0 low) | display: flags3.0 spout present |
| RE1 | in | **brew unit bottom limit switch** → sensors.2 | f_7980 stops the down move on sensors.2 |
| RE2 | in | unused | |
| RE3 | in | MCLR pin as input, unused | |

`sensors` (r013) is the byte sent to the display as **pb_flags3**.

## Zero-cross, 50/60 Hz, triac timing

`isr_ccp1_zc` (0x06BC) runs on every capture edge; CCP1CON alternates 5/4 so both edges are captured.

- `zc_period` = time since the last valid edge, in µs.
- **Valid** half periods are 6600–12000 µs.
- **Frequency detection:** until the frequency is known (mainsflags.3), periods > 9171 µs count for 50 Hz and shorter ones for 60 Hz. 30 consecutive → `mains_set_50hz`/`mains_set_60hz`; 199 edges without a decision force 50 Hz.
  - 50 Hz: ac_sample_delay=5, halfcycles_100ms=10, burst_fire_delay=45.
  - 60 Hz: 4, 12, 38.
- **Bad periods:** with the frequency known, a period outside the window for that frequency (8000–12000 at 50 Hz, 6600–10000 at 60 Hz) counts `zc_lost_cnt`; after 5, sysflags.5 **mains_lost** is set. 5 good periods clear it.

On each valid ZC:
1. reload `ac_sample_timer`, `fire_timer`, `zc_watchdog`=8, and zc_ticks=0 on the rising edge;
2. copy loads to gate flags (gateflags.2 heater 1, gateflags2.1 heater 2);
3. advance the heater windows;
4. write **PORTD = RD0 | (portd_req & 0x7D) | RD1 if tickflags.7 | RD7 if ioflags.5**;
5. set `gate_timer`=10.

`isr_tmr0` (every 200 µs):
- **gate_timer** counts down: at 3 (1.4 ms after ZC) RD1/RD7 are released; at 0 (2 ms) RD1, RD2, RD4, RD7 are released. RD3, RD5, RD6 stay as set, so those are relays or opto-triacs.
  - The **pump (RD4) and RD2** therefore get a 2 ms gate at the start of every half cycle they are requested (full conduction).
- **zc_ticks** counts from the rising ZC. RB2/RB5 (motor up/down, when gateflags.0/.5) are pulled low for one tick when zc_ticks==10, which fires a phase-angle triac 2 ms after ZC.
- **fire_timer** (45 or 38 ticks, i.e. 9 ms or 7.6 ms): just before the next ZC it decides heater firing.
  - **Heater 1:** if enabled and (`heater1_boost`==0 or heater1_power_cur ≥ heater1_window), or with ioflags.7 set, it sets RD1 now and latches tickflags.7. The ZC handler then keeps RD1 on through the ZC until 1.4 ms: **burst (whole half cycle) control**.
  - **Heater 2:** same with RD7 / ioflags.5 / commflags.0.
- **Heater power:** half cycles on per window of **320 half cycles** (`heater*_window` wraps at 0x140, i.e. 3.2 s at 50 Hz).
  - The power `heaterN_power` (16 bit 0..320) is latched in `heaterN_power_cur` at the start of each window. Values 0x40 / 0xA0 / 0x140 appear in the code.
  - Table 0x1044 holds the 32..320 levels in steps of 32 (10 %..100 %).

## ADC (`adc_init` 0x0DA6, `isr_adc` 0x0EAE, `adc_task` 0x0DD8)

- 8-bit results (left justified, only ADRESH is used); ADCON2=0x11.
- **Sequence:** the conversion starts 10 ms (TMR2) after the channel switch; the result goes to r00f and sets sysflags.3.
- **Averaging:** adc_task adds the sample to `adc_sum[ch]` and alternates AN0/AN1. After 32 samples per channel (≈0.64 s) it computes `temp_an0 = 255 - sum0/32` and `temp_an1 = 255 - sum1/32`. A higher value means hotter (NTC to ground).
- Every 20 × 100 ms: `temp_an1_slope = temp_an1 - temp_an1_prev` (heating rate of the coffee thermoblock).
- There is no conversion to °C: the rest of the firmware compares raw 8-bit values. Candidate threshold tables are at 0x1058–0x1097 (descending sequences 0x76..0x12, 0x31..0x00, 0x67..0x00…), used by the state machine / process areas.

## Inputs (`inputs_task` 0x6208, each loop)

- **Display keys:**
  - `key_edges` = display keys newly pressed (re80 & ~keys);
  - `keys_hi_edges` the same for byte 7 (knob push);
  - `keys_count` = number of held keys among bits 0-4,6,7 of keys and bit1 of keys_hi.
- **Switches** (every 10 ms, when the relay is on, i.e. active_timer or wake_timer ≠ 0):
  1. sample RE0, RA7, RE1, RA5, RB4 plus the AC bits;
  2. XOR 0x63;
  3. a new image must be identical 5 times before it replaces `sensors`;
  4. `sensor_edges` = bits that rose; sensor_events.1/.2 = bits 5/4 fell.
  With the relay off, only the AC bits 3/4 are refreshed.

## Outputs (`outputs_task` 0x6302, every loop after start)

With interrupts off, it maps the load request bits (set by the state machine, cleared each pass by f_3186) to hardware:

```
loads.6 -> RD6   loads.2 -> RD1 (heater1)  loads.4 -> RD2   loads.3 -> RD4 (pump)
loads.7 -> RD5   loads2.0 -> RD3           loads.5 -> RD7 (heater2)
loads.1 -> gateflags.0 (RB2 motor up)      loads.0 -> gateflags.5 (RB5 motor down)
```

The PORTD values are only written at the next ZC (`portd_req`), except when **mains_lost**: PORTD is cleared at once, keeping RD0.
RB3 = 1 while `active_timer` or `wake_timer` ≠ 0.

## Power management (`power_task` 0x4998)

- **Standby** is `active_timer`=0 (RB3 off).
- **Wake:**
  - the ON/OFF key alone gives wake_reason=1;
  - **auto-start** (set_options.0 clear) gives wake_reason=2: in state 0 / sub 2, when the display clock (re8e/re8f) equals set_autostart_h/m and seconds < 11;
  - wake_timer then gets 30 × 100 ms. When it expires, active_timer=100 and commflags.4/2/1 is set for reason 1/2/3.
- **While active**, active_timer is reloaded to 100 unless the machine is in state 0 / sub 2 with no activity (r042 EEPROM save bits, r018.6, ref8). When it counts down to 0 (100 ms ticks), PORTA/B/C/E are reset (RB3 off): standby.
- `autooff_time` (r0aa:ab, 10 s units) comes from table 0x1030 indexed by `set_autooff`: 90/180/360/720/1080 = 15 min/30 min/1 h/2 h/3 h (the display's auto-off menu).

## EEPROM (1 KiB, only 0x00–0x8D and 0xF6–0xFF used)

- **Storage:** three records, each stored **twice**, with a CRC-16 in the last 2 bytes (high, low).
  - **CRC** (`crc16` 0x0CE0): poly 0x8005, MSB first, register initialised to 0xAA<<8 | byte0, 16 zero bits appended. It was verified on all six copies in the image.
- **Load** (`ee_load` 0x0980): copy 0, then copy 1; the first valid copy is unpacked, otherwise defaults are used.
- **Save** (`ee_save_task` 0x0B3A): requested with ee_flags bits 5/1/3. It needs mains present, writes one byte every 30 ms and does both copies.
- **0xF6–0xFF** (10 bytes, erased in the image) are copied read-only to 0xF0C and sent by a UART service command (f_554a).

**Record B, settings** (0x00 and 0x13, 17 + 2 bytes). Image: `00 11 11 50 23 23 38 38 00 f8 7c 00 03 01 1d 00 00 | a1 39`

| byte | var | image | default | meaning |
|---|---|---|---|---|
| 0 | set_b0 | 0x00 | 3 | ? (level setting, 0..3: temperature or hardness) |
| 1..7 | set_b1..b7 | 11 11 50 23 23 38 38 | 15 15 50 43 43 36 36 | pairs of values (calibration/levels?) |
| 8-9 | set_w8 | 0x00F8 | 0 | 16 bit |
| 10 | set_b10 | 0x7C | 0x50 | |
| 11 | set_fault | 0x00 | 0 | non-zero at boot → fault state (initial_state sets r019.6, r039=1) |
| 12 | set_b12 | 0x03 | 1 | ? (level 0..3) |
| 13 | set_autooff | 0x01 | 3 | auto-off index |
| 14 | set_options | 0x1D | 0x0D/0x1D | flags1 bits: 0 auto-start off, 2 beep, 3 cup light, 4 energy saving, 7 filter |
| 15,16 | set_autostart_h/m | 0,0 | 0,0 | auto-start time |

**Record A, language and quantities** (0x26 and 0x43, 27 + 2 bytes; words are big endian in EEPROM). Image: `50 02 0186 0055 0078 00be 00fa 96 01df 00de 0161 0078 00b4 0078 01c2 | b7 b5`

| field | image | default | note |
|---|---|---|---|
| opt_lang | 0x50 | 0x52 | bits0-3 language (English = 0), bit4 language chosen (else first-start state 0x0D), bit6 ? |
| opt_misc | 0x02 | 0x03 | bit1 24 h clock, bit0 first state 0x0E |
| qty0..qty4 | 390, 85, 120, 190, 250 | 60, 85, 120, 190, 250 | likely coffee quantities in flowmeter pulses: my coffee (user-programmed to 390), espresso, standard, long, extra long |
| qty5_b | 150 | 150 | byte |
| qty6..qty12 | 479, 222, 353, 120, 180, 120, 450 | 700, 160, 160, 120, 180, 120, 450 | other quantities (hot water, milk, cappuccino…, left to the process area) |

**Record C, counters** (0x60 and 0x77, 21 + 2 bytes). Image: `0f5488 32 fe 23 2bba 00 22 00317014 01ed 00 00000000 | 3c 42`

| field | image value |
|---|---|
| cnt32_a (24 bit in EEPROM) | 1 004 680 |
| cnt_b | 0x32 |
| cnt_c | 0xFE |
| byte 5 | not loaded |
| cnt16_d | 11 194 |
| cnt_e | 0 |
| cnt_f | 0x22 |
| cnt32_g | 3 239 956 |
| cnt16_h | 493 |
| cnt_i | 0 |
| cnt32_j | 0 |

These are the statistics shown in the menus (total coffees, water, descaling, filter, milk) plus pulse totals; the mapping belongs to the comms/state areas.

## Runtime helpers

| addr | name | operation |
|---|---|---|
| 0x85D2 | memclr | clear [FSR0, FSR1) |
| 0x8562 | mul16 | r001:r000 × r003:r002 → r005:r004 |
| 0x857E | shl32 | r003..r000 <<= W |
| 0x8594 | neg32 | two's complement r003..r000 |
| 0x85A8 | mul32 | 32×32 → 32 |
| 0x85BC | divmod32 | 32-bit divide |
| 0x0EBA | sdiv32 | sign wrapper around divmod32 |
| 0x84BC | sdiv8 | signed 8-bit divide |
| 0x8518 | sdiv16 | signed 16-bit divide |

## Other constant data (0x1000–0x10BF)

| address | content |
|---|---|
| 0x1000 | ADC channel table `00 04` |
| 0x1002 | `00 05 0a 19 28 37 46 55 64 73`, `00 05 07 0a 0f 15 23 33 4f 6d`, `00 05 07 0a 0f 1c 2b 3c 4f 6d` (lookup curves) |
| 0x101C | 32-bit constants 5 000 000, 2 600 000, 1 400 000, 800 000 |
| 0x1030 | auto-off table |
| 0x103A | `02 03 04 06 08 0a 0c 0e 10 12` |
| 0x1044 | heater power words 32..320 |
| 0x1058–0x1097 | temperature-like thresholds |
| 0x109E | 16-bit code addresses (0x3AF4…0x3BE4): computed-goto table of f_3186 |

## Open points

- The exact loads on RD2/RD3/RD5/RD6, and whether RC1 counts the grinder or the brew unit motor. Answering this needs the state machine areas (f_7dd2, f_72bc, f_7980, f_6832).
- The meaning of set_b0..b12 and qty5..qty12.
- The real NTC curve: there is no conversion table in the firmware, only raw thresholds.
