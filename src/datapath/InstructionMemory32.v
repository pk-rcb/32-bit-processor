module InstructionMemory32(
	input [31:0] ProgramCounter,
	input clk,
	output [31:0] instruction
);

	reg [31:0] memory [0:127];
	integer i;

	initial begin
		// Initialize all to NOP (32'b0)
		for (i = 0; i < 128; i = i + 1) begin
			memory[i] = 32'b0;
		end

		// Try loading from external hex files (up to available words)
		$readmemh("programs/test_program.hex", memory, 0, 19);

		// If memory[0] is still 0 (no file loaded), load default program
		if (memory[0] == 32'b0) begin
			memory[0]  = 32'h20080005; // addi $t0, $zero, 5   ($8 = 5)
			memory[1]  = 32'h2009000a; // addi $t1, $zero, 10  ($9 = 10)
			memory[2]  = 32'h01095020; // add  $t2, $t0, $t1   ($10 = 15)
			memory[3]  = 32'h01285822; // sub  $t3, $t1, $t0   ($11 = 5)
			memory[4]  = 32'h01096024; // and  $t4, $t0, $t1   ($12 = 0)
			memory[5]  = 32'h01096825; // or   $t5, $t0, $t1   ($13 = 15)
			memory[6]  = 32'h0109702a; // slt  $t6, $t0, $t1   ($14 = 1)
			memory[7]  = 32'hac0a0000; // sw   $t2, 0($zero)   (Mem[0] = 15)
			memory[8]  = 32'h8c0f0000; // lw   $t7, 0($zero)   ($15 = Mem[0] = 15)
			memory[9]  = 32'h01ef8020; // add  $s0, $t7, $t7   (Load-use hazard! $16 = 30)
			memory[10] = 32'h11090002; // beq  $t0, $t1, skip  (not taken)
			memory[11] = 32'h20110001; // addi $s1, $zero, 1   ($17 = 1)
			memory[12] = 32'h11080002; // beq  $t0, $t0, target(taken -> jump over next)
			memory[13] = 32'h20110099; // addi $s1, $zero, 99  (flushed!)
			memory[14] = 32'h00000000; // nop                  (flushed!)
			memory[15] = 32'h20120002; // addi $s2, $zero, 2   (target reached! $18 = 2)
			memory[16] = 32'h00000000; // nop
			memory[17] = 32'h00000000; // nop
			memory[18] = 32'h00000000; // nop
		end
	end

	// Asynchronous read (word addressed from PC)
	assign instruction = (ProgramCounter[31:2] < 128) ? memory[ProgramCounter[31:2]] : 32'b0;

endmodule

