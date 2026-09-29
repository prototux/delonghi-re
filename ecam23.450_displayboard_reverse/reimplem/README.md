# ECAM 23.450 display board firmware: C reimplementation

This is a readable C version of the display board firmware (PIC16F916, image `5513220041_v30`), rebuilt from the binary.
Each function states the address of the code it replaces, so it can be checked against the disassembly:

```
python3 ../tools/pic14dis.py ../../files/machines/ECAM_23.450/display_board_5513220041_v30_firmware.bin -f ui_alarm
```

The disassembler tracks the RP0/RP1/PCLATH banking, and its symbol table (`tools/symbols.py`) uses the same names as this code.
The Ghidra export (`displayboard.asm`) labels every register as bank 0, which makes accesses like PIE1/TRISx look wrong.

See `../docs/firmware.md` for the architecture and module map, and `../docs/protocol.md` for the power board link.

## Layout

```
include/hw.h      pins, I2C addresses (XC8, <xc.h>)
include/state.h   every RAM variable of the original, with its address
include/fw.h      prototypes (with original address and old name), message IDs
src/              one file per module, see docs/firmware.md
host/xc.h         stand-in for <xc.h> so `make check` works without a PIC toolchain
```

## Building

```sh
make dfp      # once: download the PIC16Fxxx device family pack into ~/.mchp_packs
make          # build/displayboard.hex with XC8 (the newest one under /opt/microchip/xc8)
make check    # syntax and type check with the host C compiler, no PIC toolchain needed
```

XC8 v4.00 builds it without warnings: 7651 of 8192 words of flash and 313 of 352 bytes of RAM. The shared toolchain setup is in `../xc8.mk`. Override it with `make XC8=... DFP=...` for another install.

The build needs `-mstackcall`. The PIC16F916 has an 8-level return stack, and the deepest call path plus an interrupt plus a `const` table read needs 9. Without the option the stack wraps and the firmware sits in a watchdog reset loop. The Makefile has the details.

## Status

- Every function of the original is translated, except the C runtime helpers and three pieces of dead code.
- The behaviour is kept as-is, oddities included; comments point them out.
- The XC8 build runs in the emulator: `../emulator/test/run.html?dfw=ecam23.450_displayboard_reverse/reimplem/build/displayboard.hex` runs the 56 checks of the emulator's scenarios on it, against the stub and against the original power board firmware. They all pass.
- Nothing has been run on hardware yet.

The old hand decompilation is kept in `../legacy_decompiled/` for reference. It has known errors, listed in `docs/firmware.md`.
