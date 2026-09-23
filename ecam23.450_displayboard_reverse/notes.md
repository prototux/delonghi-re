# Random notes

* The power board connector actually has UART **AND** I2C, the SSP is used to talk to the power board, *not* the devices!
* The devices uses I2C that is bitbang'd, that's going to be fun to reverse..
* The A functions apparently are a software I2C implementation... that explains a lot
* The schematics is wrong, the I2C hardware port is at the same pins as USART, so RC4 is still unknown... it isn't set or accessed in the code as well)
* That also then explains why there's the mux for tx/rx, it isn't to chose if you want your UART in 12V or 5V, it is to chose between (probably) RS232 at 12V and I2C at 5V!
* I would guess that RC4 is a signal from the power board to the display board to set if it should be using UART or I2C, but i don't know for sure...

# Update (from the rebuilt disassembly, see docs/)

* The SSP is used as an **SPI master** (SSPCON=0x32), not I2C. On the PIC16F91x SCK/SDI share RC6/RC7 with the
  UART and **SDO is RC4**, which is why RC4 goes to the power board connector: it is SPI MOSI.
* The 74HC4052 (RC3) selects SPI (normal operation) or UART (service mode, EEPROM programming).
* See docs/protocol.md and docs/firmware.md.
