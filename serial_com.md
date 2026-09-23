# Serial communication between ECAM 23.450's power and display boards

The full description is in `ecam23.450_displayboard_reverse/docs/protocol.md`.

## Summary

- Normal operation uses **SPI**, not the UART. The display board is the master:
  - mode 3, 125 kHz, no chip select;
  - an 11-byte full-duplex frame every 30 ms, with ~1.7 ms between bytes;
  - display → power: `B0 keys enc 14 hh mm ss flags cfg nlang chk`;
  - power → display: `0B state p1 p2 flags1..5 progress chk`;
  - checksum = 0x55 + sum of bytes 0..9.
- The **UART** (9600 baud) is only a service mode, entered by holding the encoder button at power-up. A PC tool uses it to read and write the text EEPROM:
  - requests start with 0x0A, replies with 0xA0;
  - checksum = 0x55 XOR bytes 0..len-1;
  - commands: 0x95 read 16 bytes, 0x85 write 16 bytes, 0xB3 EEPROM sum.

The "packet types" previously listed in this file were the replies of that service mode:

| earlier name | actually |
|--------------|----------|
| type 1 | reply to 0xB3 (EEPROM sum) |
| type 2 | reply to 0x85 (write) |
| type 3 | reply to 0x95 (read) |
