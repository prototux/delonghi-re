# Display board firmware (PIC16F916)
#
#   make          build/displayboard.hex with Microchip XC8 (see ../xc8.mk)
#   make dfp      download the PIC16Fxxx device family pack XC8 needs
#   make check    syntax/type check with the host compiler (no PIC toolchain
#                 needed): catches typos and prototype mismatches only.
#
# Test the build in the emulator: ../emulator/test/run.html?dfw=<path of the .hex>

SRC  := $(wildcard src/*.c)
CHIP := 16F916
DFP_NAME    := PIC16Fxxx_DFP
DFP_VERSION := 1.9.176
include ../xc8.mk

# -mstackcall: the PIC16F916 has an 8-level hardware stack. The deepest
# path (main -> ... -> ___wmul, 6 calls) plus an interrupt (return address
# + handler) plus a const table read (a CALL into a RETLW table) needs 9, so
# without it the stack wraps and the firmware ends up in a watchdog reset
# loop. XC8 then turns the calls that would go too deep into table jumps.
XC8FLAGS := -mcpu=$(CHIP) -mdfp=$(DFP) -O2 -mstackcall -Iinclude

.PHONY: all check clean

all: build/displayboard.hex

build/displayboard.hex: $(SRC) $(wildcard include/*.h)
	$(need_dfp)
	@mkdir -p build
	$(XC8) $(XC8FLAGS) -o $@ $(SRC)

check:
	$(CC) -fsyntax-only -std=c11 -Wall -Wextra -Wno-main -Wno-unknown-pragmas -Iinclude -Ihost $(SRC)

clean:
	rm -rf build
