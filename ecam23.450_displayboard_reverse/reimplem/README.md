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

- `make check`: syntax and type check with the host C compiler. This is the only check run so far.
- `make`: builds with Microchip XC8 (`xc8-cc -mcpu=16F916`). This has not been tried. Expect to adjust:
  - the `#pragma config` names;
  - memory: the PIC16F916 has 352 bytes of RAM, and the original needed almost all of it.

## Status

- Every function of the original is translated, except the C runtime helpers and three pieces of dead code.
- The behaviour is kept as-is, oddities included; comments point them out.
- Nothing has been run on hardware or in a simulator yet.

The old hand decompilation is kept in `../legacy_decompiled/` for reference. It has known errors, listed in `docs/firmware.md`.
