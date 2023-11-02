import sys

def calculate_destination(pclath=None, pclath_bits=None, opcode_value=None):
    """Calculate the final destination address given the PCLATH bits and opcode value."""
    if pclath_bits:
        pclath = (pclath_bits[0] << 4) | (pclath_bits[1] << 3)

    pclath_upper = pclath & 0x18
    destination = (pclath_upper << 8) | opcode_value
    return destination

def main():
    if len(sys.argv) < 3:
        print("Usage: script_name.py [pclath_value/pclath_bits] opcode_value")
        return

    pclath_arg = sys.argv[1]
    opcode_value = int(sys.argv[2], 16)

    if "," in pclath_arg:
        bits = tuple(map(int, pclath_arg.split(",")))
        dest_addr = calculate_destination(pclath_bits=bits, opcode_value=opcode_value)
    else:
        pclath_value = int(pclath_arg, 16)
        dest_addr = calculate_destination(pclath=pclath_value, opcode_value=opcode_value)

    print(f"Destination Address: {dest_addr:#04x}")

if __name__ == "__main__":
    main()
