# Power board: machine control (f_10c0) and its helpers

`f_10c0` is called once per pass of the state machine (`f_3186@331c`).
It is not a recipe table interpreter. It is the **user and machine control layer**: it turns key presses, the encoder, alarms and temperatures into changes of the machine state `r03c` and sub-state `r038`.
Then `f_3186` and the output code run the actual sequences (pump, grinder, heaters).
Recipes are plain variables (programmed quantities) plus the constant taste → grind tables inlined here.

Symbols are in `tools/pb_sym/process.py`.

## Inputs used

| Var | Meaning |
|-----|---------|
| `r043` | Newly pressed keys: b0 1 cup, b1 2 cups, b2 hot water/OK, b3 P/menu, b4 on/off, b6 cappuccino, b7 rinse/ESC. |
| `r011` | Keys currently held, same bits as `r043`. |
| `r044` | Edges of display byte 7; b1 = encoder push. |
| `r02d` | Number of keys held. "Key alone" means `r02d == 1`. |
| `r01e.3` / `r01e.4` | Encoder moved CW / CCW (set by `f_30ba`). |
| `re5f` | Boiler NTC ADC value. Higher means colder. |
| `re61` | Second NTC ADC value (steam). |
| `r06c:r06b` | Flowmeter count for the current delivery. |
| `r06e:r06d` | Brew time. |
| `r013` | Sensors: b0 spout/nozzle present, b3 grounds container missing, b4 tank missing, b5 ready/at temperature. |
| `r018` | Alarms: b0 tank empty, b1 grounds full, b4 grind too fine, b5 beans empty, b6 fault. |
| `r019.5` | "Add less coffee". |
| `r028.0` | Clock valid (from the display). |
| `r026.2` / `r026.4` | Remote auto-start / on-off requests. |

## States and sub-states

The numbering is the same as the display protocol:

| r03c | State |
|------|-------|
| 0 | Standby (sub 0 = self-test, sub 2 = clock) |
| 1 | Warm-up (sub 9 = reheat) |
| 2 | Turning off |
| 4 | Descaling |
| 7 | Ready / brewing |
| 8 | Rinse |
| 0x0a | Milk / cappuccino |
| 0x0b | Hot water |
| 0x0c | Cleaning |
| 0x0d | First start (language) |
| 0x0e | Circuit fill ("Hot water / Confirm?") |

### First start (0x0d)

- The timers `rec7` / `rec6` (30 ticks) cycle the preview language `re6a` modulo `redf` (the language count reported by the display).
- OK alone at sub 0 → sub 1.
- At sub 3, the language is stored:
  - `r0da = (r0da & 0xf0) | re6a | 0x10` (bit 4 = language installed).
  - The settings reset to `r0c2 = 0x0d` (`0x1d` if `r0da.6`).
  - `rec3 = rec0 = 5` requests the EEPROM saves.
- If `r0da.4` is set, the saved state `re73` / `re72` is restored.

### On/off (`r043.4` alone, or `r026.4`)

- **With a fault (`r018.6`):** from state 0 or 2 → 7; from anything else → 0 sub 2.
- **From standby sub 2:** → state 1, or 0x0e when `r0db.0` (first-start circuit fill).
  - `r021.3` (rinse at start) is set if `re5f > 0x8e` (cold) or energy saving is on (`r0c2.4`).
- **From any other state:** → state 2 sub 0 with `r0a4 = 30`.
  - `r026.7` (rinse at switch-off) depends on the state it came from.

### Auto-start

- `r0c2.0 = 1` disables auto-start. It is forced to 1 when the clock is invalid.
- The machine starts when all of these hold:
  - standby sub 2;
  - `hour:min == r0c3:r0c4`;
  - `sec < 11`.
- It also starts on `r026.2`.

### Standby and ready

- **Standby** clears most of the flags and sets `re89 = 1` and `r028.1`.
- **Ready (7/0)** clears:
  - `re84`, `re83`;
  - `r01d.0`, `r01e.6`, `r025.1`, `r01f.6/7`;
  - `rec4`, `refc`, `r096/7`.
- `r028.1` is cleared in ready.
- `re9a` (100) counts down while `r013.5`.

### Temperature (`r01f.3` = reheat request)

- In ready, the machine goes to state 1 sub 9 with `r01f.3` when:
  - `re5f > 0xa2` (`> 0xde` with energy saving), or
  - `re61 > 0x8e`.
- `r01f.3` is cleared when `re5f <= 0x66`, or when the flow reaches 20 or more.

### Coffee (`re84` = brew phase)

**Phase 0 (wait for a cup key).**
Conditions: 1-cup or 2-cup key alone in state 7/0, with no `r018.0`, `r018.1` or `r018.6`.

- Result: sub 1 and `re84++`.
- `re55` = 0 for 1 cup, 1 for 2 cups; `r021.1` = 1 cup.
- `red4 = 0x50` is the long-press timer. If the key is still held when it expires, `r028.2` (programming mode) is set.
- With energy saving and `r01f.6`, `reb7 = 20` adds a preheat delay.
- It sets `r022.7`, `r021.7`, `r024.5` and `r024.4`.

**Phase 1 (compute the recipe).**

- **Quantity:** `r092:r093 = qty[re56]`.
  - For 2 cups, `r094:r095 = qty * 2 + 10`.
  - `re56` selects the drink:

    | re56 | Drink | Quantity var |
    |------|-------|--------------|
    | 0 | MY | `r0dc` |
    | 2 | Espresso | `r0de` |
    | 4 | Standard | `r0e0` |
    | 6 | Long | `r0e2` |
    | 8 | Extra long | `r0e4` |

    Each quantity is 16-bit and counted in flowmeter pulses.
- **Grind parameter from the taste `re63`:**

  | re63 | 0x10 | 0x20 | 0x30 | 0x40 | 0x50 |
  |------|------|------|------|------|------|
  | 1 cup → `re57` | 0x28 | 0x2f | 0x38 | 0x3e | 0x44 |
  | 2 cups → `re58` | 0x3f | 0x43 | 0x48 | 0x4b | 0x4f |

  `re63 == 0` means pre-ground coffee (`r021.4`).
- Then sub = 4 (or `sub++` when `r01f.6`).

**Phase 2 (brewing).**

- In programming mode at sub 0x0b, the key stores the measured flow `r06c:r06b` as the new quantity:
  - The value is clamped to 40..390.
  - It goes into the drink's quantity, or into `r0e9` (cappuccino coffee) when `r01d.0`.
  - `rec0 = 5` requests the EEPROM save.
- Otherwise sub → 0x0c / 0x0e, and `r025.1` / `r025.2` are set.

**Phase 3 (second cup).** `re84--`, state 7 sub 5, `r0a4 = 10`.

**Abort (sub 0x0e).**

- Triggered by `r018.5` (beans empty) or `r019.5` (less coffee).
- `rf05` / `rf06` are the 30-tick timers for these alarms.
- Any key (`r043 | r044`) clears `r019.5`.

### Milk / cappuccino (0x0a)

- **Start:** the cappuccino key alone in ready sets `r01d.0` (coffee after the milk) and `red1 = 0`.
  - If `r013.5` and (`r0c2.4` or `r020.4`): sub 1 with `r01d.4` (programming allowed), `red5 = 0x50`, `red1 = 0x14`, `re54 = 0`.
  - Otherwise: sub 0, `r0a4 = 50`.
- **Toggle:** pressing again within `red1` toggles `r01d.0` (cappuccino ↔ frothed milk only).
- **Programming:** the milk counter `r0a2:r0a3` (range 0x32..0x961) is stored to `r0eb`, `r0ef` or `r0f3` for `re54` = 0, 0x40 or 0x80.
- **Sub 3:** `rf00 = 120`; `r027.5` is set at ≥ 0x960.
- **Sub 5:** `rebf = 30`, `r01d.1`.
- **After the milk:**
  - `re83 = 3` or 4;
  - `r092 = r0e9`;
  - `re57` from the taste table;
  - then the coffee phase runs.
- **End:** `f_3096` returns to state 7 with sub 0x0c / 0x0e (`r025.2` if `re83 > 3`), or sub 0. It is also used when sub < 3.

### Hot water (0x0b)

- **Start:** OK alone in ready (or in state 1 sub 9).
  - Needs the spout (`r013.0`) and not `r013.5`; otherwise sub 0 with `r0a4 = 50`.
- **Sub 1:** `red5 = 0x50`; `r020.7` if `re61 < 0x4e`.
- **OK again** → sub 3 (stop).
  - In programming mode, the flow (max 1000) is stored to `r0e7:r0e8`.
- **Tank empty or spout removed** → sub 4.

### Cleaning (0x0c)

- **Requested by `r045.0` in ready.** Needs:
  - `r013.5`;
  - `re9a == 0`;
  - energy saving or `r020.4`;
  - no alarms.
- `reb6` counts ticks:
  - above 0xc7 → sub 3;
  - above 0x31, `rf00` is cleared.

### Rinse (8)

- The rinse key alone in ready → state 8 with `r021.3`.
- The rinse key while sub < 7 → sub 7 (stop).

### Descaling (4)

- **Start:** `r028.6` (from the menu).
  - Saves `re73` / `re72`.
  - Goes to state 4 sub 0.
  - Sets `r019.7` (descaling in progress, flags5.7) and `ref4 = 30`.
- **Sub 1 and sub 4:** need the spout plus OK → `r01d.3`.
- **Sub 5:** OK clears `r019.7`.

### Circuit fill (0x0e)

- **Sub 1:** spout present plus OK → sub 2.
- **Sub 3:** flow ≥ 180 → sub 4.
- **Sub 5:** clears `r0db.0` → standby.
  - With `r027.6` (filter install), it also sets `r0c2.7`, clears `r0d6..r0d9` and does `r0d5++`.

### Tank / grounds container removed (`r013.4` / `r013.3`)

| While in | Effect |
|----------|--------|
| 0x0e sub 1 | → sub 0 |
| Hot water | → sub 3 |
| Milk | `f_3096` |
| Cleaning / state 5 | → ready |
| Menu | exit |

### Fault (`r018.6` with `r039 == 1`)

- With `re85 < 5`, holding hot water + rinse (2 keys) sets `r025.6` (ESC+OK reset).
- `re85 == 1` → `r0bf = 1`; `re85 == 4` → `r0bf = 0`.
- `r018.4` (ground too fine) is cleared under several conditions, which sets `r01e.7`.

### Heater / aux request

`r023.6` is set (with GIE off) together with a value pair `r02e` / `r02f` that depends on the state. The meaning is **uncertain**; it could be a setpoint or a duty cycle.

| State | r02e / r02f |
|-------|-------------|
| Hot water | 5 / 2 |
| Warm-up / rinse | 0x32 / 0x14 |
| Milk sub 1 | 0x98 / 2 |
| Milk, other subs | 0x31 / 4 |
| Cleaning | 0x98 / 2 or 0x96 / 0x32 |
| State 5 sub 2 | 0x2f / 2 |

## Ready-state controls

- **Taste:** the encoder push (`r044.1`) adds 0x10 to `re63`; above 0x50 it wraps to 0.
- **Drink:** the encoder CW adds 2 to `re56` (above 8 → 0); CCW subtracts 2 (from 0 → 8).
- **Activity:** `rf02 = 120` whenever a key is held.
- **Energy saving (`r0c2.4`):** `ref6 = 60` is decremented on `r01c.4` ticks while the machine is idle in ready: no alarm, no keys, no encoder movement. `ref6 == 0` means energy saving is active (reported in flags1.6).

## Menu (`r026.5`)

**Entry and navigation:**

- **Entry:** P alone in ready. It sets `re6c = 1`, `re6b = 0` and `refd = 120` (timeout), and loads `rf0a` / `rf0b` with the current time if the clock is valid.
- **Moving between items:** the encoder moves `re6c` over 0..0x0e, skipping items whose enable byte in the table at `0x108F + item` is 0.
- **Editing (`r026.6`):**
  - Items 2 (clock) and 0x0f (auto-start time) use `f_3002` / `f_3044`. The hours are edited first, then the minutes (`r01e.5`).
  - The other items change `rf0a` over 0..`ree0`.
- **OK:**
  - item 0 starts a rinse;
  - item 1 starts descaling;
  - item 4 (auto-start): value 0 → off; value 1 → go to item 0x0f to set the time;
  - otherwise `f_2cb8` opens the item, or `f_2dee` applies it.
- **ESC** goes up one level, or exits the menu.
- **Timeout:** the menu exits when `refd` reaches 0.

**The table at 0x1080:** `0f 00 14 1e 32 46 5a 78 78 78 00 0c 1e 36 54 ff 00 …`, then pointer-like words `f4 3a f4 3a f6 3a …`. The enable bytes start at 0x108F. They are not fully decoded.

**Items** (`f_2cb8` opens an item, `f_2dee` applies it):

| Item | Meaning | Storage |
|------|---------|---------|
| 0 | Rinse | - |
| 1 | Descale | `r028.6` |
| 2 | Clock | time sent to the display |
| 3 | Temperature 0..4 | `r0c1` |
| 4 | Auto-start on/off | `r0c2.0` (inverted) |
| 5 | Water hardness 0..3 | `r0c0` |
| 6 | Energy saving | `r0c2.4` |
| 7 | Value 0..3 (auto-off?) | `r0b4` |
| 8 | Language | `r0da` low nibble, with `\| 0x10` |
| 9 | Water filter install / remove | `r0c2.7`, via state 0x0e with `r027.6` |
| 0x0a | Filter replace | clears `r0d6..9`, `r0d5++`, `red9 = 5`, state 0x0e |
| 0x0b | Beep | `r0c2.2` |
| 0x0c | Cup light | `r0c2.3` |
| 0x0d | Factory defaults | `r0b4 = 3`, `r0c0 = 1`, `r0c1 = 3`, `r0c2 = 0x0d/0x1d` (keeps the filter bit), `r0c3 = r0c4 = 0`, `f_451a(0)` |
| 0x0e | Value, max 4 | ? |
| 0x0f | Auto-start time | `r0c3` / `r0c4`; also enables auto-start |

Each change requests an EEPROM save (`rec3 = 5` or `rec0 = 5`).

## Helpers

- **`f_30ba` (encoder):** compares `rea5` with `rea6`, using threshold `re5a = 1`, and sets `r01e.3` (CW) or `r01e.4` (CCW). `rebc` is the resync timer.
- **`f_3002` / `f_3044` (clock editing):** increment or decrement the hours `rf0a` (0..23, when the argument is 0xff) or the minutes `rf0b` (0..59, when the argument is 0). Both wrap.
- **`f_3096` (end of a milk cycle):** see the Milk / cappuccino section.
- **`f_2be6` (grind history):** called on `r024.5` after a brew.
  - It computes `r08c:r08d = r0bc:bd − r0f5:f6`, the difference between the reference and the last brew time.
  - When the difference is within 8..0x2e, or `r027.3` is set, it shifts the histories `r0b5/6`, `r0b8/9` (← `recc`), `r0ba/b` and `r0be`.
  - On `r019.5` it loads the defaults 0x15, 0x43, 0x36 and 0x50.
  - The reference `r0bc` is stored during warm-up sub 5 on `r024.6` (`@22a0`). `r0f5 = r06d` (`@224a`).
- **`f_2718` (adaptive grinder dose):** called on `r024.4` at sub 4.
  - A weighted average of the histories (32-bit multiply and divide helpers) gives `re53`.
  - `re53` is clamped to `r0be ± 3` (`re4a` / `re4b`).
  - The bounds `recd` / `rece` come from the constants 0x44 / 0x3f:
    - espresso (`r021.1`) uses 8 and `re57`;
    - otherwise 0x2d and `re58`.
  - The result goes to `recc`, clamped to [`recd`, `rece`]; `r027.3` is set when it had to be clamped.
  - `f_3186@3e5a` then copies `recc` to `r034` (the grinder dose used by the sequencer).
- **Compiler helpers:** `f_0f70` / `f_85a8` (32-bit multiply), `f_85bc` (32-bit divide, pointer in FSR0), `f_857e` (shift left).

## Open points

- The exact meaning of `r02e` / `r02f` and of `r023.6`.
- Menu item 0x0e, and item 7 (`r0b4`).
- The full layout of the table at 0x1080 (the pointer words after 0x1090).
- The units of the grind values `re57` / `re58` / `recc`. They are probably grinder run time or pulses; this depends on how `r034` is used in the drivers.
