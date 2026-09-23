# ECAM 23.450 power board firmware (PIC18F4525)

This document reverse engineers `files/machines/ECAM_23.450/power_board_unknown_v1.0_firmware.bin`. It is the reference for building a replacement power board, or a display board that talks to the original one.

Sources and tools:
- **Disassembler:** `tools/pic18dis.py`, with the symbols in `tools/pb_symbols.py`. The names used below are the ones in that file.
- **C reconstruction:** `pb_reimplem/`. It is checked call by call against the original binary: 13,587 recorded calls replay with identical RAM and output SFRs (see `pb_reimplem/README.md`). When this document and the C disagree, the C is right.
- **Area notes:** `docs/pb_notes/*.md` are the detailed notes of each area. They contain a few errors, listed in [Corrections to the area notes](#corrections-to-the-area-notes).
- **Emulator check:** the firmware runs in the emulator (`emulator/`, "real firmware" mode) against a physical model of the machine. Every behaviour marked *(emulated)* below was observed there.

The display board side of the link is in `protocol.md`.

## Chip, image, configuration

- **Chip:** PIC18F4525.
  - 48 KB flash; the code uses 0x0000–0x87FF.
  - 3968 B of RAM; globals live in bank 0 and banks 0xE/0xF.
  - 1 KB of data EEPROM.
- **Image layout:** flash is at 0. The ID words are at 0x200000, the configuration at 0x300000 and the EEPROM at 0xF00000.
- **Compiler:** HI-TECH PICC-18.
  - `r000`–`r00e` are compiler temporaries, saved by the ISR at 0xF63–0xF7F.
  - `r0fc`–`r0ff` are argument slots.
  - Constant tables are read with TBLRD.
  - `switch` statements compile to XORLW chains.
- **Configuration words:**

  | Register | Value | Meaning |
  |---|---|---|
  | CONFIG1H | 0x08 | INTIO67: internal oscillator |
  | CONFIG2L | 0x16 | PWRT and BOR on |
  | CONFIG2H | 0x0F | WDT on, 1:128 (≈ 512 ms) |
  | CONFIG3H | 0x01 | MCLR off (RE3 is an input) |
  | CONFIG4L | 0x81 | LVP off |

- **Clock:** OSCCON=0x72 and OSCTUNE=0x80, so the internal oscillator runs at **8 MHz without the PLL (Fcy 2 MHz)**.
- **Interrupts:** a single vector at 0x0008 (IPEN=0).

### Main loop (`main` 0x6100)

Initialisation runs in this order:
1. `hw_init` (ports, oscillator);
2. `ee_load`;
3. `timers_init`;
4. `adc_init`;
5. `comms_init` (SPI slave + UART).

Each pass of the loop then:
1. runs `timebase`, `inputs_task`, `adc_task` and `comms_update`;
2. once the machine has started (0.8 s after reset) and on each 10 ms tick, runs:
   - `monitor_faults` (0x803E);
   - `state_control` (0x3186), which calls `machine_control` (0x10C0) and the unit drivers;
   - the EEPROM save task;
   - `power_task`;
   - `outputs_task`;
3. calls `wdt_kick`. It only executes CLRWDT when the pass ran the expected number of tasks (4 before the start, 10 after). A stuck task resets the chip after about 0.5 s.

## Pin map

| Pin | Dir | Function |
|---|---|---|
| RA0/AN0 | in | NTC, steam thermoblock (`temp_steam`) |
| RA1/AN1 | in | NTC, coffee thermoblock (`temp_coffee`) |
| RA5 | in | switch → `sensors.5` (inverted); only changes the energy-saving behaviour. Its function is unknown |
| RA6 | in | **flowmeter**: debounced 3 ms, about 2 pulses per ml |
| RA7 | in | **brew unit top switch** → `sensors.1` (low = closed) |
| RB0 | in | **grounds container** switch, AC-sensed: toggling with the mains = missing → `sensors.3` |
| RB1 | in | **water tank** switch, AC-sensed → `sensors.4` |
| RB2 | out | **brew unit motor, up**: triac gate, active-low 200 µs pulse 2 ms after the zero-cross |
| RB3 | out | **main relay**: supplies the loads and sensors. High while active |
| RB4 | in | **water level** (reed): high = water in the tank. `sensors.6` = tank empty |
| RB5 | out | **brew unit motor, down**: gate like RB2 |
| RC1 | in | **brew unit motor encoder**: one pulse per count, debounced 3 ms. Counts `bu_pos` |
| RC2/CCP1 | in | **mains zero-cross**: both edges captured with TMR1 |
| RC3–RC5 | SPI | slave to the display (SSPCON1=0x15: SS disabled, CKP=1) |
| RC6/RC7 | UART | service port, 19200 baud |
| RD1 | out | **coffee heater** triac, burst firing |
| RD2 | out | **grinder** triac (2 ms gate every half cycle) |
| RD3 | out | **EV2** solenoid valve (static) |
| RD4 | out | **pump** triac (2 ms gate every half cycle) |
| RD5 | out | **EV1** solenoid valve (static) |
| RD6 | out | **brew unit motor full power**: switched on after the soft start (static) |
| RD7 | out | **steam heater** triac, burst firing |
| RE0 | in | **hot water spout** present → `sensors.0` (low = present) |
| RE1 | in | **brew unit bottom switch** → `sensors.2` (1 = at the bottom) |

- **Unused pins:** RA2–RA4, RB6/RB7 (ICSP), RC0, RD0, RE2 and RE3 are inputs or unused.
- **Output timing:** PORTD is only written at the zero-cross, except when the mains is lost; then the loads are cut immediately.
- **`sensors`** (`r013`) is sent unchanged to the display as `pb_flags3`.

## Timing

**Timers:**
- **TMR0:** fires every 200 µs. It generates the triac gate pulses and decides heater firing.
- **TMR2:** fires every 1 ms. It gives the 10 ms tick, debounces RA6/RC1, and runs the SPI resync and UART timeouts.

**Mains:**
- **Zero-cross:** valid half periods are 6.6–12 ms.
- **50/60 Hz detection:** 30 consecutive half periods above or below 9171 µs decide the frequency.
- **Mains lost:** 5 bad periods, or 80 ms without a zero-cross, set `mains_lost`.
- **100 ms tick:** counted from the mains (10 or 12 half cycles), so it is synchronous with the mains.
- **1 s and 10 s ticks:** derived from the 100 ms tick.

**Heater burst firing:**
- Power is set as a number of whole half cycles on per **320 half-cycle window** (3.2 s at 50 Hz).
- The value is latched at the start of each window.
- The levels are in a table at 0x1044: 32..320 in steps of 32.

**ADC:**
- 8-bit conversions, averaged over 32 samples per channel (about 0.64 s).
- The stored value is `255 - average`: a **higher code means colder**.
- The firmware only compares raw codes; it never converts to degrees.

**Temperature codes.** These are estimates from the emulator's NTC model, which is fitted to the firmware thresholds:

| Code | Estimated temperature |
|---|---|
| 0xED | 25 °C (ambient) |
| 0xA2 | 71 °C ("reheat" threshold) |
| 0x76 / 0x72 / 0x6E / 0x6A | coffee setpoints for temperature settings 0..3, around 90–100 °C |
| 0x40 | steam keep-warm, around 125 °C |

## Display link (SPI slave)

This is the power board's side of `protocol.md` §1. `isr_spi` (0x5FBE) stores the bytes of a frame and preloads the next reply byte.

**Framing and resync:**
- A frame only starts on 0xB0. Until then, the slave keeps offering 0x0B.
- If a frame stays incomplete for 15 ms, the SSP is reset.

**Validation** in `comms_update` (0x4AF4). A frame is dropped silently unless all of these hold:
- the checksum is right: 0x55 + the sum of bytes 0..9;
- the key count in byte 7 matches the key bitmap;
- the time fields are in range (h < 24, m < 60, s < 60).

**Timing:**
- The reply is built after frame N and clocked out during frame N+1.
- The link watchdog is 5 s. When it expires, the keys are released and the clock is marked invalid.

**Reply frame (`spi_build_reply`, 0x4D16).** It is 11 bytes:

| Byte | Content |
|---|---|
| 0 | 0x0B |
| 1 | state |
| 2 | param1 |
| 3 | param2 |
| 4 | flags1 |
| 5 | flags2 |
| 6 | sensors |
| 7 | alarms |
| 8 | faults |
| 9 | progress |
| 10 | checksum |

- **Normal operation:** state = `mstate` and param1 = `mstep`. The internal numbering *is* the protocol numbering.
- **Menus:** the menu item maps to states 0x10–0x29. Bit 6 is set when `reb5 == 0`; the display ignores it.
- **Test modes:** `test_mode` 1..5 gives states 0x21–0x25.

`docs/pb_notes/comms.md` has the full bit list (flags, cup light condition, param2 per state).

## UART service port

**Line settings:** 19200 baud with BRG16. TX sends a 9th bit set to 1, so it looks like 8N2; RX is 8N1. This is **not** the display's 9600-baud port.

**Frame format:**
- Request: `0A len cmd dest data… chk`. `dest` must be 0x0F; for 0x95 it may also be 0xF0.
- Reply: `A0 len cmd 0F data… chk`.
- `chk` = 0x55 XOR all the bytes before it.

| Command | Meaning |
|---|---|
| `60` | status: I/O snapshot, `bu_pos`, pump pulse count |
| `70` | machine status: alarms, outputs, state/step, constant 0x23 (version?), both temperatures, product code |
| `80 b0 b1 b2 b3` | **remote load test**. It sets `test_mode` 3 for 5 s. `b0` is a command (brew unit up/down/position, pump N pulses, grinder, heater setpoints, EV1/EV2, combinations; see `pb_notes/units.md`). Replies alternate between 0x80 and 0x81 |
| `90 idH idL v3 v2 v1 v0` | write one parameter. 0x00–0x0E = record A, 0x32–0x41 = record B. The counters are read-only |
| `95 idH idL n` | read n 32-bit parameters. With dest 0xF0, IDs 0x3E8–0x3EE read what the display sent |
| `F0` | read the 10 factory bytes (EEPROM 0xF6–0xFF) |

The parameter IDs are listed in `pb_notes/comms.md`.

## Machine states

| `mstate` | Display | Steps / meaning |
|---|---|---|
| 0x00 | standby | 0–1 self-test delay, 2 idle (clock) |
| 0x01 | warm-up | heat, raise the brew unit, rinse, reheat (step 9 = reheat from ready) |
| 0x02 | turning off | optional rinse, brew unit home, → 0/2 |
| 0x04 | descaling | 0–6, then back to the saved state |
| 0x06 | (blank) | brew unit recovery: down, up, down, then back to ready |
| 0x07 | ready / brewing | 0 ready, 1–16 coffee cycle |
| 0x08 | rinsing | same code as the warm-up |
| 0x0A | milk / cappuccino | 0–6, then the coffee phase |
| 0x0B | hot water | 0–4 |
| 0x0C | cleaning (steam purge) | 0–4 |
| 0x0D | first start (language) | 0–3 |
| 0x0E | circuit fill ("Hot water / Confirm?") | 0–5 |
| 0x0F | circuit purge | 0–2, → standby |
| 0x21–0x25 | factory tests | `test_mode` + 0x20 |

**How states change.**
- `machine_control` (0x10C0) moves between states on keys, the encoder, alarms and temperatures.
- `state_control` (0x3186) runs the current step. On every tick it recomputes all the demands:
  - `req_bu_target`: 0xFFFF = up to the top switch, 0xFFFE = home, anything else = a position;
  - `req_pump_vol`: flowmeter pulses, 0xFFFF = unlimited;
  - the grinder time;
  - the heater setpoints and mode;
  - the valves.
- A step ends when every unit it waits on reports "done", or when its `step_timer` expires.

### Coffee cycle (state 7) *(emulated)*

| Step | Action |
|---|---|
| 0 | ready, waiting for a key |
| 1 | recipe: quantity for the drink, grind time for the strength (1 or 2 cups) |
| 2 | brew unit to position 0x52 |
| 3 | brew unit home |
| 4 | **grind**, skipped for pre-ground coffee. About 3.5 s for a standard 1 cup |
| 5 | wait |
| 6 | **brew unit up** until the top switch closes on the coffee cake |
| 7 | **stroke check** (below); in eco mode, wait for the temperature |
| 8 | **pre-infusion**: pump 0x19 pulses, then 3 s pause |
| 9 | wait |
| 10 | brew unit up (hold) |
| 11 | **dose**: pump the drink quantity. 0xFFFE while programming a quantity (the key stores the count) |
| 12–13 | optional extra (cappuccino / 2 cups) |
| 14–15 | **brew unit home**: the puck falls into the grounds container |
| 16 | ready (7/0) |

**Stroke check.** The brew unit stroke up to the top switch, `bu_pos` in encoder counts, measures the coffee dose:

| `bu_pos` | Meaning | Result |
|---|---|---|
| < 0xB4 | far too much coffee | state 6 (brew unit recovery), if the stroke reference is learned |
| 0xB4–0xC8 | too much coffee | `alarms2.5` **LESS COFFEE** ("use less pre-ground coffee"), cycle aborted |
| 0xC9–0xF1 | normal dose | the cycle continues |
| ≥ 0xF2 | no coffee | `alarms.5` **FILL BEANS CONTAINER** |
| ≥ `bu_stroke_ref`+7 while moving up | overtravel | fault class 2 |

`bu_stroke_ref` (r0bc) is the empty stroke learned during the warm-up. The power-up combo **menu + on/off** clears it, which forces it to be learned again. The last stroke also feeds the adaptive grinder dose (`grind_history_update`, `grind_dose_compute`).

**Other sequences:**
- **Warm-up (state 1):**
  1. heat the coffee thermoblock;
  2. raise the brew unit;
  3. rinse through the brew unit, with progress = pumped / volume;
  4. lower the brew unit;
  5. ready once `temp_coffee` < 0xA2 and `temp_steam` < 0x8E.
- **Reheat:** from ready, when the coffee side gets colder than 0xA2 (0xDE in eco), the machine goes to 1/9 until hot again.
- **Auto-off:** the timer is reloaded on any activity and runs in 10 s units. Its length comes from table 0x1030 indexed by `set_autooff`: 15 min, 30 min, 1 h, 2 h or 3 h. When it expires the machine goes to state 2 (with a rinse when it is hot).

### Power-up key combos

These are read on the first tick, about 0.8 s after power-up.

| Keys held | Effect |
|---|---|
| 2 cups + hot water | display/button test (0x21, 60 s). Also resets the language, the circuit-fill flag and the filter |
| 1 cup + hot water | load test (0x22): single keys drive single loads |
| hot water + rinse | automatic electric test (0x24, 60 s) |
| 1 cup + on/off + hot water | energy-saving test (0x25) |
| knob push + hot water | circuit purge (state 0x0F) |
| menu + on/off | forget the learned brew unit stroke |

### Faults and alarms (`monitor_faults` 0x803E)

**Alarms:**

| Bit | Condition |
|---|---|
| `alarms.0` | tank empty (RB4) |
| `alarms.1` | grounds container. The count goes up by 10 for a 1-cup coffee and 15 for a 2-cup one. The alarm is set when the count > 0x8B (about 14 single coffees), or after 72 h with grounds in it, or when the container is missing. Removing the container for 5 s resets the count |
| `alarms.2` | descale. Water since the last descale ≥ 5 M / 2.6 M / 1.4 M / 0.8 M flowmeter pulses, by `set_hardness` |
| `alarms.3` | filter. 100 000 pulses since the last filter change |
| `alarms.4` | ground too fine. The pump ran without flow for 3 s |
| `alarms.5` | no coffee (stroke ≥ 0xF2) |
| `alarms.6` | general fault |
| `alarms.7` | coffee NTC out of range, or the heating watchdog |
| `alarms2.4` | steam NTC out of range |
| `alarms2.5` | LESS COFFEE |
| `alarms2.6` | brew unit motor. The travel took longer than 11.9 s, or a switch was in the wrong state |

**Fault handling:**
- A fault runs a recovery sequence (`fault_class`/`fault_step`).
- It is acknowledged with ESC + OK, and needs the tank edge. The machine then restarts the warm-up.

## EEPROM (data EEPROM, 1 KB)

The firmware stores three records, each stored twice:
- the second copy immediately follows the first;
- each copy ends with a CRC-16 (poly 0x8005, MSB first, register initialised to 0xAA<<8 | byte0);
- at boot the first valid copy wins, otherwise the defaults are used;
- a save writes one byte every 30 ms, and only while the mains is present.

| Record | Address | Content |
|---|---|---|
| B, settings | 0x00 / 0x13 | `set_hardness` (0), calibration bytes, `bu_stroke_ref` (8-9), fault flag (11), `set_temperature` (12), `set_autooff` (13), `settings` (14: bit 0 auto-start off, 2 beep, 3 cup light, 4 energy saving, 7 filter), auto-start time (15-16) |
| A, language / quantities | 0x26 / 0x43 | language (bit 4 = chosen), 24 h flag, drink quantities (my coffee, espresso, standard, long, extra long) in flowmeter pulses, hot water, milk and cappuccino quantities |
| C, counters | 0x60 / 0x77 | coffees, water, descaling count, milk, filter count, pulse totals |

The per-byte tables are in `pb_notes/hw.md`. Its column labels for bytes 0, 12 and 13 of record B are wrong: they are `set_hardness`, `set_temperature` and `set_autooff`.

## Corrections to the area notes

The listing and the emulator both contradict the area notes in these places:

- **`fsm.md`:**
  - Every "pump 0xFFFF / 0xFFFE / 0x52" is really `req_bu_target` (brew unit up / home / position), and "dose" is `req_pump_vol`.
  - The driver labels are swapped: 0x7B90 is the pump and 0x7980 is the brew unit motor.
  - The temperature comparisons are inverted (a higher code is colder): warm-up step 9 goes to ready on `temp_coffee` < 0xA2.
- **`fsm.md`:** the stroke thresholds are reversed. < 0xC9 means too much coffee (LESS COFFEE), ≥ 0xF2 means no coffee. `brew_measure` is `bu_pos`.
- **`hw.md`:**
  - RC1 is the brew unit motor encoder, not the grinder.
  - RD2 is the grinder, RD5 is EV1, RD3 is EV2 and RD6 is the motor full-power relay.
  - RB4 is the water level.
- **`process.md`:**
  - `r06d:r06e` is `bu_pos`, not a brew time. `r0bc` is the learned stroke (`bu_stroke_ref`), not a time reference.
  - `r0c0` = `set_temperature`, `r0c1` = `set_autooff`, `r0b4` = `set_hardness`. The menu item table mixes these three up.
- **`comms.md`:** the `less_coffee_timer` / `beans_alarm_timer` symbols (0xF06 / 0xF05) look swapped relative to the bits they mask.
- **`r0f5` and `r0f6`–`r0f8`, `r069:r06a`, `r08c`:** these are compiler-overlaid scratch, not persistent variables.
- **`units.md`:**
  - The heater threshold tables start one byte later than stated (0x1003, 0x100D, 0x1017).
  - `flags21.1` means *one* cup, not two.
- **`pb_symbols.py`:** these names were wrong and are now fixed there and in the C:
  - `grind_dose_min`/`_max` were swapped; they are now `grind_dose_hi`/`_lo`;
  - the two 30-tick alarm hold timers were swapped (0xF05 is LESS COFFEE, 0xF06 is no coffee).

## Open points

- The function of RA5 (`sensors.5`). It only changes the energy-saving keep-warm. The code runs that path with `settings.4` clear and `sensors.5` set, so one of the two is inverted with respect to its name.
- Menu item 0x0E, and the exact use of the calibration bytes in record B.
- The real NTC curve. The °C values above are fitted, not measured.
