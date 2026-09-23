# ECAM 23.450 display board emulator

This emulator runs the **original display board firmware** (or any PIC16F916 image, including the C rebuild in `../reimplem` once it has been compiled with XC8) on an emulated PIC.
The power board on the other end of the SPI link is either:
- **a stub state machine** (default): quick, and every screen and alarm can be forced from the side panel;
- **the real power board firmware** on an emulated PIC18F4525, driving a physical model of the machine (thermoblocks, pump and flowmeter, grinder, brew unit, switches). Choose "real firmware" in the Power board box, or open the page with `?pb=real`.

![front panel](../docs/emulator.png)

## Running it

The page loads the firmware and EEPROM images from `files/`, so serve the **repository root** over HTTP:

```sh
cd <repo root>
python3 -m http.server 8000
# then open http://localhost:8000/ecam23.450_displayboard_reverse/emulator/web/
```

You can also load other images from the "Emulator" box: a `.bin` dump or an XC8 `.hex` for the firmware, a 32 KiB `.bin` for the EEPROM.

**Controls:**

| Control | Mouse | Keyboard |
|---------|-------|----------|
| Buttons | click (hold for long presses) | <kbd>Q</kbd> on/off, <kbd>W</kbd> P/menu, <kbd>E</kbd> rinse/ESC, <kbd>I</kbd> 1 cup, <kbd>O</kbd> 2 cups, <kbd>P</kbd> hot water/OK, <kbd>C</kbd> cappuccino |
| Knob | drag the ring, use the wheel, or click the centre to push | <kbd>←</kbd> <kbd>→</kbd> to turn, <kbd>↓</kbd> to push |
| Pause | | <kbd>Space</kbd> |

**Service mode:** use "Restart in service mode" (or hold the knob while pressing "Power cycle"). You can then send the UART service commands from the side panel.

**Side panel:**
- **Power board:** stub or real firmware, the state it reports, and (stub) its settings and counters.
- **Machine** (real firmware only): take out the water tank, empty it, remove the grounds container (this empties it) or the hot water spout, run out of beans. It also shows both thermoblock temperatures, the brew unit position (and the travel the firmware measured), the water pumped, the pucks in the grounds container, and which loads are on.
- **Alarms & sensors:** remove the tank, fill the grounds container, run out of beans, and so on.
- **Manual frame:** send any power board frame, with presets for the factory test modes (display/button test, load test, electric test steps, …).
- **SPI frames:** the last frames in both directions, decoded.
- **Emulator:** pause, speed, power cycle, LCD colour, and whether the RTC starts as "set".

`?demo=standby|ready|brew|menu|alarm|cappu` runs a scripted sequence before the first frame. It is handy for screenshots. With `?pb=real`, `?demo=warmup|coffee` does the same on the real power board firmware.

## Tests

`test/scenarios.js` boots the firmware and drives it through:
- boot and standby;
- warm-up, brewing and the progress bar;
- alarms;
- the menu and a language change;
- setting the clock;
- losing the power board link;
- the factory test modes;
- UART service mode: read, write and EEPROM checksum.

A last scenario, `realpb`, runs both original firmwares together against the machine model: warm-up, a coffee (grind, compaction, pre-infusion, dose, puck ejection), then a coffee with an empty bean hopper.

Each run checks the LCD text, the RTC, the buzzer and the SPI traffic. All 50 checks pass.

```sh
node test/run.mjs                 # or: node test/run.mjs brew,menu
# without Node: serve the repo and open emulator/test/run.html
```

## What is emulated

| Part | Model |
|------|-------|
| `core/pic16f916.js` | Full 35-instruction core with banking, 8-level stack and cycle counts. Peripherals: TMR0 with prescaler and write inhibit, WDT (resets are counted), TMR1, TMR2 + CCP1 PWM, SSP (SPI master), USART with baud timing, ports with read-modify-write on the pins, interrupts. The oscillator follows OSCCON. |
| `core/i2c.js` | Bit-level open-drain I2C bus with the ST7036 LCD (DDRAM, CGRAM, instruction set), the M41T00 RTC (runs in emulated time, ST/OUT bits) and the M24256 EEPROM (64-byte pages, /WC pin, 5 ms busy after a write). |
| `core/board.js` | Key matrix and encoder (active levels taken from the schematic), the 74HC4052 link mux, and the LED / backlight / cup light / buzzer outputs, sampled as duty cycles. |
| `core/powerboard.js` | SPI slave and a plausible machine state machine: standby → warm-up → rinse → ready, brewing, milk, hot water, rinse, the settings menu, alarms. **It is not the real power board firmware.** Timings and sequences are invented; the screens are the real firmware's. |
| `core/pic18f4525.js` | PIC18 core (full instruction set, indirect addressing, shadow registers, 31-level stack), TMR0-3, CCP1 capture, ADC, MSSP as SPI slave, EUSART, data EEPROM writes, WDT, interrupts. |
| `core/realpb.js` | The real power board firmware on that core, with the same interface as the stub. |
| `core/plant.js` | The machine around the power board: 50 Hz mains and zero-cross, two thermoblocks with NTCs, pump and flowmeter, grinder, brew unit motor with its encoder and switches (the top switch closes earlier with more coffee in the chamber), tank, water level, grounds container, spout. The constants are fitted to the firmware's own thresholds (see `docs/powerboard.md`), not measured. |
| `web/` | The front panel. The LCD uses a 5×7 font; the ST7036's European/Cyrillic ROM codes are mapped from the texts (best effort), and CGRAM glyphs come from the emulated controller. |

The screen is recomputed from the real firmware and real EEPROM contents, and the timings are those of the firmware.
Two caveats:
- The encoder is modelled as a hand-turned knob, 15 ms per quadrature phase. The firmware polls it once per main-loop pass, and a pass can take ~12 ms while the LCD is being redrawn.
- The LCD font for codes ≥ 0x80 is a reconstruction.

## Recording the power board for the C reconstruction

`test/pb_trace.html` runs both firmwares through a long session (brews, hot water, cappuccino, menu, alarms, UART service commands, factory tests). It records calls of the original power board functions: RAM and SFRs at entry, RAM at return. `pb_reimplem/` replays the records against its C code (`make difftest`, see `pb_reimplem/README.md`). The records are POSTed to `/log`: serve the repository root with `python3 emulator/test/logserver.py trace.log` instead of `http.server`, open `…/emulator/test/pb_trace.html` and wait for `__END__` at the end of `trace.log` (about 3 minutes).

## Findings made with the emulator

- The UART service command codes are **0x85 / 0x95 / 0xB3**. The static analysis had read them as 0x85 / 0x10 / 0x26; that is fixed in `reimplem/` and `docs/`.
- When the power board link is lost, the text lines blank, but the standby clock overlay stays frozen on screen. This is a quirk of the original firmware, reproduced here.
- The service mode EEPROM checksum takes about 11 s: 32 KiB go through the bit-banged I2C.
- Power board: the brew unit stroke up to the top switch measures the coffee dose. A short stroke means *too much* coffee ("LESS COFFEE"), not too little. The analysis notes had it the other way round.
