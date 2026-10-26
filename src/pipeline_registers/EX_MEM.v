module EX_MEM(
	input clk,
	input reset,
	input write_en,
	input flush,
	// Control signals in
	input Branch_in,
	input BranchNotEqual_in,
	input MemRead_in,
	input MemWrite_in,
	input RegWrite_in,
	input MemtoReg_in,
	// Data signals in
	input [31:0] BranchTarget_in,
	input Zero_in,
	input [31:0] ALUResult_in,
	input [31:0] WriteData_in,
	input [4:0] WriteReg_in,
	// Control signals out
	output reg Branch_out,
	output reg BranchNotEqual_out,
	output reg MemRead_out,
	output reg MemWrite_out,
	output reg RegWrite_out,
	output reg MemtoReg_out,
	// Data signals out
	output reg [31:0] BranchTarget_out,
	output reg Zero_out,
	output reg [31:0] ALUResult_out,
	output reg [31:0] WriteData_out,
	output reg [4:0] WriteReg_out
);

	always @(posedge clk or posedge reset) begin
		if (reset || flush) begin
			Branch_out         <= 1'b0;
			BranchNotEqual_out <= 1'b0;
			MemRead_out        <= 1'b0;
			MemWrite_out       <= 1'b0;
			RegWrite_out       <= 1'b0;
			MemtoReg_out       <= 1'b0;
			BranchTarget_out   <= 32'b0;
			Zero_out           <= 1'b0;
			ALUResult_out      <= 32'b0;
			WriteData_out      <= 32'b0;
			WriteReg_out       <= 5'b0;
		end else if (write_en) begin
			Branch_out         <= Branch_in;
			BranchNotEqual_out <= BranchNotEqual_in;
			MemRead_out        <= MemRead_in;
			MemWrite_out       <= MemWrite_in;
			RegWrite_out       <= RegWrite_in;
			MemtoReg_out       <= MemtoReg_in;
			BranchTarget_out   <= BranchTarget_in;
			Zero_out           <= Zero_in;
			ALUResult_out      <= ALUResult_in;
			WriteData_out      <= WriteData_in;
			WriteReg_out       <= WriteReg_in;
		end
	end

endmodule

