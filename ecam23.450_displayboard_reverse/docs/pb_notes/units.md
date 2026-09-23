# Power board: unit drivers, test modes, counters, progress ("units")

Scope: everything `f_3186` calls apart from `f_10c0`. Symbols are in `tools/pb_sym/units.py`.

## Architecture

The state logic works per tick. The `f_3186` prologue clears the request variables, then either `f_10c0` or a test-mode handler (chosen by `re88`) sets new ones. After that, `f_3186` always runs the unit drivers in this order:

```
f_7e58 wait snapshot -> f_7106 power mgr -> f_72bc heater B + valves -> f_7464 heater A
-> f_7b90 pump -> f_7dd2 grinder -> f_7980 brew unit -> f_7e86 sequencer
-> f_6b6e progress -> (clear r02a/r02b) f_7768 -> ... -> f_6832 counters
```

**Requests** (all cleared each tick):

| var | meaning |
|---|---|
| r030 | valves: .0 EV1, .1 EV2 |
| r031 | heater A setpoint |
| r033 | heater B setpoint |
| r035 | heater mode |
| r034 | grinder ticks |
| r065:r066 | brew unit target: FFFF = up to the upper limit, FFFE = down/home, else a position |
| r067:r068 | pump pulses (FFFF = unlimited) |

**Wait flags** (in the same tick):
- r022: .0 grinder, .1 brew unit, .2 pump, .3 heater A.
- r023.3: heater B.
- Step flags: r022.5 forward, r022.6 back, r027.7 back two.

`f_7e58` copies the wait flags into `re7f` (bits 0..4). `f_7e86` sees when each requested unit is done:

| unit | done when |
|---|---|
| grinder | r03f ∈ {2,3} |
| brew unit | r03e ∈ {3,6} |
| pump | r037 ∈ {2,3} |
| heater A | r03a ∈ {2,3} |
| heater B | r03b ∈ {2,3} |

When every requested unit is done, `f_7e86` advances one counter:
- `re86` in test mode;
- `re85` when r039 ∈ {1,2} (fault sub-step);
- `r038` (the sub-state) otherwise.

The step flags work on the same three counters. `re83++` when r01d.7 is set and the brew unit is done, or r01d.6 is set and the grinder is done.

A unit returns to state 0 only after its wait bit disappears from `re7f`, so a unit stays "done" until the state logic stops requesting it.

**Output image:**
- r02a: .0 motor down, .1 up, .2 heater A, .3 pump, .4 grinder, .5 heater B, .6 motor full power, .7 EV1.
- r02b: .0 EV2.

Temperatures `re5f` (A) and `re61` (B) are NTC codes: **higher = colder**.

Setpoint specials:

| value | meaning |
|---|---|
| FF | max |
| FD | 0x100 |
| FA | 0xA0 |
| F8 | fixed power 0x40 |

## Heaters

- **f_7106, power manager.** It shares the mains power between the two heaters according to r035:

  | r035 | behaviour |
  |---|---|
  | 0 | A only (r028.3 once re9b = 0) |
  | 1 | alternate, A first |
  | 2 | alternate, B first |
  | 3 | B only (r028.4) |
  | 4 | both, r023.7 = 1 |
  | 5 | both, r026.0 = 1 |

  Alternation uses r028.5 and the demand functions `f_7716` (A) and `f_76de` (B). re9c / re9b = 10 hold timers while heating.
- **f_7716 / f_76de, demand.** The demand is 1 when the temperature code is above the setpoint (colder), with +3 of hysteresis when not heating, or when the setpoint is FF/FD. Always 0 when the setpoint is 0 or there is a fault (r019.4 for B; r018.7 for A). A also requires `reb8 == 0` and `r01f.1`.
- **f_7464, heater A (coffee).**
  - **Brew feed-forward** (state 7 sub 0x0B or r025.7, with r035 = 0, reb8 = 0 and re5f within [sp−16, sp+8]): re60 = 0. The power is the 16-bit table 0x1044[re67] (0x20..0x140), with r02a.2 when r01f.1.
  - **Otherwise, regulation** (re60 = 1): err = re5f − sp. If err > 0x72 the power is 0x140. Otherwise i = the first threshold in 0x1003.. (05 0A 19 28 37 46 55 64 73) that is ≥ err, and the power is i·32 + 0x20.
  - r03a = 3 on r018.7.
  - ree6 = the previous setpoint.
- **f_72bc, heater B (steam) and valves.**
  - The power follows the same scheme: threshold tables 0x100C (normal) or 0x1016 (r01d.2), err > 0x6C → 0x140, and 0x140 for special setpoints or in test mode 4.
  - r03b = 3 on r019.4.
  - Valves: r030 → r02a.7 (EV1) and r02b.0 (EV2). They are blocked when the tank is missing (except in test mode) or the grounds container is missing.
- **f_7768, brewing power adaptation.** It runs during state 7 with 0 < sub < 0x0E (sub 0x0B or r025.7).
  - Every 20 ticks (after a 60-tick delay), re67 is recomputed from the window's flow pulses `re59`: > 0x11 → 9, < 3 → 0, else an index in 0x103B (03 04 06 08 0A 0C 0E 10 12).
  - It is then corrected by the signed `rede` (±1..3).
  - If |rede| ≤ 1: re5f ≤ 0x74 (hot) → −1; > 0x7B (cold) → +1.
  - re68 = the average of three windows.
  - Outside brewing, re67 = 9 if (r021.4 or re68 ≥ 4), else 3.

## Pump, grinder, brew unit

- **f_7b90, pump.**
  - States: 0 → 1 run (r02a.3; r021.6 inhibits it except in test mode) → 4 → 2.
  - It stops when r06b:r06c ≥ r067:r068.
  - During state 7 (0 < sub ≤ 0x0D) it pauses instead of stopping when the tank or grounds container is removed.
  - No water (r018.0): pumping is allowed only while r098:r099 < 0xB5.
  - Flow watchdog re7a/rec8: 100 while off, 30 once ≥ 13 pulses (100 in state 0x0E without r0db.0).
- **f_7dd2, grinder.**
  - States: 0 → 1 when r034 ≠ 0 and the tank and grounds container are present.
  - State 1: r02a.4 on; red2 counts r01c.3 ticks up to r034 → 4 → 2 → 0.
  - r034 = 0 while running aborts.
- **f_7980, brew unit motor.**
  - States: 1 up (r02a.1), 2 down (r02a.0), 4/5 stop with run-on re9f, 3 done.
  - Start delays: re96 (down), re97 (up). Soft start re9e, after which r02a.6 gives full power.
  - The target is latched into r05b:r05c. The position r06d:r06e is counted by `f_6832` from motor sensor pulses (r01b.4; r023.0 = direction) and reset at the lower limit.
  - ±4-count deadband.
  - An unexpected limit switch hit sets r019.6 and r039 = 3.
  - r03d = zone, rec9 = 40 while off.

## Test modes (re88, re86 = test_step, sent to the display by f_4d16)

| re88 | fn | content |
|---|---|---|
| 1 | f_6386 | nothing (display/button test) |
| 2 | f_63cc | **LOAD TEST**, described below |
| 3 | f_65c0 | **remote load test**, UART cmd 0x80, described below |
| 4 | f_64f8 | automatic self-test, described below |
| 5 | f_6388 | step select: clean edge → 1, ESC edge → 2 |

**f_63cc, LOAD TEST.**
- Steps 0/1/2: brew unit home, up, then position 82.
- Step 3: each single key drives one load:

  | key | load |
  |---|---|
  | menu | HEATER (r031 = coffee setpoint table 0x1058[r0c0]) |
  | 1cup | EV1 |
  | push | EV2 |
  | onoff | EV1 + EV2 |
  | clean | GRINDER 10 |
  | hotwater | PUMP unlimited |
  | cappu | VAPORIZER (r033 = 0x30, mode 3) |

- Steps 4/5 (2cups): brew unit down or up.

**f_64f8, automatic self-test.** The sequence runs over re86 = 0..~17. Timer r0a4:r0a5 (20/10/30) sets r022.5 to step forward. It runs heater A (0x27), the grinder 20 with the pump, the brew unit up and down, steam 0x30, then EV1 and EV2.

**f_65c0, remote load test (UART 0x80).**
- The frame bytes are b0 = cmd `re5b`, then a0 `re5c`, a1 `re5d`, a2 `re5e`. "word" means a1:a2 (a1 high).
- Test step: step 0 → 1 when cmd ≠ 0. In step 1 the command runs every tick; cmd = 0 goes back to step 0.
- cmd 0xC8 sets r01e.1.
- `re71` is cleared each tick. Command 0x0A sets it to a0, echoing a0 to the display.

| cmd | action (wait flag) |
|---|---|
| 01 / 02 | BU up / down (BU) |
| 09 | BU to position word (BU) |
| 03 | pump word pulses, 0 → 100 (pump) |
| 04 | grinder a2 ticks, 0 → 50 (grinder) |
| 05 | heater A setpoint a2, 0 → the table setpoint |
| 06 | heater B setpoint a2 (0 → 0x30), mode 3 |
| 07 / 08 | EV1 / EV2 |
| 0A | re71 = a0 |
| 15 | A = a1, B = a2, mode 1 |
| 16 / 17 / 18 | A = a0 plus pump word / grinder a2 / BU position word |
| 19 / 1A / 1B | B = a0, mode 3, plus pump word / grinder a2 / BU position word |
| 1C / 1D | pump word with EV1 / EV2 (pump) |
| 1E | EV1 + EV2 |
| 1F | pump word with EV1 + EV2 (pump) |

## Counters (f_6832)

**End of brew** (r022.7, state 7 sub > 0x0D):
- red9 = rec3 = 5.
- r0c9 += 10 (r021.1) or 15, saturating at FF.
- r0ca += 1/2 (cap FE).
- r0cb:r0cc += 1/2 (cap FEFF). The 1/2 probably means one or two cups.

**r01d.5:** red9 = 5 and r0d3:r0d4 += 1.

**Flow pulse** (r01b.0, red9 = 30):
- re59++ while brewing.
- The pump count r06b++ (always with a volume limit, else only in the brewing sub-states).
- r098++ while there is no water.
- Decalc counter r0c5..c8 += 8 (filter and no r018.3) or 10, ×5 in states 0x0A / 0x0C / 0x05, saturating at 00FFFFFF.
- Filter counter r0d6..d9 += 1 (cleared without a filter, r0c2.7).
- Total r0cf..d2 += 1.

**Brew unit sensor pulse** (r01b.4): position ± 1.

## Progress (f_6b6e → re79, SPI tx byte 9)

`re79` is clamped to 100 and held for re99 = 50. vol = r067:r068, pulses = r06b:r06c. Helpers: `f_0f70` mul32, `f_0eba` div32, `f_8562` / `f_8518` mul/div16.

| state | formula |
|---|---|
| 0x0E | pulses·100 / vol |
| 1 (sub < 4 or 9) | (0xED − re5f)·100 / (0xED − r031); 0 when re5f > 0xED |
| 1 sub 5 | pulses·100 / vol |
| 8 | sub < 5 → 10; sub 5 → 10 + pulses·90 / vol |
| 7 | sub < 4 → 0; 5..0x0A → 50 (r01d.0) or 20; 0x0B → r028.2 ? pulses·100 / 390 : 50 + pulses·50 / vol (r01d.0) or 20 + pulses·80 / vol; > 0x0B → 100 |
| 0x0A sub 3 | r01d.4: 10 + r0a2:r0a3·90 / 2400; else 10 + r0a2·(40 or 90) / r096:r097 |
| 0x0C sub 2 | 10 + reb6·90 / 100 |
| 0x0B sub 2 | 10 + pulses·90 / (1000 if r01d.4 else vol) |

## Constant tables

| address | content |
|---|---|
| 0x1003 | heater A thresholds |
| 0x100C / 0x1016 | heater B thresholds |
| 0x103B | f_7768 flow thresholds |
| 0x1044 | 16-bit powers 0x20..0x140 |
| 0x1058 | coffee setpoints 76 72 6E 6A (by r0c0) |

Also seen:
- 0x1020: 32-bit values 5 000 000 / 2 600 000 / 1 400 000 / 800 000.
- 0x1030: auto-off times 90 / 180 / 360 / 720 / 1080 (×10 s).

## Open questions

- Meaning of r01f.1, reb8, rede, r028.2, r01d.0 / .2 / .4 / .5, r025.7, r021.1 / .4 / .6.
- Where re96, re97, re9e, re9f, rec8 and ref5 are decremented (probably in the timer ISRs).
- The exact meaning of r0c9, r0ca and r0d3.
