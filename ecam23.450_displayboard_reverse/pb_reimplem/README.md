# ECAM 23.450 power board firmware in C

This is a C reconstruction of `files/machines/ECAM_23.450/power_board_unknown_v1.0_firmware.bin` (PIC18F4525, HI-TECH PICC-18).

It follows the original function by function:
- Every function keeps its original address in a comment.
- The behaviour is kept exactly, including the oddities, which are commented.
- Compiler artefacts are collapsed into plain C: the maths helpers, bank switching, XOR switch chains and the compiler's shared scratch bytes.

`../docs/powerboard.md` describes what the firmware does. Read it first.

## Layout

| File | Content |
|---|---|
| `src/main.c` | startup, `main` loop, `hw_init`, watchdog kick, config words |
| `src/isr.c` | interrupt dispatch, TMR0 (triac gates, heater burst firing), TMR2 (1 ms), CCP1 (mains zero-cross, 50/60 Hz) |
| `src/timebase.c` | timers, 10 ms / 100 ms / 1 s / 10 s ticks and all the countdowns |
| `src/adc.c` | the two NTC channels |
| `src/io.c` | switch inputs (debounce, AC-sensed switches), load outputs, relay and standby (`power_task`) |
| `src/eeprom.c` | the three EEPROM records (two copies + CRC-16 each), load, save, defaults |
| `src/spi_link.c` | SPI slave link with the display board, reply frame |
| `src/service_uart.c` | 19200-baud service port: status, remote load test, parameter read/write |
| `src/machine_control.c` | keys and encoder → machine state: on/off, drinks, milk, hot water, rinse, descaling, faults, auto-start, energy saving |
| `src/menu.c` | the settings menu |
| `src/grinder_adapt.c` | adaptive grinder dose from the measured brew unit stroke |
| `src/state_control.c` | per-tick supervisor: the steps of every state, power-up key combos, auto-off |
| `src/faults.c` | alarms and faults (`monitor_faults`) |
| `src/heaters.c` | coffee / steam thermoblock regulation and power sharing, valves |
| `src/water.c` | pump (flowmeter volume) and grinder |
| `src/brew_unit.c` | brew unit motor (soft start, position, limit switches) |
| `src/sequencer.c` | "wait for units, then next step", progress bar, counters |
| `src/test_modes.c` | factory test modes (load test, automatic test, remote test, …) |
| `src/units.h` | bit masks shared by the unit drivers |
| `src/*.vars`, `src/*.protos` | the globals (type, name, original address) and exported functions of each area |
| `include/pb.h`, `src/globals.c` | **generated** from the `.vars`/`.protos` files by `tools/gen_header.py` |
| `host/` | host-side `xc.h` stand-in, SFR storage and the differential test harness |

The globals keep the names of `../tools/pb_symbols.py`, so the C and the disassembly listing (`../tools/pic18dis.py`) can be read side by side.

## Building and checking

```sh
make dfp        # once: download the PIC18Fxxxx device family pack into ~/.mchp_packs
make            # build/powerboard.hex with XC8 (the newest one under /opt/microchip/xc8)
make header     # regenerate include/pb.h after editing a .vars/.protos file
make check      # host compiler syntax/type check (-Wall -Wextra, clean)
make link       # host link: every function defined exactly once
make difftest TRACE=trace.log   # compare with the original binary, see below
```

XC8 v4.00 builds it without warnings: 31786 of 49152 bytes of flash (the original uses about 34 KB) and 523 bytes of RAM. The configuration words match the original's.

The build has no data EEPROM contents. On a blank chip `ee_load` finds no valid record and uses the defaults, like a factory-fresh board. The emulator starts it with the EEPROM of the original dump.

**The XC8 build runs in the emulator.** `../emulator/test/run.html?pbfw=ecam23.450_displayboard_reverse/pb_reimplem/build/powerboard.hex` runs the 56 checks of the emulator's scenarios with it. That includes a full coffee against the machine model: warm-up, rinse, grind, compaction, dose and puck. They all pass, with the original display firmware and with the XC8 build of `../reimplem/` (`&dfw=...`). Nothing has been run on hardware yet.

## Differential test against the original binary

Compiling cleanly only shows that the C is consistent with itself. The differential test shows that it *behaves like the binary*:

1. **Record.** `../emulator/test/pb_trace.html` runs the original power board and display firmwares together in the emulator, against the machine model. The scripted session covers:
   - warm-up, 1 and 2 cup coffees at different strengths, hot water, cappuccino, rinse, the menu;
   - tank, grounds container and beans alarms;
   - every UART service command;
   - four factory test modes started with the power-up key combos.

   Each time the PIC reaches a function entry through a CALL, it saves RAM and SFRs. When the function returns, it saves the RAM and the output SFRs.
2. **Replay.** `build/difftest` loads each "before" snapshot into the C globals and the SFR page, calls the C function, and compares every global plus the output SFRs with what the original left:
   - the output SFRs are the port latches, TRIS, the timer, CCP, ADC, SSP and UART configuration, SSPBUF and TXREG;
   - compiler scratch, which is not a global in C, is not compared.

```sh
# from the repository root
python3 ecam23.450_displayboard_reverse/emulator/test/logserver.py trace.log &
firefox 'http://127.0.0.1:8765/ecam23.450_displayboard_reverse/emulator/test/pb_trace.html?post&cap=500'
# wait for "__END__" at the end of trace.log (about 3 minutes), then
make -C ecam23.450_displayboard_reverse/pb_reimplem difftest TRACE=$PWD/trace.log
```

**Current result: 13 587 recorded calls, 0 differences.**
- The sample covers all 47 exported functions, including the ISR, `state_control`, `machine_control` and every unit driver.
- The main-loop functions are sampled up to 500 times each, spread over the states they ran in.

**What the test does not cover:**
- Paths the session never reaches: descaling, the circuit purge, the first start, most fault recoveries, and 60 Hz mains.
- The EEPROM functions, whose reads need the hardware.
- The exact order of SFR writes inside a call. For example, it does not check the width of a triac gate pulse within one ISR run, only the state it leaves behind.

## Known quirks kept from the original

They are commented in the code. The main ones:
- **SPI resync:** after the last SPI byte, SSPBUF is loaded from the byte after the TX buffer (`uart_buf[0]`). After a rejected frame, that byte is clocked out.
- **Service read overflow:** `svc_read_params` doesn't bound the parameter count, so a count above 4 writes past `uart_buf` (undefined behaviour in C; the original overwrites `ee_buf`).
- **Encoder wrap:** `encoder_poll` loses a two-step wrap of the encoder count.
- **Menu toggles:** for menu items 4, 6, 0x0B and 0x0C, the value opened and the value applied use opposite senses (see `menu.c`).
