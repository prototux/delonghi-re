# ECAM 23.450 display board firmware (PIC16F916)

This document goes with the C reimplementation in `reimplem/`. The power board protocol has its own document: `protocol.md`.

## Hardware as seen by the firmware

| Pin | Use | Notes |
|-----|-----|-------|
| RA0..RA2 | keypad rows | driven low one at a time |
| RA3 / RA4 | ESC / OK LEDs | active low; driven at 50 % PWM when "on", blink at 2 Hz when in `led_blink` |
| RA5 | J2 pin 1 | unused |
| RA6 | LCD backlight | active low (see below) |
| RA7 | cup light | follows `pb_flags2.4` |
| RB1 | EEPROM /WC | low only during a write |
| RB2 | LCD /RST | |
| RB3 / RB4 | I2C SDA / SCL | bit-banged |
| RB5..RB7 | keypad columns | |
| RC0 / RC1 | encoder A / B | |
| RC2 | encoder push | |
| RC3 | 74HC4052 select | 1 = SPI, 0 = UART |
| RC4 | SPI SDO | power board connector pin 2 |
| RC5 | buzzer | CCP1 PWM, ~3.97 kHz, 50 % |
| RC6 / RC7 | UART TX/RX or SPI SCK/SDI | through the 74HC4052 |

The polarities are confirmed by the schematic (`files/machines/ECAM_23.450/display_board_schematics.pdf`):
- The rows (Q4/Q7/Q8) and LEDs (Q5/Q6) are driven through BC807 PNP transistors, and the backlight (Q2) and cup light (Q1) through BCP51 PNPs, on a −5 V supply, so they are all **active low**.
- The key columns and encoder contacts read 1 when closed.

In standby the firmware stops the backlight PWM (RA6 high, backlight off) when `dim_timer` runs out, and restarts it when a key is pressed.

The schematic also names the keys:
- SW2 "Heißwasser / Menü bestätigen" (hot water = OK);
- SW4 "Spülen / Menü verlassen" (rinse = ESC, called CLEAN in the C and in the English texts);
- SW1 on the knob, "Kaffeestärke" (push = coffee strength), where rotating sets the quantity or menu item.

The LCD is a TM202SIFSUGWA (2×20, ST7036i) and the RTC an M41T00.

**Oscillator and config:** internal RC at 8 MHz (2 MIPS). Config word `0x33CC`: INTOSCIO, WDT on, power-up timer on, MCLR off (RE3 is an input), BOR on, no code protection.

**I2C bus** (bit-banged, ~50–80 kHz, push-pull SCL, no clock stretching):

| address | device | use |
|---------|--------|-----|
| 0x78 | ST7036 LCD controller | 2 × 20 characters |
| 0xD0 | M41T00 RTC | 8 BCD registers |
| 0xA0 | M24256 EEPROM | 32 KiB: texts and header |

The SSP module is **not** used for I2C. It is the SPI link to the power board.

## Architecture

It is a superloop with no RTOS. Five interrupt sources feed flags and buffers.

```
main()  (main.c)
  init: hw_init, timers_init, rtc_init, lcd_init(0), eeprom_load_config
  forever:
    timebase_update()   5/50/500 ms ticks and all software timers
    keypad_scan()       one matrix row per ~2 ms, debounce, key bitmap for the power board
    encoder_poll()      quadrature decode, enc_count, CW/CCW events
    link_update()       start an SPI frame every 30 ms, parse the power board frame, UART service frames
    if started (150 ms after boot):
      service_update()  service mode entry (first pass), RTC re-read every 500 ms, set clock
      ui_update()       machine state -> messages / LEDs / overlay, then display_refresh()

isr()  (isr.c)
  SSP     one SPI byte done; schedule the next one
  timer0  ~192 us: buzzer, SPI pacing, LED PWM, idle detection, keypad delay, 5 ms tick
  timer1  ~430 us: backlight PWM
  UART RX/TX  service mode frames
```

The UI is **stateless on the display side**. `ui_update()` recomputes the whole screen from the last power board frame on every pass:

1. It picks a handler from `pb_state & 0x3F`.
2. Most handlers call `ui_alarm()` first. If an alarm is active, its screen wins.
3. The handler sets `line1_msg` and `line2_msg`, the LEDs, and optionally the 10-character overlay (`field[]`) or the progress bar.
4. `display_refresh()` redraws a line whose message changed, 5 characters per pass.

On top of that, every line is redrawn every 2.5 s and the LCD is re-initialised every 15 s, to recover from glitches.

## Module map

| C (reimplem/src) | function | orig. address | old name (displayboard.asm / legacy_decompiled) |
|---|---|---|---|
| main.c | `main` | 0x0070, 0x1004 | main, ENTRY_SUB_AND_MAINLOOP |
| | `hw_init`, `timers_init` | 0x1F47, 0x1E8B | init_hardware_1, init_hardware_2 |
| isr.c | `isr` + handlers | 0x0004, 0x1E5B, 0x1F97, 0x1EBF, 0x1EFE, 0x19C4 | _interrupt, interrupt_handler_* |
| timebase.c | `timebase_update` | 0x0723 | MAINLOOP_SUB1 |
| keypad.c | `keypad_scan` | 0x12CB | MAINLOOP_SUB2 |
| encoder.c | `encoder_poll` | 0x10D8 | MAINLOOP_SUB3 |
| softi2c.c | `softi2c_start/write/read/stop/delay`, `softi2c_bus_init` | 0x1647, 0x161B, 0x15F5, 0x16D2, 0x16DF, 0x16E8 | Aline, Alice, Elsa, Agathe, Anais, Eleonore |
| i2cmem.c | `i2c_read_block`, `i2c_write_block` | 0x165B, 0x172E | Caroline, Cecile |
| | `eeprom_load_config`, `eeprom_checksum` | 0x16E8, 0x1795 | Eleonore, Clemence |
| rtc.c | `rtc_buf_invalid`, `rtc_init` | 0x14E4, 0x1507 | Eloise, init_something_2 |
| lcd.c | `lcd_write`, `lcd_init`, `lcd_putc_at`, `lcd_write_field` | 0x00FD, 0x0123, 0x01E9, 0x0832 | Adele, Emy, Eva, Emma |
| text.c | `text_load_line`, `text_load_scroll` | 0x13BD, 0x121A | Emilie, Clara |
| display.c | `display_refresh` | 0x087E | Elodie |
| pblink.c | `link_select`, `link_checksum`, `link_update`, `spi_send_frame`, `uart_reply_*` | 0x0467, 0x0490, 0x05B8, 0x0540, 0x04AD/0x04D9/0x0500 | USART_MAYBE_CONFIG, USART_MAYBE_CHECKSUM, USART_MAYBE_LOGIC, SSP_SEND_1, USART_PACKET_SEND_1/2/3 |
| service.c | `service_update` | 0x1559 | Coralie |
| ui_main.c | `ui_update` | 0x0AC6 | MAINLOOP_MAIN_LOGIC |
| ui_menu.c | `ui_menu` | 0x01F5 | MAINLOOP_MAIN_LOGIC_SUB2 |
| ui_alarm.c | `ui_alarm` | 0x0961 | Elona |
| ui_format.c | `format_time`, `format_number` | 0x1048, 0x116F (+ 0x00C3) | MAINLOOP_MAIN_LOGIC_SUB1, Eliana (+ Elise) |
| util.c | `bcd_to_bin`, `delay_ms` | 0x14CE (+ 0x1A29), 0x1E71 | Evelise (+ Eloane), delay_2ms |
| romdata.c | ROM messages, CGRAM glyphs | 0x0800, 0x1800.., 0x1A35 | |
| — | C runtime (RAM init, fetch_data), 16-bit multiply | 0x0094..0x00C2, 0x19EE | memclear, init_ram_with_data, fetch_data, Estelle |
| — | dead code, never called | 0x1A03, 0x1A16, 0x1E7F | deadcode_1..3 |

`include/state.h` lists every RAM variable with its original address, and `tools/symbols.py` uses the same names.

## Timing

| what | period |
|------|--------|
| timer0 interrupt | ~192 µs (TMR0 = 0xFD, prescaler 1:128) |
| tick | 5 ms (26 timer0 ticks), 50 ms, 500 ms |
| keypad | one row per ~1.9 ms, full scan ~7.7 ms; a key needs 2 consecutive scans |
| SPI frame | every 30 ms, one byte every ~1.7 ms |
| link lost | 2.5 s without a valid frame |
| key click / alarm beep | 50 ms / 250 ms |
| LED blink | 250 ms on / 250 ms off |
| marquee | 1 s pause, then one character every 350 ms |
| periodic redraw / LCD re-init | 2.5 s / 15 s |
| `delay_2ms()` | really **~1.0 ms** per unit (2020 cycles at 2 MIPS), so it is renamed `delay_ms` |

## External EEPROM layout (M24256)

| address | content |
|---------|---------|
| 0x0000 | number of languages (0x0F). Below 9, only the first 16 KiB count for the service checksum |
| 0x0001 | 0xFF (unused) |
| 0x0002 / 0x0003 | config byte and its complement (0x65 / 0x9A), forwarded to the power board |
| 0x0004..0x0013 | 0xFF |
| 0x0014 + (lang·100 + id)·20 | message `id` (0..99) of language `lang`, 20 characters, not NUL terminated |

Messages 0xC8..0xDD are in ROM: test mode texts, "UART MODE", "PRESS ESC + OK", "ENERGY SAVING", and patterns. See `reimplem/src/romdata.c` and `reimplem/include/fw.h`.

In the dump, language 0 is English and language 1 is German. `language` comes from `pb_flags2 & 0x0F`.

**CGRAM glyphs** loaded at init:

| glyph | pattern |
|-------|---------|
| 0 | upper half block |
| 1 | `04 04 04 06 0C 04 04 00` |
| 2 | `08 1C 08 09 06 08 04 00` |
| 3 | same data as glyph 2 |

The progress bar uses 0xFF (full block) on `_`. The level bars use 0xFD / 0x6F from the ST7036 ROM font.

## Corrections to the earlier notes

- The SSP runs as an **SPI master**, not I2C. On the PIC16F91x, SCK/SDI share RC6/RC7 with the UART and **SDO is RC4**. RC4 is therefore the SPI data output to the power board, not an unknown GPIO.
- The UART only exists for the EEPROM service mode. The packet types in `serial_com.md` are service replies:
  - type 1 is the reply to command 0xB3 (EEPROM sum);
  - type 2 is the reply to the write command;
  - type 3 is the reply to the read command.
- The RX header is 0x0A and the TX header is 0xA0. Both checksums are seeded with 0x55: SPI sums the bytes, the UART XORs them.
- `Cecile`/`Caroline` are generic I2C block write/read routines used for both the EEPROM (16 bytes) and the RTC (8 bytes). `Clemence` is the EEPROM checksum, not an RTC driver.
- The soft-I2C read loop reads 8 bits (the legacy C had 7).
- The v20 and v30 firmware images in `files/` are identical.

## Open questions

- `pb_flags4.6/.7`, `pb_flags5` bits 0..4 and 6: which brew-unit faults they encode.
- Byte 3 of the display→power frame (`0x14`) and EEPROM byte 2 (`0x65`): does the power board check them?
- `fx.b1`, `ui.b2`, `pb_flags1.0` / glyph 0x10: meaning unknown (see comments in the C).
- The exact connector pinout and voltage levels of the UART path through the 74HC4052: check the schematic.

## Emulator

`emulator/` runs the original firmware on an emulated PIC16F916, with the LCD, RTC, EEPROM and a stub power board. Its end-to-end tests (`emulator/test/`) confirm most of what this document describes; see `emulator/README.md`.
