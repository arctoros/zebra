
import sys

# Simplified Z80 opcode cycle table (main opcodes only, real Z80 has many more cases)
# Many opcodes have variable timing depending on addressing mode or conditions.
Z80_CYCLES = {
    0x00: 4,  # NOP
    0x01: 10, # LD BC,nn
    0x02: 7,  # LD (BC),A
    0x03: 6,  # INC BC
    0x04: 4,  # INC B
    0x05: 4,  # DEC B
    0x06: 7,  # LD B,n
    0x07: 4,  # RLCA
    0x08: 4,  # EX AF,AF'
    0x09: 11, # ADD HL,BC
    0x0A: 7,  # LD A,(BC)
    0x0B: 6,  # DEC BC
    # ... fill out more opcodes as needed ...
    0xC3: 10, # JP nn
    0xC9: 10, # RET
    0xCD: 17, # CALL nn
}

CB_PREFIX_CYCLES = {
    0x00: 8,  # RLC B
    0x01: 8,  # RLC C
    # ... fill out CB prefix opcodes ...
}

def read_rom(path):
    with open(path, "rb") as f:
        return f.read()

def decode_and_count_cycles(rom):
    pc = 0
    visited_opcodes = set()
    total_cycles = 0
    length = len(rom)

    while pc < length:
        opcode = rom[pc]
        instr_len = 1
        cycles = 0

        if opcode == 0xCB:
            if pc + 1 < length:
                cb_opcode = rom[pc + 1]
                if (0xCB, cb_opcode) not in visited_opcodes:
                    visited_opcodes.add((0xCB, cb_opcode))
                    cycles = CB_PREFIX_CYCLES.get(cb_opcode, 8)  # Default to 8
                instr_len = 2
            else:
                break
        elif opcode in Z80_CYCLES:
            if opcode not in visited_opcodes:
                visited_opcodes.add(opcode)
                cycles = Z80_CYCLES[opcode]
        else:
            # Unknown opcode; skip 1 byte
            if opcode not in visited_opcodes:
                visited_opcodes.add(opcode)
                cycles = 4  # Safe default
        total_cycles += cycles
        pc += instr_len

    return total_cycles

def main():
    if len(sys.argv) < 2:
        print("Usage: python z80_cycle_counter.py <rom_file>")
        sys.exit(1)

    rom_path = sys.argv[1]
    rom = read_rom(rom_path)
    total_cycles = decode_and_count_cycles(rom)
    print(f"Estimated total cycles for one pass through each instruction: {total_cycles}")

if __name__ == "__main__":
    main()
