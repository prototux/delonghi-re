# Power board communications (area "comms")

Functions:
- `f_4acc` comms_init
- `f_5fbe` isr_spi
- `f_4af4` comms_update
- `f_4d16` spi_build_reply
- `f_5f7a` checksum
- `f_2c8e` bin_to_bcd
- `f_6076` / `f_604c` UART ISRs
- `f_51ea`..`f_55c8` service replies
- `f_566e` pack_io_snapshot
- `f_5704` recipe_code
- `f_583c` / `f_5cdc` param_get / param_set

Symbols are in `tools/pb_sym/comms.py`.

## Clock

`f_6158` sets:
- `OSCCON = 0x72`: 8 MHz internal oscillator;
- `OSCTUNE = 0x80`: PLL off.

So Fosc = 8 MHz and Fcy = 2 MHz.

## 1. SPI slave (link with the display board)

### Hardware

`comms_init` sets `SSPCON1 = 0x15` and `SSPSTAT = 0`:
- SPI slave with the SS pin disabled;
- CKP = 1, CKE = 0, SMP = 0.

This matches the display's mode 3 master at 125 kHz. It enables `SSPIE`, then reads `SSPBUF` to clear it.

### Byte exchange: `isr_spi` (0x5FBE)

Buffers:
- rx at 0xF16..0xF20 (`spi_rx`);
- tx at 0xF21..0xF2B (`spi_tx`);
- index `spi_idx` (0xEA9).

For each received byte `b`:
1. On SSPOV: clear it, then set `spi_idx = 0` and `spi_resync_ms = 15`.
2. If `r026.3` (frame complete, not processed yet) is set, the byte is ignored.
3. If `spi_idx == 0`, the byte is only accepted if `b == 0xB0`:
   - store it, `spi_idx = 1`, `spi_last = 10`;
   - in every case load `SSPBUF = spi_tx[spi_idx]`. So until a 0xB0 arrives, the slave keeps offering `tx[0]` (0x0B).
4. Otherwise: `spi_rx[idx] = b`, `idx++`, `SSPBUF = spi_tx[idx]`. When `idx > 10`, set `r026.3` (frame done).
5. Set `spi_resync_ms = 15` while the frame is incomplete, 0 once it is complete.

Timing follows from this:
- The byte clocked out while the display's byte *n* comes in is `tx[n]`; `tx[0]` was preloaded into SSPBUF.
- **Resync:** `f_05ca` (TMR2 ISR, 1 ms) decrements `spi_resync_ms`. When it reaches 0 (15 ms without the frame completing), the SSP is re-initialised (`SSPCON1 = 0x15`, `SSPSTAT = 0`, dummy read, `SSPEN`), `spi_idx = 0`, and `r054 = 15` again.
  - The display's ~1.7 ms byte gap is well below this limit.
  - Its ~12 ms frame gap is also below it, but that doesn't matter: after a complete frame `r054 = 0`, so no timeout runs between frames.

### Frame processing: `comms_update` (0x4AF4), each main loop pass

This runs if `r026.3` is set (a complete frame is waiting).

**Validation.** The frame is discarded silently unless all of these hold:
- `checksum(spi_rx, 10, add) == spi_rx[10]` (seed 0x55, sum);
- the popcount of `rx[1]` (8 bits) plus `rx[7]` bits 0..2 equals `(rx[7] & 0x78) >> 3`, i.e. the key count the display sends must match its key bitmap;
- `rx[4] < 24`, `rx[5] < 60` and `rx[6] < 60` (binary time).

**Accept:**
1. If `rx[2] != disp_enc`, set `enc_activity (0xEBC) = 30`.
2. Copy the fields:

   | Variable | Source |
   |----------|--------|
   | `disp_keys` (0xE80) | `rx[1]` |
   | `disp_enc` (0xEA5) | `rx[2]` |
   | `disp_id` (0xE8B) | `rx[3]` |
   | `disp_hour` / `disp_min` / `disp_sec` (0xE8E..0xE90) | `rx[4..6]` |
   | `disp_keys_hi` (0xE81) | `rx[7] & 3` |
   | `disp_eecfg` (0xE70) | `rx[8]` |
   | `r028.0` (clock valid) | `rx[7].7` |
   | `disp_languages` (0xEDF) | `rx[9]` |

3. Call `spi_build_reply`, then set `link_timeout (0xED7) = 50`.

**In all cases** (valid or not): `spi_idx = 0` and `r026.3 = 0`.

**Link watchdog.** `f_016a` decrements `link_timeout` on the r01c.3 tick; that tick is derived from the mains zero-cross captured by CCP1, and is probably 100 ms, which gives about **5 s**. When it reaches 0: `disp_keys = 0`, `disp_keys_hi = 0` and `r028.0 = 0`, so keys are released and the clock is marked invalid.

**Latency.** The reply is built after frame N and clocked out during frame N+1.

**Quirk.** After an invalid frame SSPBUF still holds `tx[11]` (the byte after the buffer, i.e. `uart_buf[0]`), so the first byte of the next reply is wrong and the display drops that frame too. The frame after that is fine, because `spi_build_reply` reloads `SSPBUF = tx[0] = 0x0B` at its end.

### Reply frame: `spi_build_reply` (0x4D16)

The frame is `spi_tx[0..10]`:

| Byte | Content |
|------|---------|
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
| 10 | checksum: `checksum(tx, 10, add)` |

The function ends with `SSPBUF = tx[0]`.

#### State / param1 / param2

Evaluated in this order: test mode, then menu, then normal operation. Everything starts at 0.

**1. Test mode** (`test_timer` 0xEF8 != 0):
- state = 0x20 + `test_mode` (0xE88): 1 → 0x21 display test, 2 → 0x22 load test, 3 → 0x23 electric step, 4 → 0x24, 5 → 0x25;
- param1 = `test_param1` (0xE86);
- param2 = `test_step` (0xE71) if `test_mode == 3`, else `reda` (0xEDA; a countdown in `f_016a`).

**2. Menu** (`r026.5` set; `menu_item` = 0xE6C). The item index maps to the state:

| item | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|------|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|
| state | 0x10 | 0x14 descale | 0x11 clock | 0x16 auto-off | 0x13 auto-start | 0x15 temperature | 0x27 energy saving | 0x17 hardness | 0x12 language | 0x1F filter | 0x19 replace filter | 0x26 beep | 0x28 cup light | 0x18 defaults | 0x1A + `menu_value` (stats page) if open, else 0x1A | 0x29 auto-start time |

Item 0 → state 0x10, which the display shows as a blank screen. Any other index leaves the state at 0.

Params:
- **Items 2 and 15** (clock, auto-start time):
  - param1 = BCD(`menu_value`), with bit 7 = `r01e.5` (editing minutes);
  - param2 = BCD(`menu_value2`).
- **Item 14** (statistics), by page:

  | state | param1:param2 |
  |-------|---------------|
  | 0x1A | `r0cc:r0cb` (coffees) |
  | 0x1B | param2 = `r0ce` (descaling) |
  | 0x1C | 32-bit `r0cf..r0d2` / 2000, saturated to 0xFFFF (water, presumably litres) |
  | 0x1D | param2 = `r0d5` (filter) |
  | 0x1E | `r0d4:r0d3` (milk) |

- **Other items:** param1 = `menu_value` (0xF0A).
- **Then:**
  - state bit 7 = `r026.6` (item open);
  - state bit 6 = `reb5 == 0`. **This is new: the display masks it off with `& 0x3F`, meaning unknown.**

**3. Normal operation.** state = `machine_state` (r03c) and param1 = `machine_sub` (r038), so the internal state numbers *are* the protocol numbers 0x00-0x0F. Then:

- **r03c = 0x0D** (first start): param2 = `re6a` (language offered).
- **r03c = 7** (coffee):
  - param1 bit 5 = two cups (`cups == 1`); bit 6 = cappuccino (`r01d.0`);
  - param2 = (`r021.4` ? 0 : `taste` re63) | `drink` (re56);
  - bit 0 = `r025.1`;
  - bit 7 = programming the quantity (`r028.2` and sub > 1).
- **r03c = 0x0A** (milk):
  - param1 bit 6 = cappuccino;
  - param2 = taste | drink as above;
  - bit 7 = `r01d.4 && red5 == 0` (programming).
- **r03c = 0x0B** (hot water):
  - param1 bit 5 = cups==1; bit 7 when sub == 2;
  - param2 bit 7 as for milk.
- **Other states:**
  - param2 bit 7 = (`r037 == 1 && r02a.3`); this is the state 1 "rinse phase" flag the display uses (`ui.b2`);
  - bit 5 = (`r0bc|r0bd == 0` && state == 0 && `r011.3` && `r011.4` && `r02d == 2`);
  - bit 2 = (`r01d.4 && red5 == 0`);
  - bit 3 = `r01d.3` (descaling "underway" in state 4).

#### flags1 (byte 4)

| bit | source | meaning |
|-----|--------|---------|
| 0 | `settings.0` (r0c2) | auto-start off (the display hides glyph 0x10) |
| 1 | `settings2.1` (r0db) | 24 h clock |
| 2 | `settings.2` | beep enabled |
| 3 | `settings.3` | cup lighting enabled |
| 4 | `settings.4` | energy saving enabled |
| 5 | `rf00 != 0 && machine_sub == 0` | "Press CLEAN button" reminder |
| 6 | `settings.4 && ref6 == 0` | energy saving *active*: `ref6` is presumably its countdown |
| 7 | `settings.7` | water filter installed |

#### flags2 (byte 5)

- **Bits 0-3:** `language & 0x0F` (r0da).
- **Bit 4, cup light on**, needs all of:
  - `ref6 != 0` (not in energy saving);
  - `settings.3`;
  - at least one of:
    - `refa != 0` (a hold timer, probably after a brew);
    - state 7 with sub 1..16;
    - state 0x0A with sub > 1;
    - state 1 with sub > 4 and sub != 9;
    - state 8 with sub > 4;
    - state 2 with sub != 0;
    - state 0x0C.
- **Bit 5:** `r020.4` (milk container missing).

#### Bytes 6-9

- **sensors (byte 6):** `r013` unchanged.
- **alarms (byte 7):** `r018`, with bit 7 = `r019.4`. Bit 5 is cleared when `r018.5` is set but `rf06 != 0`, which delays or masks the "beans empty" alarm.
- **faults (byte 8):** `(r019 & 0xE0) | r039 | (re85 << 2)`. Bit 5 is cleared when `r019.5` is set and `rf05 != 0`. So:
  - bits 0-1 = `fault_lo`;
  - bits 2-4 = `fault_hi`;
  - bits 5-7 = `r019` bits 5-7 (bit 5 = "LESS COFFEE", bit 6 = fault detail, bit 7 = descaling drip tray).
- **progress (byte 9):** `re79`.

#### Discrepancies with docs/protocol.md

- **State bit 6** is used by the power board in menus (`reb5 == 0`); the display ignores it.
- **Link-lost timeouts:** the power board's watchdog is ~5 s (50 ticks at 100 ms); the display's is 2.5 s.
- **flags1 bit 6** is "energy saving enabled and its timer expired".
- **flags1 bit 0** is confirmed as "auto-start off".
- **flags2 bit 4** has the full cup-light condition listed above.
- **State 0x10** is a real menu entry (item 0) that the display renders blank.
- **Test states** 0x21-0x25 come from `test_mode` (1-5).
- **The 0x14 constant** (display byte 3) is stored as `disp_id` and exposed over the UART as parameter 0x3E8. The power board does not otherwise check it.
- **The display's EEPROM bytes 8/9** (`0x65`, number of languages) are stored:
  - `disp_eecfg` is exposed as parameter 0x3E9;
  - `disp_languages` bounds the language menu (see the state-machine area).

## 2. UART service port

### Line settings

`comms_init` sets:
- `BAUDCON = 0x08`: BRG16;
- `SPBRG = 0x67`, `SPBRGH = 0`;
- `TXSTA = 0x65`: TX9, TXEN, BRGH, TX9D = 1;
- `RCSTA = 0x90`.

That gives **19200 baud** (8 MHz / (4 × 104) = 19231). TX sends a 9th bit = 1, so it looks like 8N2; RX is 8N1.

This is **not** the display's 9600 baud. The two service ports are separate: the power board's is probably reached through its own connector or a test jig.

### Receive: `isr_uart_rx` (0x6076)

- **FERR/OERR:** CREN off, dummy read, index 0, CREN on.
- **Busy:** bytes are ignored while `r01c.1` (frame pending) or `r01b.7` (reply being sent) is set.
- **Timeout:** each byte sets `uart_rx_to = 2` (×10 ms); when it runs out, the index is cleared.
- **Framing:**
  - byte 0 must be 0x0A;
  - byte 1 is the length, which must be < 0x19, otherwise the frame is dropped;
  - bytes are stored into `uart_buf` (0xF2C);
  - once `idx > len`, `r01c.1` is set.
- **The frame:** 0x0A, len, cmd, dest, data…, checksum. The checksum is at index `len` and equals `0x55 ^ bytes[0..len-1]`, the same as the display's service port.

### Transmit

- The reply is built over the request in `uart_buf` with header 0xA0, the same command byte and `dest` 0x0F.
- The checksum (XOR, seed 0x55) is placed at index `len`, and `len+1` bytes are sent.
- Sending sets `r01b.7`; `isr_uart_tx` clears TXIE at the end and sets `uart_tx_to = 2`; `f_016a` clears `r01b.7` 20 ms later.

### Command dispatch (`comms_update`, 0x4BF4)

The frame is handled only if its checksum is valid. Byte 3 (`dest`, copied to 0xE91) must be 0x0F; for cmd 0x95 it may also be 0xF0. The command switch is a chain of XORs: 0x60, ^0x10 = 0x70, ^0xF0 = 0x80, ^0x10 = 0x90, ^0x05 = 0x95, ^0x65 = 0xF0.

In the formats below, `chk` is the checksum and `aa bb` a 16-bit big-endian value.

| Request | Reply |
|---------|-------|
| `0A 04 60 0F chk` | `A0 13 60 0F s0..s6 [r06e r06d] [r06c r06b] 00 00 00 00 chk` |
| `0A 04 70 0F chk` | `A0 10 70 0F al al2 io 00 state sub 23 t1 t2 prod r0c9 0A chk` |
| `0A 08 80 0F b0 b1 b2 b3 chk` | alternately `A0 0F 80 0F s0..s6 [r06e r06d] [r06c r06b] chk` or `A0 0C 81 0F recb t1 t2 re78 re77 r0b8 r0b5 0A chk` |
| `0A 0A 90 0F idH idL v3 v2 v1 v0 chk` | `A0 07 90 0F idH idL st chk` (st = 00 ok, FF bad ID) |
| `0A 07 95 dd idH idL n chk` | `A0 (6+4n) 95 0F idH idL {v3 v2 v1 v0} × n chk` |
| `0A 04 F0 0F chk` | `A0 0E F0 0F e0..e9 chk` |

**0x60, status.**
- `s0..s6` is `io_snapshot` 0xE4C..0xE52, packed by `f_566e`:
  - `s0`: bit0 = `r011.4`, bit1 = `r011.0`, bit2 = `r011.1`, bit3 = `r012.1`, bit5 = `r011.2`;
  - `s1`: bit6 = `r011.6`;
  - `s2`: bit0 = `r011.3`, bit7 = `r011.7`;
  - `s5` = `r013` bits 0-4 and 6;
  - `s6`: bit0 = `r013.5`.
  - `r011`/`r012` are probably the input/output images (see the drivers area).
- It is followed by two 16-bit values, `r06e:r06d` and `r06c:r06b`. These are used by the process engine and are probably pump/flow or brew-unit counters.

**0x70, machine status.**
- `al` = `r018`.
- `al2` = `r019` bits 5, 6, 4, 7 mapped to bits 0..3.
- `io` = `r02a` bits packed:
  - bit0 = `r02a.0 && r02a.6`; bit1 = `r02a.1 && r02a.6`;
  - bit2 = `r02a.2`;
  - bit3 = `r037 == 1 && r02a.3`;
  - bit4 = `r02a.4`; bit5 = `r02a.5`; bit6 = `r02b.0`; bit7 = `r02a.7`.
- `state` / `sub` = `r03c` / `r038`.
- **0x23** is a constant, probably the firmware version (v1.0? or 0x23).
- `t1` / `t2` = `re5f` / `re61`, written by the ADC code (`f_0dd8`); probably two temperatures, e.g. coffee and steam thermoblock.
- `prod` = `recipe_code()` (`f_5704`), the product being made:

  | Code | Product |
  |------|---------|
  | 1..5 | one cup: my/espresso/standard/long/extra long |
  | 6..10 | two cups |
  | 0x0B..0x0F | cappuccino with drink 0..8 (state 7 or 0x0A) |
  | 0x10 | hot water (state 0x0B) |
  | 0x11 | frothed milk (state 0x0A, not cappuccino) |
  | 0 | nothing |

- `r0c9` is parameter 0x65.

**0x80, remote load test.**
- `b0..b3` go to `test_outputs` 0xE5B..0xE5E.
- It sets `test_timer (0xEF8) = 5` and `test_mode (0xE88) = 3`. The display then shows the electric test screen (state 0x23, param2 = `test_step`) until the timer expires. How `b0..b3` drive the loads is in the state-machine/outputs area.
- The reply alternates, toggling `r01b.1` each time:
  - 0x80: same layout as 0x60 without the last 4 zero bytes;
  - 0x81: `recb`, `re5f`, `re61`, `re78`, `re77` (only read here: probably raw ADC values), `r0b8`, `r0b5` (parameters 0x36 and 0x33), then 0x0A.

**0x90, write one parameter.** The ID is big-endian `idH idL` (bytes 4-5) and the value is 32-bit big-endian (bytes 6-9); only the low 16 bits are used. `param_set` (`f_5cdc`):

| IDs | Target | Effect |
|-----|--------|--------|
| 0x00..0x0E | block A (below) | `eeprom_save_a` = 5 (save request) |
| 0x32..0x41 | block B (below) | `eeprom_save_b` = 5 |
| anything else | | fails: counters are read-only |

**0x95, read N parameters.** `dd` must be 0x0F or 0xF0. The reply length is 6 + 4n. `param_get` (`f_583c`) returns 32-bit values, big-endian in the reply (8-bit and 16-bit values are zero-extended).

With `dd == 0x0F`:

| ID | Variable | Meaning |
|----|----------|---------|
| 0x00 | `r0da` | language (8 bit) |
| 0x01 | `r0db` | bit1 = 24 h (8 bit) |
| 0x02 | `r0dc` (16) | |
| 0x03 | `r0de` (16) | |
| 0x04 | `r0e0` (16) | |
| 0x05 | `r0e2` (16) | |
| 0x06 | `r0e4` (16) | |
| 0x07 | `r0e6` (8) | |
| 0x08 | `r0e7` (16) | |
| 0x09 | `r0e9` (16) | |
| 0x0A | `r0eb` (16) | |
| 0x0B | `r0ed` (16) | |
| 0x0C | `r0ef` (16) | |
| 0x0D | `r0f1` (16) | |
| 0x0E | `r0f3` (16) | |
| 0x32..0x39 | `r0b4`..`r0bb` (8) | |
| 0x3A | `r0bc` (16) | |
| 0x3B..0x41 | `r0be`..`r0c4` (8) | 0x3F = `settings` r0c2 |
| 0x64 | `r0c5..r0c8` (32) | |
| 0x65 | `r0c9` | |
| 0x66 | `r0ca` | |
| 0x67 | `r0cb` (16) | coffees |
| 0x68 | `r0cd` | |
| 0x69 | `r0ce` | descaling |
| 0x6A | `r0cf..r0d2` (32) | water |
| 0x6B | `r0d3` (16) | milk |
| 0x6C | `r0d5` | filter |
| 0x6D | `r0d6..r0d9` (32) | |
| 0xC8, 0xCA | | constant 0x0A |
| 0xC9 | | constant 0x0C |
| 0xCB | | 0 |
| other | | 0 |

The 0xC8..0xCB constants are probably version/format identifiers. Blocks A (0x0DA..0x0F4) and B (0x0B4..0x0C4) are the EEPROM-backed configuration, probably the recipe quantities, temperatures and so on (see the EEPROM area). IDs 0x64..0x6D are the counters.

With `dd == 0xF0` (what the power board knows about the display, all 8 bit):

| ID | Variable |
|----|----------|
| 0x3E8 | `disp_id` (0x14) |
| 0x3E9 | `disp_eecfg` (0x65) |
| 0x3EA | hour |
| 0x3EB | minute |
| 0x3EC | second |
| 0x3ED | encoder |
| 0x3EE | languages |

**0xF0, factory block.** `e0..e9` are the 10 bytes at 0xF0C..0xF15, i.e. data EEPROM 0xF6..0xFF, read at boot by `f_0980`. They are probably serial or production data; the dump has 0xFF there.

## Timings

| Tick | Source |
|------|--------|
| 1 ms | TMR2 ISR (`f_05ca`): T2CON 0x09, PR2 0xF9 → 2000 Tcy |
| 10 ms (`r01c.2`) | 10 TMR2 ISRs (`r056`) |
| `r01c.3` | set from `r025.5`, which the CCP1 ISR sets every `re7c` captures (init 12); probably mains half-cycles, so 100 ms at 60 Hz (the drivers area should confirm) |
| `r01c.4` | 10 × `r01c.3` |
| `r01c.5` | 10 × `r01c.4` |

Other timings:
- `r01b.2` "started" is set 80 × 10 ms after boot (`r04c` = 0x50). The main loop only runs the machine logic after that.
- SPI resync: 15 ms. UART inter-byte timeout: 20 ms. Busy hold after a reply: 20 ms. Display link watchdog: 50 × `r01c.3` ticks.
