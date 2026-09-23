# Display board firmware (PIC16F916)
#
#   make          build with Microchip XC8 (xc8-cc must be in PATH)
#   make check    syntax/type check with the host compiler (no PIC toolchain
#                 needed): catches typos and prototype mismatches only.

SRC  := $(wildcard src/*.c)
CHIP := 16F916

.PHONY: all check clean

all: build/displayboard.hex

build/displayboard.hex: $(SRC) $(wildcard include/*.h)
	@mkdir -p build
	xc8-cc -mcpu=$(CHIP) -O2 -Iinclude -o $@ $(SRC)

check:
	$(CC) -fsyntax-only -std=c11 -Wall -Wextra -Wno-main -Wno-unknown-pragmas -Iinclude -Ihost $(SRC)

clean:
	rm -rf build
