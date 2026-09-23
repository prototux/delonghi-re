# Power board: state supervisor (f_3186) and fault monitor (f_803e)

Analyst: fsm. Addresses are flash byte addresses. Names are the proposals of `tools/pb_sym/fsm.py`.

> **Main finding:** `f_3186` is **not** where keys move the machine between states. Most `mstate`
> (r03c) writes are in `f_10c0` (40+ sites: the process/key engine, another analyst). `f_3186` is the
> per-tick **supervisor**. For the current `mstate`/`mstep` it decides the actuator demands (heater
> setpoints, pump, grinder, dose valve, step timer), advances steps by raising `act_req.5`
> ("step done", consumed by `f_10c0`/`f_7e86`), and handles a few time-based transitions itself:
> end of warm-up → ready, end of turn-off → standby, auto-off → turn-off, recovery → previous state.
> The settings menu (items 0x11..0x29) is **not** in this function. `f_4d16` maps a menu index
> `re6c` to the display states 0x10..0x29, and the menu navigation code writes `re6c`/`r03c` in
> `f_10c0`.

The analysis tool does not follow the TBLRD jump table at 0x3BE8. A helper that seeds its 17 targets
lists the whole function.

## Timebase (for reading the constants)

`f_016a` turns `r01c.0`, raised by the TMR2 ISR every 10 ms, into one-pass ticks in `ticks` (r01c):

| bit | period |
|-----|--------|
| b2 | 10 ms |
| b3 | 100 ms (via `r025.5`) |
| b4 | 1 s |
| b5 | 10 s |

`step_timer` (r0a4:a5) is decremented on the 100 ms tick, so a value of 30 means 3 s.

This is confirmed by the auto-off table at 0x1030: 90/180/360/720/1080 × 10 s = 15 min, 30 min, 1 h, 2 h, 3 h, which matches display menu 0x16. The test timer 60 = 60 s.

## f_3186 layout

| addr | what |
|------|------|
| 3186-31B4 | Clear the per-tick demands: `act_req` (r022) bits 0-6, r023.3, r01d.6/7, r021.7, r027.0/7, r01e.7, `heat1_sp`/`heat2_sp`=0, `grind_dose_req`=0, `pump_amount`=0, `dose_amount`=0, `valve_sel`=0, `heat_mode`=0. Every demand is recomputed on each tick. |
| 31B6-3284 | **Power-up key combos**: only once, when `flags25.0` is set by `f_3146` at init. Table below. |
| 3286 | If `r01b.5` is set, skip straight to the drivers (L_4230). |
| 328C-330E | **Factory test mode** running (`test_timer`≠0): the timer counts down on the 1 s tick for modes 0,1,3,4,5 but not mode 2. Dispatch on `test_mode`: 1 → `f_6386` (empty: the display/button test runs entirely on the display side), 2 → `f_63cc` (load test), 3 → `f_65c0` (electric step test), 4 → `f_64f8` (electric test), 5 → `f_6388` (energy saving test). Then the drivers. |
| 3312 | If `reca`==0 (power not ready yet, set by the ISR/inputs code), go to the drivers. |
| 331C | **CALL f_10c0**: process/key engine (moves `mstate`/`mstep`). |
| 3320 | If `alarms.6` (fault) is set and `mstate`≠0: fault recovery sequence (below). Otherwise the per-state dispatch at 0x41D6. |
| 41D6-422E | Dispatch on `mstate` (XOR chain): 0→3420, 1→3444, 2→4000, 4→40E2, 6→4058, 7→36EA, 8→3444 (shares warm-up code), 0x0A→3C0E, 0x0B→3E80, 0x0C→3E80, 0x0D→33BC, 0x0E→33DC, 0x0F→40AE. States 3, 5, 9 and 0x10+ fall through. |
| 4230-4258 | Clear r02a/r02b, then the drivers in order: `f_7e58` (demand bits → `re7f`), `f_7106` (heater arbitration from `heat_mode`/setpoints), `f_72bc` (steam heater, `heat2_sp`, `valve_sel`), `f_7464` (coffee heater, `heat1_sp`), `f_7b90` (brew unit motor / dose), `f_7dd2` (grinder, `grind_dose_req`), `f_7980` (pump, `pump_amount`), `f_7e86` (valves / step-done bookkeeping), `f_6b6e`, `f_7768`. |
| 425C-431E | **Auto-off** (details below). |
| 4320-433E | `reed` = 12 while brewing (state 7, step 1..13) or when r037==1 && r02a.3. |
| 4344-440C | **Ready idle / eco level** (state 7, step 0, 10 s tick): `ready_idle`++ (saturating). `eco_level` is 0 if idle ≤ tbl[0x108A]=0, 4 if idle ≥ tbl[0x108E]=84, else the index i where idle < tbl[0x108B+i] with the thresholds 12, 30, 54, 84 (2 min, 5 min, 9 min, 14 min). In eco with `sensors.5`, `eco_timer`-- every 10 s. `ready_idle` is cleared in states 0 and 8, and while brewing. |
| 440E-4438 | `ref5` = 30 if 0x14 ≤ `brew_measure` < 0x2D and `sensors.4`, else 0. |
| 443A-4454 | `eco_timer` reloaded to 120 (20 min) unless (eco enabled && state 7 step 0 && `sensors.5`). |
| 4458-445C | `ref0`=0; **CALL f_6832**. |
| 4460-4486 | r02a bits 0/1/6 (set by the drivers) → r023.0, `re9e`/`re9f`=50. |
| 4488-44B0 | `re96`=30 if `motor_cmd` is 1 or 4, `re97`=30 if it is 2 or 5. |
| 44B2-4518 | Countdowns on the 100 ms tick: `rec3`→`r042.5`, `red9`→`r042.3`, `rec0`→`r042.1` (flags for f_10c0). `rec3`/`red9` are forced to 0 while test mode 2/3/4 runs. |

### Power-up key combos (0x31B6)

Checked once, on the first supervisor tick after boot. The main loop starts ticking 800 ms after power-up (`r04c`=80 × 10 ms), so these are the keys held while the machine is switched on.

| keys held (exact count) | effect |
|---|---|
| 2 cups + hot water (2) | `test_mode`=1 (display state **0x21** display/button test), `test_timer`=60 s. It also resets the language (`r0da` &= 0xE0), sets `r0db.0` and clears `settings.7` (filter), and sets `rec3`=`rec0`=5. It looks like a factory "first start" reset plus the display test. |
| 1 cup + hot water (2) | `test_mode`=2 (**0x22** load test), `test_timer`=1 (never counts down in mode 2). |
| hot water + rinse (2) | `test_mode`=4 (**0x24** electric test), `test_timer`=60, `test_param`=0, `step_timer`=1 s. |
| encoder push + hot water (2) | `mstate`=0x0F step 0: circuit purge ("EMPTY CIRCUIT"). |
| menu + on/off (2) | clears `brew_ref` (r0bc:bd), `rec3`=5 (re-learns the brew unit travel). |
| 1 cup + on/off + hot water (3) | `test_mode`=5 (**0x25** energy saving test), `test_timer`=60, `test_param`=0. |

`test_mode`+0x20 is what `f_4d16` sends as the display state, with `test_param` as param1. In mode 3 param2 is `re71`, otherwise `reda`.

## Per-state logic (step dispatch = XOR chains on `mstep`)

**Common tails:**

| label | meaning |
|-------|---------|
| L_415E | `act_req.5` (step done) |
| L_3336 | wait for `step_timer`==0, then step done |
| L_35A4 | `pump_amount`=0xFFFE + pump |
| L_40B4 | `pump_amount`=0xFFFF + pump |
| L_3354 | `pump_amount`=0x52 + pump |
| L_3BD8 / L_3610 | `step_timer`=3 s / 1 s |
| L_36A2 | **→ state 7 step 0 (READY)** |

The coffee setpoint table is at 0x1058: `set_temperature` 0..3 → 0x76, 0x72, 0x6E, 0x6A; entries 4..7 = 0x49, 0x40, 0x3B, 0x36 are not used here. Below, "SP" means `tbl[set_temperature]`.

### 0x00 standby (0x3420)

| step | action |
|------|--------|
| 0 | `step_timer`=2 s, done |
| 1 | wait timer, then done |
| 2 | idle, no heater (the display shows the clock) |

### 0x01 warm-up and 0x08 rinse (0x3444)

**Heating, state 1 with step ≠ 0.** Heating targets `temp_coffee` thresholds 0x55/0x75/0x4E and a rinse at `heat1_sp`=0x76, with `heat2_sp`=0x40 or 0xFF and `heat_mode` 1/2/5. Eco without `sensors.5` uses 0x76/0xC8.

**Other cases (state 8, or state 1 step 0):**
- With `flags21.3` and step 5: `heat1_sp`=0xFD, or 0xFA when `r01f.7`, once `temp_coffee` ≥ SP−20.
- Otherwise `heat1_sp`=SP (steps ≠ 0, 6).

**Steps (0x36B8):**

| step | state 1 (warm-up) | state 8 (rinse) |
|---|---|---|
| 0 | tank present, no tank-empty alarm, grounds container present → done | same. In eco, if `temp_coffee` > 0x8D: `r01f.7`=1 and a short pump (0x52) |
| 1 | pump (0xFFFE) | pump if eco && `r01f.7`, else done |
| 2 | wait `temp_coffee` ≥ 0xB6, then pump 0xFFFF | pump 0xFFFF |
| 3 | done when `temp_coffee` ≥ 0x8E or not eco | same |
| 4 | done | done |
| 5 | if `flags21.3` (rinse pending): dose valve `dose_amount`=0xAF, 1 s; else done | dose = `r0e6` (rinse amount from EEPROM) |
| 6 | wait timer | wait timer |
| 7 | pump 0xFFFE | pump 0xFFFE |
| 8 | wait `temp_coffee` ≥ SP+10 (only in eco), then done | done |
| 9 | eco: `temp_coffee` ≥ 0xC8 → READY; normal: `temp_coffee` ≥ 0xA2 and `temp_steam` ≥ 0x8E → READY | READY immediately |

### 0x02 turning off (0x4000)

| step | action |
|------|--------|
| 0 | if `flags26.7` (turned off during warm-up): pump 0xFFFE, else done |
| 1 | pump 0xFFFF |
| 2 | wait / done |
| 3 | if `flags21.3`: dose 0x4B, 1 s (rinse on the way off); else done after 1 s |
| 4 | wait |
| 5 | done |
| 6 | pump 0x52 |
| 7 | `mstate`=0, `mstep`=2 (**standby**), and the saved state is set to the same |

### 0x04 descaling (0x40E2)

`heat_mode`=1, `heat1_sp`=`heat2_sp`=0xB6.

| step | action |
|------|--------|
| 0 | done |
| 1 | only if `r01d.3`: if tank empty and `r098:099` ≥ 0xB5 → done. Else, unless `alarms.4`: count `ref4` down in seconds with the dose valve open (0xFFFF), `valve_sel`=3 while `ref4` > 4. At 0 → done, `reeb`=30. |
| 2 | `reeb` counts down on the 10 s tick. Then done if the tank is empty and ≥ 0xB5, or if `alarms.4`. When `reeb`==0: `act_req.6` and `ref4`=30. |
| 3 | done unless (tank empty and tank present) |
| 4 | only if `r01d.3`: tank empty ≥ 0xB5 or `alarms.4` → done, else dose valve open. If not tank empty → `valve_sel`=3. |
| 5 | done if `r01d.3` |
| 6 | restore `saved_mstate`/`saved_mstep`: back to where descaling was started from |

`f_803e` clears the descale water counter when state 4 step 6 is reached.

### 0x06 brew unit recovery (0x4058)

This state is hidden: the display shows a blank screen. `f_803e` enters it when `brew_measure` < 0xB4 with the motor moving and the upper switch set. It saves the current state and sets `step_timer`=1 s.

| step | action |
|------|--------|
| 0 | wait timer, then pump 0xFFFE |
| 1 | pump 0xFFFF |
| 2 | pump 0xFFFE |
| 3 | if `saved_mstate`==2 (was turning off): `flags21.3` = !(`r01f.2` && tank empty), keep the saved state and go to 2/0. Otherwise → 7/0 READY. |

### 0x07 ready / brewing (0x36EA)

If `temp_coffee` ≤ 0x4E (cold), heating is skipped and control goes straight to the step table.

**Step 0, ready: heater logic.**
- **Steam thermoblock keep-warm** (only when `temp_steam` > 0x24):
  - `ready_timer` (10 ms units, reload 4500 = 45 s) runs;
  - `re87` cycles 0..2 at 1000/2500/4000 × 10 ms, with `re95` as the ramp;
  - the target `heat2_keepwarm` is 0x40, or 0x30 in eco with `sensors.5` and `eco_timer`≠0;
  - the steam heater is driven around the target (±4) with `heat_mode` 1 or 3;
  - `r01f.0` is set when the steam side is above the target.
- **Coffee thermoblock:**
  - 0x71 < `temp_coffee` ≤ 0x78 and `ready_timer` < 0x33: `heat_mode`=0, `heat1_sp`=0xFF (boost);
  - else `heat1_sp`=0x76 once `temp_coffee` > 0x75, `heat_mode`=1.
- `r020.4` is set when `temp_steam` ≤ 0x40 (not in eco).
- **Eco without `sensors.5`:** the coffee side is held between 0xC3 and 0xC9 (lower keep-warm).

**Steps 1-3:** `heat1_sp`=SP, or 0x76 when not eco.

**Steps 4-15:** variants for pre-ground (`flags21.4` → SP+0x14), for `r01f.6`, and for step 7 (full on until `temp_coffee` ≥ SP−20). Steps 8 and 9..10 use full on when `set_temperature`==3, and step 11 or `flags25.7` gives full on until SP+8.

**Brew step table (TBLRD, 0x109E, 17 entries → 0x3AF4..0x3BE4). This is the espresso cycle:**

| step | action |
|------|--------|
| 0,1 | nothing (0 = ready, waiting for a key; handled by f_10c0) |
| 2 | pump 0x52 (short) |
| 3 | pump 0xFFFE |
| 4 | **grind**: unless pre-ground (`flags21.4`), `grind_dose_req`=`grind_dose` + grinder. If `r01f.3`: dose valve 20. Timer 3 s when eco && `r01f.6`, else 1 s. With pre-ground: done unless `r01f.3`. |
| 5 | wait timer |
| 6 | pump 0xFFFF for 2 s (pre-infusion) |
| 7 | wait timer. If eco: wait `temp_coffee` ≥ SP+16. Then done. |
| 8 | dose valve 0x19, 3 s |
| 9 | wait timer |
| 10 | pump 0xFFFF |
| 11 | **brew water dose**: `dose_amount` = `coffee_dose_2cups` (`flags21.1`) or `coffee_dose_1cup`, or 0xFFFE when `r028.2` (programming the quantity) |
| 12 | if `flags25.1` && `flags25.2`: pump 0xFFFF, else done. 3 s |
| 13 | if `flags25.7`: dose 0x186, 3 s; else wait timer |
| 14,15 | pump 0xFFFE |
| 16 | → READY |

### 0x0A milk / cappuccino (0x3C0E)

**Heating:**
- steps 1: `heat_mode` 2 (eco) or 3, `heat2_sp`=0x2B above 0x35;
- with `flags1d.0` (cappuccino), the coffee side is reheated to SP;
- steps 0,4+: `heat2_sp`=0xFF with mode 3 until `temp_steam` reaches 0x1D, or 0x24 at step 4.

**Steps:**

| step | action |
|------|--------|
| 0 | wait timer → READY |
| 1 | if `r01f.3`: dose 20. Else if `temp_steam` ≤ 0x35 and `red1`==0: done after 2.5 s. Else `dose_amount`=0xFFFF (heating steam). |
| 2 | valve open. When the timer expires: done, then 5 s. |
| 3 | **milk**: `dose_amount`=0xFFFE, `valve_sel`=1 (+2 when the timer is 0). Unless programming (`flags1d.4`), done when the milk counter `r0a2:a3` ≥ the milk dose. The dose is selected by `re54`: 0 → `r0eb`, 0x40 → `r0ef`, 0x80 → `r0f3`. |
| 4 | done after 3 s |
| 5 | if `r01d.1`: `valve_sel`=1 (+2 and 3 s when `rebf`==0), else wait timer |
| 6 | if `flags1d.0`: `re84`=3 when `cappu_phase`==5; else → READY |

**Cappuccino coffee phase** (`flags1d.0`, from 0x3E1C), after the milk steps, on `cappu_phase`:

| phase | action |
|-------|--------|
| 1,2 | pump 0xFFFE, `r01d.7` |
| 3 | not eco → phase++ |
| 4 | pre-ground → phase++, else grind (`r01d.6`) |

### 0x0B hot water / steam and 0x0C (0x3E80)

**Heating:**
- **0x0C:** `heat_mode`=3. In eco the steam side is limited to 0x67; then `heat2_sp`=0xFF until `temp_steam` > 0x24.
- **0x0B:** step 2: `heat1_sp`=0xFF while `temp_coffee` > 0x5D. Other steps ≠ 0: `heat_mode`=5, `heat1_sp`=SP, `heat2_sp`=0xFF until `temp_steam` > 0x8D.

**Steps:**

| step | 0x0B | 0x0C |
|---|---|---|
| 0 | wait timer → READY | done |
| 1 | done when `temp_coffee` ≤ 0x8E, or when `temp_steam` > 0xA2 (then `rec5`=30); else valve open | done when `temp_steam` ≤ 0x67, else valve open |
| 2 | **dispense**: `valve_sel`=3, `dose_amount`=`hotwater_dose` (0xFFFE when programming) | valve open, `valve_sel`=3 |
| 3 | `rebd`=30, done | done |
| 4 | wait `rebd`=0 → READY | → READY |

### 0x0D first start (language) (0x33BC)

| step | action |
|------|--------|
| 0,1 | `step_timer`=3 s |
| 2 | wait timer, then done |
| 3 | idle (waiting for OK, in f_10c0) |

### 0x0E (0x33DC)

This state is labelled "hot water prompt" on the display side. Here it looks like the **circuit filling / "Hot water / Confirm?" with the spout**:

| step | action |
|------|--------|
| 0 | done when there is no tank-empty alarm, the tank is present and the grounds container is present |
| 2 | spout present (`sensors.0`) → dose 0xB4 (18 s worth), `valve_sel`=3; else `act_req.6` (missing condition) |
| 4 | pump 0xFFFE |
| 1,3,5 | idle |

### 0x0F circuit purge (0x40AE)

This state is entered by the push + hot water power-up combo.

`heat1_sp`=0x5A.

| step | action |
|------|--------|
| 0 | pump 0xFFFF |
| 1 | `act_req.3` (purge valve) for 10 s |
| 2 | wait timer → standby (state 0 step 0) |

### Fault recovery (0x3326, when `alarms.6` and `mstate`≠0)

| fault | `fault_code` 0 | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|---|
| class 1 | wait, done | done | pump 0xFFFE if `flags25.6` | pump 0x52 if `flags25.6` | done | idle |
| class 2 | wait, done | pump 0xFFFE | wait | pump 0x52 | idle | — |

The code steps up through `f_10c0`. The fault is cleared in `f_803e` (below).

### Auto-off (0x425C)

**Reload** `autooff_timer` from `tbl[0x1030 + 2*set_autooff]` (in 10 s units) whenever any of these holds:
- the state is 0, 2, 4 or 0x0F;
- a key edge (`keys_pressed`|`keys2_pressed`);
- `r01e.3`;
- `r01e.4`;
- r03f==1 && r02a.4;
- r037==1 && r02a.3.

**Otherwise** it counts down on the 10 s tick. At 0:
- `flags21.3` is set (rinse when turning off);
- if brewing (state 7, step 1..13): `step_timer`=3 s and `flags26.7`/`flags21.3` are cleared;
- else if in state 1 step 0: `flags26.7`=1, otherwise it is cleared;
- **→ state 2 step 0 (turning off).**

## f_803e: fault monitor (every tick, before f_3186)

| addr | condition → effect |
|------|--------------------|
| 8040 | `grounds_out_timer`=50 while the grounds container is present |
| 804A-8074 | `rf03`=180. `ref3`=36 (NTC check enable) unless in state 1 with both `f_76de`/`f_7716` false and not (r037==1 && r02a.3) |
| 8078-8126 | **Brew unit motor watchdog**. While `motor_cmd` is 1 or 2, `motor_run_timer` counts in 100 ms (saturating). Checks depend on `motor_phase`: phase 2 at > 2.9 s needs the lower switch `sensors.2`, phase 3 needs the upper switch `sensors.1`, otherwise `alarms2.6`. After 11.9 s, if the travel was not completed: `fault_class` 1 (phase 0) or 2 (phase 1/3), `alarms2.6`, `step_timer`=1 s, `fault_code`=0 or 2. `motor_run_timer` is cleared when the motor is idle. |
| 812C-817C | `brew_measure` ≥ `brew_ref`+7 while the motor moves (`motor_cmd`==1, `brew_ref`≠0) → fault class 2 (or 3 if already faulted) |
| 817E-81D8 | `brew_measure` < 0xB4 with `motor_cmd` 1/4, upper switch set, `brew_ref`≠0, not already in or returning to state 6/step 3 → save the state, **state 6 (brew unit recovery)**, `step_timer`=1 s |
| 81DA-8234 | **Grounds**. `grounds_timer` reloaded to 0x6540 (72 h) while `grounds_count`==0, else it counts down every 10 s. `alarms.1` (grounds) is set when (`grounds_count` > 0x8B, or `grounds_timer` expired, while in ready/warm-up) or the container is missing. |
| 8236-8256 | Container removed for 5 s (`grounds_out_timer` expired) → `grounds_count`=0, `alarms2.7`=0, `red9`=5 |
| 8258-82B2 | **Descale alarm** `alarms.2` = `water_since_descale` ≥ table at 0x1020 [`set_hardness`] (32-bit, little endian): 5 000 000, 2 600 000, 1 400 000, 800 000 |
| 82B4-82E0 | State 4 step 6 (descaling finished): clear `water_since_descale`, `descale_count`++, `red9`=5 |
| 82E2-8304 | **Filter alarm** `alarms.3` = `water_since_filter` ≥ 100 000 |
| 8306-831A | `alarms.4` (ground too fine) = r037==1 && r02a.3 && `rec8`==0 |
| 831C-836A | In state 7 step 11 (brewing water) or `flags25.7`: `red6` 2 s timer; at 0, `r01f.1` is cleared if `r06b:6c` < 3. Otherwise `red6`=20. `r01f.1` is set when `r06b:6c` ≥ 0x2D (flow present). |
| 836C | `alarms.0` (tank empty) = `sensors.6` |
| 8376-83A4 | State 7 step 7 (compaction): `brew_measure` ≥ 0xF2 → `alarms.5` (beans empty); ≥ 0xC9 → `alarms2.5` (LESS COFFEE) |
| 83A6-83CC | Coffee NTC out of range (< 0x13 or > 0xFC, when `ref3` and `rf03` are ≠ 0) → `alarms.7`, `fault_class`=3 |
| 83CE-83E4 | Steam NTC out of range (< 5 or > 0xFC) → `alarms2.4`, `fault_class`=3 |
| 83E6-83EE | `alarms.6` (general fault) \|= `alarms.7` \| `alarms2.4` \| `alarms2.6` |
| 83F0-8452 | **Fault acknowledge**. With a fault and `r024.2` (a tank re-insert edge from `f_6208`), and (class 1 with code 5, or class 2 with code 4), i.e. the recovery sequence finished: clear the fault. If the state is not 0/2, go to warm-up 1/0, with `flags21.3` = `temp_coffee` > 0x8E (still hot → rinse). Otherwise go to 0/2. |

## State table summary

| mstate | display | meaning | leaves to |
|---|---|---|---|
| 0x00 | standby | off, clock | → 1 (f_10c0 on ON key); 0x0F / test modes at power-up |
| 0x01 | warm-up | heat + rinse, steps 0..9 | → 7/0 at step 9 when hot; → 2 on auto-off |
| 0x02 | turning off | rinse + pump, steps 0..7 | → 0/2 |
| 0x04 | descaling | steps 0..6 | → saved state |
| 0x06 | (blank) | brew unit recovery | → 7/0, or back to 2 |
| 0x07 | ready / brewing | 0 ready, 2..16 espresso cycle | → 7/0; → 2 on auto-off |
| 0x08 | rinsing | same code as warm-up | → 7/0 |
| 0x0A | milk / cappuccino | steps 0..6 + coffee phase | → 7/0 |
| 0x0B | hot water / steam | steps 0..4 | → 7/0 |
| 0x0C | cleaning (steam purge) | steps 0..4 | → 7/0 |
| 0x0D | first start / language | steps 0..3 | (f_10c0) |
| 0x0E | circuit fill / spout prompt | steps 0..5 | (f_10c0) |
| 0x0F | circuit purge | 0..2 | → 0/0 |
| 0x21..0x25 | factory tests | `test_mode`+0x20 | `test_timer` |

## Open points (for the other analysts)

- `r01f` bits:
  - .0: steam above target;
  - .1: water flowing;
  - .2 and .3: unknown;
  - .6: unknown;
  - .7: extra rinse.
- `r02a`: driver status bits.
  - .3 with r037==1: the brew unit is at a position;
  - .4 with r03f==1: unknown.
- `sensors.5` (PORTA5): modifies the eco behaviour. Possibly the "steam knob / milk system" or the "grid" detector.
- The exact physical meaning of `act_req.2` vs `valve_sel`, and of `pump_amount` 0xFFFE vs 0xFFFF.
