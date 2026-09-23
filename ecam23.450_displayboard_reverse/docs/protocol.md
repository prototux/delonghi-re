# ECAM 23.450: display board ↔ power board protocol

This is derived from the display board firmware (v30 image, which is byte-identical to the v20 one).
The C reference is `reimplem/src/pblink.c`, `isr.c` and `keypad.c`.
Meanings marked *(inferred)* come from which messages or LEDs a bit drives in the UI code. They have not been confirmed on a live machine.

The board-to-board link carries one of two protocols. A 74HC4052 driven by RC3 selects which one reaches the PIC's RC6/RC7:

| RC3 | Link | Used for |
|-----|------|----------|
| 1   | **SPI** (SSP module) | normal operation, always, except in service mode |
| 0   | **UART** | service mode only: a PC tool reads and writes the text EEPROM |

The UART is **not** how the machine is controlled. Everything the machine does goes over SPI.

## 1. SPI link (normal operation)

### Physical layer

- The display board is the **master**. Settings: `SSPCON = 0x32`, `SSPSTAT = 0x00`.
  - SCK = RC6, SDI = RC7, SDO = RC4 (power-board connector pin 2).
  - **Mode 3**: clock idles high (CKP=1), data changes on the falling edge and is sampled on the rising edge (CKE=0, SMP=0).
  - **125 kHz** (Fosc/64), MSB first.
  - **There is no chip select.** Frames are only delimited by timing (see below).
- The exchange is full duplex. While the display board clocks its 11-byte frame out, it clocks the power board's 11-byte frame in: byte *n* received belongs with byte *n* sent.

### Timing

- A frame starts every **30 ms** (`spi_period` = 6 × 5 ms).
- Bytes are **not** sent back-to-back. After each byte the SSP interrupt waits 9 timer0 ticks (≈ **1.7 ms**) before the timer0 ISR writes the next byte to SSPBUF.
  - One frame therefore lasts about 18 ms, followed by roughly 12 ms of silence.
  - A slave can resynchronise on the long gap between frames.
- A received frame only counts if byte 0 is `0x0B` and the checksum matches.
- After **2.5 s** without a valid frame (`link_timeout` = 50 × 50 ms), the display board:
  - clears its copy of the machine state, which blanks the screen;
  - sets `ui.link_lost`.

### Checksum

`chk = (0x55 + byte[0] + … + byte[9]) & 0xFF`, sent as byte 10. Both directions use it.

### Display → power board (`spi_tx`)

| # | Content |
|---|---------|
| 0 | `0xB0` |
| 1 | key bitmap (below) |
| 2 | encoder position: free-running 8-bit counter, +1 per clockwise detent, −1 per counter-clockwise detent |
| 3 | `0x14` (constant; meaning unknown, maybe a board/protocol id) |
| 4 | RTC hours, **binary** (0..23) |
| 5 | RTC minutes, binary |
| 6 | RTC seconds, binary |
| 7 | bit 7: clock was set by the user (RTC valid); bits 3..6: number of keys held; bit 1: encoder push button |
| 8 | EEPROM byte 2 (config byte, 0x65 in the dump; only taken if byte 3 is its complement, otherwise 0) |
| 9 | EEPROM byte 0 (number of languages in the EEPROM, 0x0F in the dump) |
| 10 | checksum |

Key bitmap (byte 1). Keys are debounced over two full matrix scans (~16 ms).

| bit | key | matrix |
|-----|-----|--------|
| 0 | 1 cup | RA2 × RB7 |
| 1 | 2 cups | RA2 × RB6 |
| 2 | hot water (also "OK") | RA1 × RB7 |
| 3 | menu / P | RA0 × RB7 |
| 4 | on/off | RA0 × RB6 |
| 5 | always 0 | |
| 6 | cappuccino | RA2 × RB5 |
| 7 | clean (also "ESC") | RA1 × RB6 |

The key names come from `io_ports_map.txt`. The "OK" and "ESC" roles come from the "PRESS ESC + OK" alarm, which tests exactly these two keys, and from the clock menu, where hot water commits the new time.

Example (no key, encoder 0, 12:34:56, clock set, EEPROM as in the dump):
`B0 00 00 14 0C 22 38 80 65 0F 73`

### Power board → display (`spi_rx`)

| # | Name in the C | Content |
|---|---------------|---------|
| 0 | | `0x0B` (the frame is dropped otherwise) |
| 1 | `pb_state` | bits 0..5: machine state (table below); bit 7: menu item open / confirm |
| 2 | `pb_param1` | bits 0..4: sub-state; bit 5: two cups; bit 6: cappuccino; bit 7: context dependent. In menus it holds a value (BCD hour, language, option…) |
| 3 | `pb_param2` | drink selection and taste in state 0x07 (below); a value in menus / tests |
| 4 | `pb_flags1` | settings (below) |
| 5 | `pb_flags2` | bits 0..3: **language index**; bit 4: cup light on; bit 5: milk container missing *(inferred)* |
| 6 | `pb_flags3` | sensors (below) |
| 7 | `pb_flags4` | alarms (below) |
| 8 | `pb_flags5` | bits 0..1 + bits 2..4: brew unit fault sub-codes; bit 5: "LESS COFFEE"; bit 6: fault detail flag; bit 7: descaling, "EMPTY THE DRIP TRAY" step |
| 9 | `pb_b9` | progress 0..100, shown as a 10-block bar |
| 10 | | checksum |

Example (ready, espresso, standard taste, beep + 24 h clock):
`0B 07 00 04 06 00 00 00 00 00 71`

#### Machine states (`pb_state & 0x3F`)

| state | screen (English texts) |
|-------|------------------------|
| 0x00 | standby: clock (if set), "INSERT TANK", "INSERT GROUNDS CONTAINER", "Self-diagnosis" (sub-state < 2); the backlight goes off after a while |
| 0x01 | warm-up: "Heating up / Please wait", or "Rinsing" + progress |
| 0x02 | "Turning off / Please wait" |
| 0x04 | descaling sequence (sub-state 0..5): "Add descaler / Confirm?", "Descaling underway", "EMPTY THE DRIP TRAY", "Rinsing complete"… |
| 0x07 | ready (sub-state 0: drink + taste, maintenance reminders), brewing (sub-state ≥ 1: "1 ESPRESSO COFFEE"…, progress bar, "Program quantity") |
| 0x08 | "Rinsing" (+ progress from sub-state 5) |
| 0x0A | milk drinks: "INSERT MILK CONTAINER", "Cappuccino" / "Frothed milk" + scrolling "Preparation underway…" |
| 0x0B | hot water: "INSERT WATER SPOUT", "Hot water" + progress |
| 0x0C | "Cleaning" + progress |
| 0x0D | first start: "Press OK to install ENGLISH". The language shown is `pb_param2` |
| 0x0E | hot water prompt: "Hot water / Confirm?" |
| 0x0F | "Heating up" / "Please wait" |
| 0x11..0x1F, 0x26..0x29 | settings menu (see `reimplem/src/ui_menu.c`) |
| 0x21 | display + button test |
| 0x22 | load test: HEATER / GRINDER / PUMP / EV1 / EV2 / VAPORIZER / MOTOR UP / DOWN |
| 0x23 | electric test steps (`pb_param2`): LEDs, backlight, cup light, LCD patterns |
| 0x24 | "ELECTRIC TEST MODE" |
| 0x25 | "ENERGY SAVING" |
| others | blank |

Menu items:

| state | item | notes |
|-------|------|-------|
| 0x11 | adjust time | p1/p2 = BCD hour/minute, p1 bit 7 = editing minutes |
| 0x12 | set language | p1 = language |
| 0x13 | auto-start on/off | |
| 0x14 | descaling | |
| 0x15 | temperature | p1 = level 0..3 |
| 0x16 | auto-off | p1 0..4 = 15 min / 30 min / 1 h / 2 h / 3 h |
| 0x17 | water hardness | p1 = level 0..3 |
| 0x18 | default values | |
| 0x19 | replace filter | |
| 0x1A..0x1E | statistics | coffee / descaling / water / filter / milk, p1:p2 = 16-bit count |
| 0x1F | install filter | |
| 0x26 | beep | |
| 0x27 | energy saving | |
| 0x28 | cup lighting | |
| 0x29 | auto-start time | |

#### `pb_param2` in state 0x07

- bits 1..3: drink.

  | value | drink |
  |-------|-------|
  | 0 | MY COFFEE |
  | 2 | ESPRESSO |
  | 4 | STANDARD |
  | 6 | LONG |
  | 8 | EXTRA LONG |

  While brewing, the message is `drink + 2` (+1 for two cups).
- bits 4..6: taste.

  | value | taste |
  |-------|-------|
  | 0 | pre-ground |
  | 1..5 | extra-mild … extra-strong |
  | 6 | pre-ground |
  | 7 | program quantity |

- bit 0: "Please wait" phase while brewing. bit 6: show "Hot water" on line 2. bit 7: programming the quantity.

#### `pb_flags1` (settings)

| bit | meaning |
|-----|---------|
| 0 | hide the indicator glyph 0x10 next to the clock (auto-start off?) *(inferred)* |
| 1 | 24 h clock (else 12 h with AM/PM) |
| 2 | beeper enabled: the buzzer only sounds when this is set |
| 3 | cup lighting enabled |
| 4 | energy saving enabled |
| 5 | "Press CLEAN button" reminder (hides the descale/filter reminders) |
| 6 | energy saving active: backlight at 50 %, "Energy Saving" on line 2 |
| 7 | water filter installed |

#### `pb_flags3` (sensors)

| bit | meaning |
|-----|---------|
| 0 | water spout in place (else "INSERT WATER SPOUT") |
| 1 | brew unit upper limit switch (load test) |
| 2 | brew unit lower limit switch (load test) |
| 3 | grounds container missing |
| 4 | water tank missing |
| 5 | unknown; a change of bit 0 or bit 5 beeps |

#### `pb_flags4` (alarms, in `ui_alarm()` priority order)

| bit | meaning |
|-----|---------|
| 6 (+7) | brew unit / general fault: "GENERAL ALARM!", "INSERT INFUSER ASSEMBLY", "PRESS ESC + OK" (see `ui_alarm.c`) |
| 1 | grounds alarm: "INSERT GROUNDS CONTAINER" if `pb_flags3.3`, else "EMPTY GROUNDS CONTAINER" (ready state only) |
| 0 | "FILL TANK" (suppressed during the start of some cycles) |
| 5 | beans empty: "FILL BEANS CONTAINER" / "ADD PRE-GROUND COFFEE" |
| 4 | "GROUND TOO FINE / ADJUST MILL", alternating with "INSERT WATER SPOUT" |
| 2 | descale needed ("DESCALE" reminder) |
| 3 | replace filter ("REPLACE FILTER" reminder) |

## 2. UART service mode

**Entering it:** hold **only the encoder push button** while powering up.

- The display shows "UART MODE" and the SPI link stops.
- It lasts 30 s. Every valid frame extends it to 10 s from that frame.
- After that, the board switches back to SPI.

**Line settings:** 9600 baud (SPBRG=12, BRGH=0 at 8 MHz), 8 data bits, no parity.
The PIC transmits a 9th bit set to 1, so what goes out looks like 8N2. It receives 8N1.

**Frames:** `header, len, cmd, args…, chk`, where `chk = 0x55 ^ byte[0] ^ … ^ byte[len-1]` is sent at index `len`.

- The request header is `0x0A`, and `len` must be below 23.
- The reply header is `0xA0`.
- The reply is written over the request, so the address bytes are echoed.
- The receiver drops a frame after a 10 ms gap. It ignores input while a reply is being sent and for 10 ms after it.

| request | reply | action |
|---------|-------|--------|
| `0A 05 10 AH AL chk` | `A0 15 95 AH AL d0..d15 chk` | read 16 EEPROM bytes at AH:AL |
| `0A 15 85 AH AL d0..d15 chk` | `A0 06 85 AH AL ok chk` | write 16 bytes (ok = 1). If the EEPROM is still busy with the previous write (~5 ms): ok = 0, nothing written |
| `0A 03 26 chk` | `A0 05 26 SH SL chk` | 16-bit sum of the first 16 KiB (EEPROM byte 0 < 9) or 32 KiB of the EEPROM |

For example, to read the first message of the English table: `0A 05 10 00 14 5E`.

## 3. What a replacement display board has to do

To stay compatible with the stock power board, a replacement display board must at minimum:

1. **Be the SPI master** (mode 3, ~125 kHz, no chip select).
   - Exchange an 11-byte frame about every 30 ms, with ~1.7 ms between bytes.
   - Sending bytes back-to-back is untested: the power board may need the gaps.
2. **Fill in the outgoing frame:**
   - the key bitmap and key count;
   - an encoder counter;
   - the constant 0x14;
   - the time in binary, with bit 7 of byte 7 set only if the clock is valid;
   - EEPROM bytes 2 and 0. The power board may depend on these; the stock values are `0x65` and `0x0F`.
3. **Handle the local devices:**
   - drive the buzzer itself when asked (key click, alarm beeps), but only if `pb_flags1.2` is set;
   - drive the cup light from `pb_flags2.4`;
   - keep time itself: the RTC lives on the display board, and the power board sets it through menu state 0x11.
4. **Render the text:** the power board only sends states, so every screen text lives on the display board (external EEPROM in 15 languages plus the ROM messages).
