# 8-bit Single-Cycle CPU in Verilog

A minimal 8-bit single-cycle CPU built from scratch in Verilog for learning computer architecture. Every fundamental hardware block is implemented as a standalone module and wired into a complete datapath.

---

## Architecture Overview

- **ISA:** Custom 8-bit fixed-length instruction set
- **Architecture:** Harvard (separate instruction and data memory)
- **Registers:** 4 × 8-bit general purpose (R0 hardwired to zero)
- **Memory:** 256 × 8-bit instruction memory, 8 × 8-bit data memory
- **Design:** Single-cycle — one instruction completes per clock cycle

---

## Blocks Implemented

| Module | Type | Description |
|--------|------|-------------|
| `pc` | Sequential | Program Counter — holds address of current instruction |
| `imem` | Combinational | Instruction Memory — ROM storing the program |
| `control` | Combinational | Control Unit — decodes opcode, drives all control signals |
| `regfile` | Sequential | Register File — 4×8-bit, 2 read ports, 1 write port |
| `alu` | Combinational | ALU — ADD, SUB, AND, OR; outputs result + flags |
| `sign_ext` | Combinational | Sign Extender — extends 3-bit immediate to 8 bits |
| `dmem` | Sequential | Data Memory — 8 locations, supports LOAD and STORE |
| `datapath` | Mixed | Wires all blocks together with MUXes |
| `cpu` | Top | Top-level: datapath + control |

---

## ISA

### Instruction Formats

```
R-Type  (register operations)
┌─────────┬────────┬────────┬────────┐
│  [7:5]  │ [4:3]  │ [2:1]  │  [0]   │
│  opcode │   rs   │   rd   │ unused │
└─────────┴────────┴────────┴────────┘
Operation: rd ← rd OP rs

I-Type  (immediate / memory / branch)
┌─────────┬────────┬────────────────┐
│  [7:5]  │ [4:3]  │    [2:0]       │
│  opcode │ rd/rs  │  immediate     │
└─────────┴────────┴────────────────┘
Operation depends on opcode
```

### Instruction Set

| Opcode | Mnemonic | Format | Operation |
|--------|----------|--------|-----------|
| `000` | `ADD rd, rs` | R | `rd ← rd + rs` |
| `001` | `SUB rd, rs` | R | `rd ← rd - rs` |
| `010` | `AND rd, rs` | R | `rd ← rd & rs` |
| `011` | `OR  rd, rs` | R | `rd ← rd \| rs` |
| `100` | `LDI rd, imm` | I | `rd ← sign_ext(imm)` |
| `101` | `LD  rd, imm` | I | `rd ← MEM[imm]` |
| `110` | `ST  rs, imm` | I | `MEM[imm] ← rs` |
| `111` | `BEQ rs, imm` | I | `if rs == 0: PC ← PC + sign_ext(imm)` |

### Register File

| Register | Alias | Notes |
|----------|-------|-------|
| R0 | zero | Hardwired to 0. Reads always return 0; writes are discarded |
| R1 | — | General purpose |
| R2 | — | General purpose |
| R3 | — | General purpose |

