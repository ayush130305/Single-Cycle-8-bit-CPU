# 8-bit Single-Cycle CPU in Verilog

---

## What the CPU Does

- Fetches an 8-bit instruction every clock cycle from instruction memory
- Decodes the opcode and generates control signals
- Executes arithmetic, logic, load/store, and branch operations
- Writes results back to a 4-register file or data memory
- Branches by adding a sign-extended offset to the PC

## Block Diagram

<img width="1045" height="703" alt="WhatsApp Image 2026-06-18 at 12 24 15 PM" src="https://github.com/user-attachments/assets/7a00c193-8200-474c-b738-43b19536da24" />

## Flow

<img width="1038" height="676" alt="WhatsApp Image 2026-06-18 at 12 24 15 PM (1)" src="https://github.com/user-attachments/assets/25813b67-ea52-4bf9-8c76-a21bccf23f9a" />



**Verified program:**
```asm
LDI R1, 3      ; R1 = 3
LDI R2, 2      ; R2 = 2
ADD R1, R2     ; R1 = 3 + 2 = 5
ST  R1, 0      ; MEM[0] = 5
```

**Simulation output:**
```
PC     = 5
R1     = 5
R2     = 2
MEM[0] = 5
```

---

## Architecture

- **ISA:** Custom 8-bit fixed-length instruction set
- **Architecture:** Harvard (separate instruction and data memory)
- **Registers:** 4 × 8-bit (R0 hardwired to zero, R1–R3 general purpose)
- **Instruction Memory:** 256 × 8-bit ROM
- **Data Memory:** 8 × 8-bit RAM
- **Design:** Single-cycle — one instruction completes per clock cycle

---

## Blocks Implemented

| Module | Type | Description |
|--------|------|-------------|
| `PC.v` | Sequential | Program Counter — increments each cycle, loads branch target on taken branch |
| `imem.v` | Combinational | Instruction Memory — ROM addressed by PC, outputs raw instruction bits |
| `control.v` | Combinational | Control Unit — decodes opcode, drives all datapath control signals |
| `reg_file.v` | Mixed | Register File — 2 async read ports, 1 sync write port, R0 hardwired zero |
| `alu.v` | Combinational | ALU — ADD, SUB, AND, OR with zero, carry, overflow, negative flags |
| `sign_ext.v` | Combinational | Sign Extender — extends 3-bit immediate to 8 bits |
| `dmem.v` | Sequential | Data Memory — synchronous write, combinational read, gated by mem_write/mem_read |
| `cpu.v` | Top | Wires all blocks together with MUXes and branch logic |

---

## ISA

### Instruction Formats

```
R-Type  (register operations)
┌─────────┬────────┬────────┬────────┐
│  [7:5]  │ [4:3]  │ [2:1]  │  [0]   │
│  opcode │   rs   │   rd   │ unused │
└─────────┴────────┴────────┴────────┘

I-Type  (immediate / memory / branch)
┌─────────┬────────┬────────────────┐
│  [7:5]  │ [4:3]  │    [2:0]       │
│  opcode │ rd/rs  │  immediate     │
└─────────┴────────┴────────────────┘
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

| Register | Notes |
|----------|-------|
| R0 | Hardwired to 0. Writes discarded. |
| R1–R3 | General purpose |

---

## Simulation Results

Program: `LDI R1,3 → LDI R2,2 → ADD R1,R2 → ST R1,0`

| Signal | Expected | Got |
|--------|----------|-----|
| R1 | 5 | ✅ 5 |
| R2 | 2 | ✅ 2 |
| MEM[0] | 5 | ✅ 5 |
| PC | 5 | ✅ 5 |

<img width="2326" height="774" alt="image" src="https://github.com/user-attachments/assets/bf548ea8-d904-492c-9b67-ad12c4700be0" />
---

## Waveforms to Check

Open the simulation waveform in Vivado and add these signals. They tell the complete story of each instruction cycle.

### 1. Clock and Reset
| Signal | What to look for |
|--------|-----------------|
| `clk` | Toggles every 5ns |
| `rst` | High for 20ns then low — no register writes should happen while high |

### 2. Fetch Stage
| Signal | What to look for |
|--------|-----------------|
| `u_pc/pc_out` | Steps 0 → 1 → 2 → 3 → 4 after reset releases |
| `u_imem/instr` | Should read 8B → 92 → 12 → C8 as PC increments |

### 3. Decode Stage
| Signal | What to look for |
|--------|-----------------|
| `opcode` | Changes each cycle: 100 → 100 → 000 → 110 |
| `alu_src` | 1 for LDI/ST/LD, 0 for ADD/SUB |
| `reg_write` | 1 for LDI and ADD, 0 for ST |
| `mem_write` | Pulses high only on cycle 4 (ST instruction) |
| `write_addr` | Should be 01 (R1), 10 (R2), 01 (R1), 01 (R1) |

### 4. Execute Stage
| Signal | What to look for |
|--------|-----------------|
| `alu_a` | 0 for LDI (forced), then register values for ADD |
| `alu_b` | Immediate for LDI, register for ADD |
| `u_alu/result` | 3 → 2 → 5 → 0 across the 4 cycles |
| `zero` | Goes high when result is 0 (used by BEQ) |

### 5. Writeback
| Signal | What to look for |
|--------|-----------------|
| `wb_data` | Value being written to register file each cycle |
| `u_rf/registers[1]` | 0 → 3 → 3 → 5 → 5 |
| `u_rf/registers[2]` | 0 → 0 → 2 → 2 → 2 |
| `u_dmem/mem[0]` | X → X → X → X → 5 (written on ST cycle) |

### Key things to verify in waveform
- No register writes while `rst = 1`
- `pc_out` increments exactly once per clock after reset
- `mem_write` is only high for exactly one cycle (the ST instruction)
- `wb_data` matches the expected ALU result each cycle

---

## Project Structure

```
8bit-cpu/
├── src/
│   ├── PC.v
│   ├── imem.v
│   ├── control.v
│   ├── reg_file.v
│   ├── alu.v
│   ├── sign_ext.v
│   ├── dmem.v
│   └── cpu.v
├── tb/
│   └── cpu_tb.v
└── README.md
```

---
