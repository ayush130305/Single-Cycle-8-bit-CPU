# 8-bit Single-Cycle CPU in Verilog

---

## What the CPU Does

- Fetches a 16-bit instruction every clock cycle from instruction memory
- Decodes the 4-bit opcode and generates control signals
- Executes arithmetic, logic, shift, load/store, and branch operations
- Writes results back to a 4-register file or data memory
- Branches by adding a signed 8-bit offset to the PC
- Unconditional jump via `BEQ R0, offset` — R0 is hardwired zero
- 3-stage pipeline: Fetch → Decode → Execute with full hazard handling

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

- **ISA:** Custom 16-bit fixed-length instruction set
- **Architecture:** Harvard (separate instruction and data memory)
- **Registers:** 4 × 8-bit (R0 hardwired to zero, R1–R3 general purpose)
- **Instruction Memory:** 256 × 16-bit ROM
- **Data Memory:** 8 × 8-bit RAM
- **Design:** 3-stage pipeline — Fetch, Decode, Execute

---

## Blocks Implemented

| Module | Type | Description |
|--------|------|-------------|
| `PC.v` | Sequential | Program Counter — increments each cycle, supports stall and flush, loads branch target on taken branch |
| `imem.v` | Combinational | Instruction Memory — 256×16 ROM addressed by PC, outputs raw instruction bits |
| `control.v` | Combinational | Control Unit — decodes 4-bit opcode, drives all datapath control signals |
| `reg_file.v` | Mixed | Register File — 2 async read ports with write-before-read forwarding, 1 sync write port, R0 hardwired zero |
| `alu.v` | Combinational | ALU — ADD SUB AND OR XOR NOT SHL SHR MOV with zero, carry, overflow, negative flags |
| `sign_ext.v` | Combinational | Immediate passthrough — 8-bit immediate, signed via 2's complement |
| `dmem.v` | Sequential | Data Memory — synchronous write, combinational read, gated by mem_write/mem_read |
| `cpu.v` | Top | 3-stage pipeline with IF/ID and ID/EX registers, forwarding unit, hazard detection, flush logic |

---

## ISA

### Instruction Formats

```
R-Type  (register operations)
┌──────────┬────────┬────────┬──────────────────┐
│ [15:12]  │ [11:10]│  [9:8] │     [7:0]        │
│  opcode  │   rs   │   rd   │   unused (0x00)  │
└──────────┴────────┴────────┴──────────────────┘

I-Type  (immediate / memory / branch)
┌──────────┬────────┬────────┬──────────────────┐
│ [15:12]  │ [11:10]│  [9:8] │     [7:0]        │
│  opcode  │  rd/rs │ unused │   immediate      │
└──────────┴────────┴────────┴──────────────────┘
```

### Instruction Set

| Opcode | Mnemonic | Format | Operation |
|--------|----------|--------|-----------|
| `0000` | `ADD rd, rs` | R | `rd ← rd + rs` |
| `0001` | `SUB rd, rs` | R | `rd ← rd - rs` |
| `0010` | `AND rd, rs` | R | `rd ← rd & rs` |
| `0011` | `OR  rd, rs` | R | `rd ← rd \| rs` |
| `0100` | `XOR rd, rs` | R | `rd ← rd ^ rs` |
| `0101` | `NOT rd`     | R | `rd ← ~rd` |
| `0110` | `SHL rd, rs` | R | `rd ← rd << rs` |
| `0111` | `SHR rd, rs` | R | `rd ← rd >> rs` |
| `1000` | `CMP rd, rs` | R | flags only, no writeback |
| `1001` | `MOV rd, rs` | R | `rd ← rs` |
| `1010` | `LDI rd, imm` | I | `rd ← imm` |
| `1011` | `LD  rd, imm` | I | `rd ← MEM[imm]` |
| `1100` | `ST  rs, imm` | I | `MEM[imm] ← rs` |
| `1101` | `BEQ rs, imm` | I | `if rs == 0: PC ← PC + imm` |
| `1110` | `BNE rs, imm` | I | `if rs != 0: PC ← PC + imm` |
| `1111` | reserved | — | — |

### Register File

| Register | Notes |
|----------|-------|
| R0 | Hardwired to 0. Writes discarded. |
| R1–R3 | General purpose |

---

## Pipeline

### Stages

```
Fetch   → IF/ID register → Decode  → ID/EX register → Execute
[PC+IMEM]                 [CTRL+RF]                  [ALU+DMEM+WB]
```

### Pipeline Registers

**IF/ID** — holds `pc_out` and `instr` between Fetch and Decode.
Flushed on reset or branch taken.
Frozen on load-use hazard.

**ID/EX** — holds all decoded values and control signals between Decode and Execute.
Zeroed on reset, flush, or load-use hazard (bubble inserted).

### Hazard Handling

| Hazard | Cause | Fix |
|--------|-------|-----|
| Data hazard | Instruction reads register written by previous instruction | Write-before-read forwarding in register file + EX/WB forwarding register |
| Load-use hazard | LD result needed by immediately next instruction | Stall PC and IF/ID for 1 cycle, insert bubble into ID/EX |
| Control hazard | Branch decision made in Execute, wrong instruction already fetched | Flush IF/ID and ID/EX when branch taken |

---

## Simulation Results

### Basic + Forwarding
Program: `LDI R1,3 → LDI R2,2 → ADD R1,R2 → ST R1,0`

| Signal | Expected | Got |
|--------|----------|-----|
| R1 | 5 | ✅ 5 |
| R2 | 2 | ✅ 2 |
| MEM[0] | 5 | ✅ 5 |

### Load-Use Hazard (Stall)
Program: `LDI R1,10 → ST R1,0 → LDI R2,3 → LD R1,0 → ADD R1,R2 → ST R1,0`

| Signal | Expected | Got |
|--------|----------|-----|
| R1 | 13 | ✅ 13 |
| R2 | 3 | ✅ 3 |
| MEM[0] | 13 | ✅ 13 |

### Control Hazard (Flush)
Program: `LDI R1,3 → LDI R2,2 → ADD R1,R2 → BEQ R0,+2 → [flushed] → ST R1,0`

| Signal | Expected | Got |
|--------|----------|-----|
| R1 | 5 | ✅ 5 |
| R2 | 2 | ✅ 2 (255 = flush failed) |
| MEM[0] | 5 | ✅ 5 |


(single cycle 8 bit cpu output of v1)
<img width="2326" height="774" alt="image" src="https://github.com/user-attachments/assets/bf548ea8-d904-492c-9b67-ad12c4700be0" />

---

## Waveforms to Check

Open the simulation waveform in Vivado and add these signals.

### 1. Clock and Reset
| Signal | What to look for |
|--------|-----------------|
| `clk` | Toggles every 5ns |
| `rst` | High for 40ns then low — pipeline registers zero during reset |

### 2. Fetch Stage
| Signal | What to look for |
|--------|-----------------|
| `u_pc/pc_out` | Steps 0 → 1 → 2 → 3 → 4 after reset, freezes on stall |
| `u_imem/instr` | 0xA403 → 0xA802 → 0x0900 → 0xC400 as PC increments |

### 3. Decode Stage
| Signal | What to look for |
|--------|-----------------|
| `opcode` | Changes each cycle: 1010 → 1010 → 0000 → 1100 |
| `alu_src` | 1 for LDI/ST/LD, 0 for ADD/SUB |
| `reg_write` | 1 for LDI and ADD, 0 for ST |
| `mem_write` | Pulses high only on ST instruction |
| `write_addr` | Should be 01 (R1), 10 (R2), 01 (R1), 01 (R1) |

### 4. Execute Stage
| Signal | What to look for |
|--------|-----------------|
| `alu_a` | 0 for LDI (forced), then register values for ADD |
| `alu_b` | Immediate for LDI, register for ADD |
| `u_alu/result` | 3 → 2 → 5 → 0 across the 4 cycles |
| `zero` | Goes high when result is 0 (used by BEQ) |

### 5. Hazard Signals
| Signal | What to look for |
|--------|-----------------|
| `load_use_hazard` | Pulses high for exactly 1 cycle on LD followed by immediate use |
| `flush` | Pulses high same cycle branch_taken fires |
| `branch_taken` | Goes high when BEQ/BNE condition met |
| `forward_A` | Goes high when forwarding to ALU input A |
| `forward_B` | Goes high when forwarding to ALU input B |

### 6. Writeback
| Signal | What to look for |
|--------|-----------------|
| `wb_data` | Value being written to register file each cycle |
| `u_rf/registers[1]` | Updates after LDI and ADD |
| `u_rf/registers[2]` | Updates after LDI R2 |
| `u_dmem/mem[0]` | Updates after ST |

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
