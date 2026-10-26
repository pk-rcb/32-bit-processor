# ==============================================================================
# 32-bit MIPS 5-Stage Pipelined Processor Verification Program
# Covers:
#   1. Immediate instructions (addi)
#   2. R-type instructions (add, sub, and, or, slt)
#   3. Data Forwarding (EX->EX, MEM->EX RAW dependencies)
#   4. Memory instructions (sw, lw)
#   5. Load-Use Hazard Detection & Hardware Pipeline Stall Insertion
#   6. Branch instructions (beq taken, beq not taken) & Pipeline Branch Flushing
# ==============================================================================

# [0x00] Initialize $t0 = 5
addi $t0, $zero, 5          # $8  = 5

# [0x04] Initialize $t1 = 10
addi $t1, $zero, 10         # $9  = 10

# [0x08] R-Type ADD with EX->EX Forwarding: $t2 = $t0 + $t1 = 15
add  $t2, $t0, $t1          # $10 = 15

# [0x0C] R-Type SUB with MEM->EX Forwarding: $t3 = $t1 - $t0 = 5
sub  $t3, $t1, $t0          # $11 = 5

# [0x10] R-Type AND: $t4 = 5 & 10 = 0
and  $t4, $t0, $t1          # $12 = 0

# [0x14] R-Type OR:  $t5 = 5 | 10 = 15
or   $t5, $t0, $t1          # $13 = 15

# [0x18] R-Type SLT: $t6 = (5 < 10) = 1
slt  $t6, $t0, $t1          # $14 = 1

# [0x1C] Store Word: Mem[0] = $t2 (15)
sw   $t2, 0($zero)          # Mem[0] <= 15

# [0x20] Load Word: $t7 = Mem[0] = 15
lw   $t7, 0($zero)          # $15 = 15

# [0x24] Load-Use Data Hazard: immediate use of $t7
# Hazard Detection Unit inserts 1-cycle stall bubble, then forwards from MEM/WB
add  $s0, $t7, $t7          # $16 = 15 + 15 = 30

# [0x28] Branch Not Taken: $t0 != $t1, falls through to next instruction
beq  $t0, $t1, skip_target  # 5 == 10? False

# [0x2C] Sequential Instruction: executed normally
addi $s1, $zero, 1          # $17 = 1

# [0x30] Branch Taken: $t0 == $t0 (5 == 5), branches to target
beq  $t0, $t0, branch_target # Taken!

# [0x34] Flushed Instruction: MUST NOT EXECUTE (overwritten with bubble)
addi $s1, $zero, 99         # Should be flushed! ($17 must remain 1)

# [0x38] NOP (Flushed)
nop

# [0x3C] Branch Target Reached!
branch_target:
addi $s2, $zero, 42         # $18 = 42

# Trailing NOPs to flush pipeline
nop
nop
nop
