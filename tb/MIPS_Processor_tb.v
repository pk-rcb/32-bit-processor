`timescale 1ns / 1ps

`include "src/MIPS_Processor.v"

module MIPS_Processor_tb;

    reg clk;
    reg reset;

    wire [31:0] probe_PC;
    wire [31:0] probe_instruction;
    wire [31:0] probe_ALUResult;
    wire [4:0]  probe_WriteReg;
    wire [31:0] probe_WriteData;
    wire        probe_RegWrite;
    wire        probe_Stall;

    // Instantiate Processor Top-Level
    MIPS_Processor uut (
        .clk(clk),
        .reset(reset),
        .probe_PC(probe_PC),
        .probe_instruction(probe_instruction),
        .probe_ALUResult(probe_ALUResult),
        .probe_WriteReg(probe_WriteReg),
        .probe_WriteData(probe_WriteData),
        .probe_RegWrite(probe_RegWrite),
        .probe_Stall(probe_Stall)
    );

    // Clock Generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    integer cycle_count;
    integer pass_count;
    integer fail_count;

    // Helper task to check register value
    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected_val;
        input [255:0] test_name;
        reg [31:0] actual_val;
        begin
            actual_val = uut.regfile.registers[reg_num];
            if (actual_val === expected_val) begin
                $display("  [PASS] %0s: Reg[%2d] = %2d (Expected: %2d)", test_name, reg_num, actual_val, expected_val);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %0s: Reg[%2d] = %2d (Expected: %2d)", test_name, reg_num, actual_val, expected_val);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Helper task to check memory value
    task check_mem;
        input [31:0] addr;
        input [31:0] expected_val;
        input [255:0] test_name;
        reg [31:0] actual_val;
        begin
            actual_val = uut.dmem_inst.data[addr >> 2];
            if (actual_val === expected_val) begin
                $display("  [PASS] %0s: Mem[%2d] = %2d (Expected: %2d)", test_name, addr, actual_val, expected_val);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %0s: Mem[%2d] = %2d (Expected: %2d)", test_name, addr, actual_val, expected_val);
                fail_count = fail_count + 1;
            end
        end
    endtask


    initial begin
        // Setup GTKWave VCD dump
        $dumpfile("mips_processor.vcd");
        $dumpvars(0, MIPS_Processor_tb);

        clk = 0;
        reset = 1;
        cycle_count = 0;
        pass_count = 0;
        fail_count = 0;

        $display("================================================================================");
        $display("       32-bit MIPS 5-Stage Pipelined Processor Verification Simulation          ");
        $display("================================================================================");

        // Hold reset for 2 cycles
        #12;
        reset = 0;
        $display("[Time %0t ns] Reset deasserted. Processor execution initiated.\n", $time);

        // Monitor cycle-by-cycle execution
        while (cycle_count < 35) begin
            @(posedge clk);
            #1; // slight offset after posedge
            cycle_count = cycle_count + 1;

            if (probe_RegWrite && probe_WriteReg != 0) begin
                $display("[Cycle %2d | Time %4dns] PC: 0x%08h | Instr: 0x%08h | WB => Reg[%2d] <= 0x%08h (%0d)",
                         cycle_count, $time, probe_PC, probe_instruction, probe_WriteReg, probe_WriteData, $signed(probe_WriteData));
            end else if (probe_Stall) begin
                $display("[Cycle %2d | Time %4dns] PC: 0x%08h | Instr: 0x%08h | [STALL] Load-Use Bubble Inserted",
                         cycle_count, $time, probe_PC, probe_instruction);
            end else begin
                $display("[Cycle %2d | Time %4dns] PC: 0x%08h | Instr: 0x%08h",
                         cycle_count, $time, probe_PC, probe_instruction);
            end
        end

        // Run Verification Assertions
        $display("\n================================================================================");
        $display("                         AUTOMATED VERIFICATION REPORT                          ");
        $display("================================================================================");

        check_reg(8,  32'd5,  "ADDI $t0 (Immediate Init)");
        check_reg(9,  32'd10, "ADDI $t1 (Immediate Init)");
        check_reg(10, 32'd15, "ADD  $t2 (EX-EX Forward) ");
        check_reg(11, 32'd5,  "SUB  $t3 (MEM-EX Forward)");
        check_reg(12, 32'd0,  "AND  $t4 (Bitwise AND)  ");
        check_reg(13, 32'd15, "OR   $t5 (Bitwise OR)   ");
        check_reg(14, 32'd1,  "SLT  $t6 (Set On Less)  ");
        check_mem(0,  32'd15, "SW   Mem[0] (Store Word)");
        check_reg(15, 32'd15, "LW   $t7 (Load Word)    ");
        check_reg(16, 32'd30, "ADD  $s0 (Load-Use Stall)");
        check_reg(17, 32'd1,  "BEQ  $s1 (Flush Test)   ");
        check_reg(18, 32'd42, "BEQ  $s2 (Branch Target)");

        $display("--------------------------------------------------------------------------------");
        $display("Total Assertions: %0d | Passed: %0d | Failed: %0d",
                 pass_count + fail_count, pass_count, fail_count);

        if (fail_count == 0) begin
            $display("\n>>> ALL TESTS PASSED! 32-bit MIPS Processor Verified Successfully. <<<");
            $display("Waveform file generated: mips_processor.vcd (open in GTKWave)\n");
        end else begin
            $display("\n>>> VERIFICATION FAILED with %0d errors. <<<\n", fail_count);
        end
        $display("================================================================================");

        $finish;
    end

endmodule
