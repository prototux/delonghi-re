# Power board firmware (PIC18F4525), C reconstruction
#
#   make          build with Microchip XC8 (xc8-cc must be in PATH)
#   make header   regenerate include/pb.h and src/globals.c from src/*.vars, *.protos
#   make check    syntax/type check with the host compiler (no PIC toolchain
#                 needed): catches typos and prototype mismatches only.
#   make link     host link: catches duplicate and missing definitions.

SRC  := $(wildcard src/*.c)
CHIP := 18F4525

.PHONY: all header check link difftest clean

all: build/powerboard.hex

build/powerboard.hex: $(SRC) $(wildcard include/*.h)
	@mkdir -p build
	xc8-cc -mcpu=$(CHIP) -O2 -Iinclude -o $@ $(SRC)

include/pb.h src/globals.c host/vartab.c: $(wildcard src/*.vars src/*.protos) tools/gen_header.py
	python3 tools/gen_header.py

header: include/pb.h

check: include/pb.h
	$(CC) -fsyntax-only -std=c11 -Wall -Wextra -Wno-main -Wno-unknown-pragmas -Iinclude -Ihost $(SRC)

clean:
	rm -rf build

# host link check: every function defined exactly once, nothing missing
link: include/pb.h
	@mkdir -p build
	$(CC) -std=c11 -w -Iinclude -Ihost $(SRC) host/sfr.c -o build/host_link && echo "link OK"

# differential test against calls recorded from the original firmware:
#   open emulator/test/pb_trace.html (it POSTs the records to /log, see
#   emulator/README.md), save them as TRACE, then: make difftest TRACE=file
TRACE ?= build/trace.log
HOSTOBJ := $(patsubst src/%.c,build/host/%.o,$(SRC))

build/host/%.o: src/%.c include/pb.h
	@mkdir -p build/host
	$(CC) -std=c11 -O1 -g -w -Dmain=pb_main -Iinclude -Ihost -c $< -o $@

build/difftest: $(HOSTOBJ) host/difftest.c host/vartab.c host/sfr.c host/difftest.h
	$(CC) -std=c11 -O1 -g -w -Iinclude -Ihost $(HOSTOBJ) host/difftest.c host/vartab.c host/sfr.c -o $@

difftest: build/difftest
	build/difftest $(TRACE)
