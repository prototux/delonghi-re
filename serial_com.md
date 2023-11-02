# Serial communication between ECAM 23.450's power and display boards

This is WIP, based on the reverse engineering of the display board firmware

## Notes

* The communication is packet-baset
* Packets are at most 23 bytes long (0x17)
* First packet seems to be the header
* Second packet seems (with very high confidence) to be the packet size
* Packets 3 to n are the data
* Last byte seems to be a checksum

## Packet type 1 (unknown role)

* header: 0xa0
* size 0x05
* data[0]: unknown
* data[1]: (variable @ bank-1/0x58)
* data[2]: (variable @ bank-1/0x57)
* checksum

## Packet type 2 (unknown role)

* header: 0xa0
* size: 0x06
* data[0]: 0x85
* data[1]: unknown
* data[2]: unknown
* data[3]: (parameter of the function, stored @ bank-0:0x4f)
* checksum

## Packet type 3 (unknown role)

* header: 0xa0
* size: 0x15
* data[0]: 0x95
* data[1]: unknown
* data[n]: unknown
* checksum
