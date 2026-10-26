# 32-bit MIPS 5-Stage Pipelined Processor in Verilog HDL

A complete implementation of a **32-bit MIPS 5-Stage Pipelined Processor** designed in Verilog HDL featuring dedicated pipeline registers, data forwarding, load-use hazard detection with automatic pipeline stalling, and branch resolution with pipeline flushing.

The project is verified using **Icarus Verilog (`iverilog`)** and includes automated testbench verification with waveform generation for **GTKWave (`gtkwave`)**.

---

## 🏛️ Architectural Overview

The processor implements the classic 5-stage MIPS pipeline architecture:

```
+---------------+     +---------------+     +---------------+     +---------------+     +---------------+
|      IF       |     |      ID       |     |      EX       |     |      MEM      |     |      WB       |
| Instruction   | ==> |  Instruction  | ==> |   Execution   | ==> | Memory Access | ==> |   Writeback   |
|     Fetch     |     |    Decode     |     |  / ALU Stage  |     |   (Data RAM)  |     |  (Reg File)   |
+---------------+     +---------------+     +---------------+     +---------------+     +---------------+
        |                     |                     |                     |                     |
     [IF/ID]               [ID/EX]               [EX/MEM]              [MEM/WB]                 |
        ^                     ^                     |                     |                     |
        |                     +-- Data Forwarding --+---------------------+                     |
        +----------------------------- Writeback Bus -------------------------------------------+
```

### 1. Instruction Fetch (IF)
- **Program Counter (PC)**: 32-bit register with synchronous write enable (`PCWrite`).
- **Adder**: Calculates `PC + 4`.
- **Instruction Memory**: 32-bit word-addressed memory preloaded with instructions (`$readmemh`).
- **Branch Target MUX**: Driven by `PCSrc` to select between sequential (`PC + 4`) and branch target address.
- **Pipeline Register**: `IF/ID` latches `PC + 4` and fetched `Instruction` on `posedge clk`.

### 2. Instruction Decode (ID)
- **Register File**: 32 general-purpose 32-bit registers (`$zero` hardwired to 0), synchronous write on negedge clock / write-through forwarding to avoid same-cycle read/write hazard.
- **Main Control Unit**: Decodes 6-bit Opcode to generate stage control signals (`RegDst`, `ALUSrc`, `MemtoReg`, `RegWrite`, `MemRead`, `MemWrite`, `Branch`, `BranchNotEqual`, `Jump`, `ALUOp`).
- **Sign Extension Unit**: Converts 16-bit immediate into sign-extended 32-bit value.
- **Hazard Detection Unit**: Detects Load-Use hazards and stalls the pipeline (freezes PC and IF/ID, inserts bubble into ID/EX).
- **Pipeline Register**: `ID_EX` latches decoded controls, register operands, immediate values, and register indices.

### 3. Execute / Address Calculation (EX)
- **ALU Control Unit**: Decodes 2-bit `ALUOp` and 6-bit `funct` field to generate 3-bit ALU control codes.
- **Arithmetic Logic Unit (ALU)**: Supports `ADD`, `SUB`, `AND`, `OR`, `SLT`, `NOR`, `XOR`, with `Zero` and `Carry` flag generation.
- **Data Forwarding Unit**: Resolves RAW data hazards by forwarding results directly from `EX/MEM` and `MEM/WB` stages into ALU inputs.
- **Branch Adder**: Computes branch target: `PC + 4 + (SignExtImm << 2)`.
- **RegDst MUX**: Selects destination register between `rt` (Instruction[20:16]) and `rd` (Instruction[15:11]).
- **Pipeline Register**: `EX/MEM` latches branch target, ALU result, zero flag, memory write data, and destination register.

### 4. Memory Access (MEM)
- **Data Memory**: 32-bit data memory supporting synchronous write on `posedge clk` and asynchronous read when `MemRead` is asserted.
- **Branch Logic**: Evaluates branch condition (`PCSrc = (Branch & Zero) | (BranchNotEqual & ~Zero)`). If taken, redirects PC and asserts pipeline flush.
- **Pipeline Register**: `MEM_WB` latches memory read data, ALU result, destination register, and writeback controls.

### 5. Write Back (WB)
- **MemtoReg MUX**: Selects between memory read data (`lw`) and ALU result (R-type / Immediate).
- Updates register file on active clock edge with `RegWrite` enable.

---

## ⚡ Supported Instruction Set

| Category | Instructions | Description |
|---|---|---|
| **R-Type** | `add`, `sub`, `and`, `or`, `slt`, `xor`, `nor` | Arithmetic and logical register operations with forwarding |
| **Immediate** | `addi`, `andi`, `ori`, `slti` | Immediate arithmetic and logic |
| **Memory** | `lw`, `sw` | Load word from memory, Store word to memory |
| **Branch** | `beq`, `bne` | Conditional branches with pipeline flush |
| **Jump** | `j` | Unconditional jump |

---

## 📂 Project Structure

```
MIPS/
├── docs/
│   ├── Pipelined Datapath.pdf      # Complete architectural datapath diagram
│   └── README.md                   # Architecture remarks & notes
├── programs/
│   ├── test_program.asm            # Assembly source code covering all test cases
│   └── test_program.hex            # Hexadecimal machine code for simulation
├── src/
│   ├── basic_blocks/
│   │   ├── DFF.v                   # D flip-flop with asynchronous reset
│   │   ├── Gates.v                 # 32-bit AND, OR, NOT, XOR, NOR gates & decoders
│   │   └── Reg32.v                 # 32-bit register with enable and reset
│   ├── control/
│   │   ├── ALUController.v         # ALU control decoder (ALUOp + Funct)
│   │   ├── Decoder.v               # 5-to-32 decoder
│   │   └── MainController.v        # Main control unit
│   ├── datapath/
│   │   ├── ALU.v                   # 32-bit Arithmetic Logic Unit with Zero flag
│   │   ├── Adder.v                 # Hierarchical full adder modules
│   │   ├── DataMemory32.v          # 32-bit Data RAM
│   │   ├── InstructionMemory32.v   # 32-bit Instruction ROM ($readmemh loader)
│   │   ├── JumpConcat.v            # Jump address concatenation
│   │   ├── LeftShift.v             # 32-bit left shifter by 2
│   │   ├── Mux.v                   # 2:1, 3:1, 4:1 multiplexers (1-bit & 32-bit)
│   │   ├── Mux32.v                 # 32:1 32-bit multiplexer
│   │   ├── Mux5bit2to1.v           # 5-bit 2:1 multiplexer (RegDst Mux)
│   │   ├── ProgramCounter.v        # PC register with stall/write enable
│   │   ├── RegFile32.v             # 32x32-bit Register File ($zero protected)
│   │   └── SignExtend.v            # 16-to-32 bit sign extender
│   ├── hazard/
│   │   ├── DataForwardingUnit.v    # RAW hazard forwarding (EX/MEM & MEM/WB)
│   │   └── HazardDetectionUnit.v   # Load-use stall and branch flush logic
│   ├── pipeline_registers/
│   │   ├── IF_ID.v                 # IF/ID stage register with stall & flush
│   │   ├── ID_EX.v                 # ID/EX stage register with flush bubble
│   │   ├── EX_MEM.v                # EX/MEM stage register with branch flush
│   │   └── MEM_WB.v                # MEM/WB stage register
│   └── MIPS_Processor.v            # Top-level pipelined processor module
├── tb/
│   ├── MIPS_Processor_tb.v         # Automated self-checking verification testbench
│   └── gtkwave_signals.gtkw        # Pre-configured GTKWave signal layout
├── Makefile                        # Build automation Makefile
├── run_sim.bat                     # Windows Batch simulation launcher
├── run_sim.ps1                     # PowerShell simulation & waveform launcher
└── README.md                       # Main documentation
```

---

## 🚀 How to Run the Simulation

The project is preconfigured for **Icarus Verilog (`iverilog`)** and **GTKWave (`gtkwave`)**.

### Option A: Using PowerShell (Recommended on Windows)

```powershell
# Run compilation, execute simulation, and verify assertions
.\run_sim.ps1

# Run simulation AND immediately open waveforms in GTKWave
.\run_sim.ps1 -Waveform
```

### Option B: Using Windows Batch Script

Double-click `run_sim.bat` or run in terminal:
```cmd
run_sim.bat
```
The script will compile the code, run the simulation, display the verification report, and prompt you to open GTKWave.

### Option C: Manual Command Line

```bash
# 1. Compile with Icarus Verilog
iverilog -g2012 -o sim.vvp tb/MIPS_Processor_tb.v

# 2. Run simulation with vvp
vvp sim.vvp

# 3. View waveforms with GTKWave using pre-configured layout
gtkwave mips_processor.vcd tb/gtkwave_signals.gtkw
```

### Option D: Using Make

```bash
make sim   # Compile and run simulation
make wave  # Run simulation and launch GTKWave
make clean # Remove simulation artifacts
```

---

## 📊 Verification Results

When the simulation runs, the testbench monitors instruction execution cycle-by-cycle and runs automated assertions against register and memory states:

```
================================================================================
                         AUTOMATED VERIFICATION REPORT                          
================================================================================
  [PASS] ADDI $t0 (Immediate Init): Reg[ 8] =  5 (Expected:  5)
  [PASS] ADDI $t1 (Immediate Init): Reg[ 9] = 10 (Expected: 10)
  [PASS] ADD  $t2 (EX-EX Forward) : Reg[10] = 15 (Expected: 15)
  [PASS] SUB  $t3 (MEM-EX Forward): Reg[11] =  5 (Expected:  5)
  [PASS] AND  $t4 (Bitwise AND)  : Reg[12] =  0 (Expected:  0)
  [PASS] OR   $t5 (Bitwise OR)   : Reg[13] = 15 (Expected: 15)
  [PASS] SLT  $t6 (Set On Less)  : Reg[14] =  1 (Expected:  1)
  [PASS] SW   Mem[0] (Store Word): Mem[ 0] = 15 (Expected: 15)
  [PASS] LW   $t7 (Load Word)    : Reg[15] = 15 (Expected: 15)
  [PASS] ADD  $s0 (Load-Use Stall): Reg[16] = 30 (Expected: 30)
  [PASS] BEQ  $s1 (Flush Test)   : Reg[17] =  1 (Expected:  1)
  [PASS] BEQ  $s2 (Branch Target): Reg[18] = 42 (Expected: 42)
--------------------------------------------------------------------------------
Total Assertions: 12 | Passed: 12 | Failed: 0

>>> ALL TESTS PASSED! 32-bit MIPS Processor Verified Successfully. <<<
Waveform file generated: mips_processor.vcd (open in GTKWave)
```

---

## 🔍 GTKWave Waveform Analysis

The testbench generates `mips_processor.vcd`. When opened with `tb/gtkwave_signals.gtkw`, signals are organized cleanly by pipeline stage:
- **Clock & Reset**
- **IF Stage**: `probe_PC`, `probe_instruction`, `probe_Stall`
- **ID Stage**: `ReadReg1`, `ReadData1`, `ReadReg2`, `ReadData2`, Control Signals
- **EX Stage**: `EX_ALU_InA`, `EX_ALU_InB`, `ForwardA`, `ForwardB`, `EX_ALUControl`, `EX_ALUResult`, `EX_Zero`
- **MEM Stage**: `MemRead`, `MemWrite`, `PCSrc`, `EX_MEM_ALUResult`, `EX_MEM_WriteData`, `MemReadData`
- **WB Stage**: `probe_RegWrite`, `probe_WriteReg`, `probe_WriteData`
