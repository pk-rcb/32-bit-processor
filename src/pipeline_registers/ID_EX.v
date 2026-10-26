module ID_EX(
	input clk,
	input reset,
	input write_en,
	input flush,
	// Control signals in
	input RegDst_in,
	input [1:0] ALUOp_in,
	input ALUSrc_in,
	input Branch_in,
	input BranchNotEqual_in,
	input MemRead_in,
	input MemWrite_in,
	input RegWrite_in,
	input MemtoReg_in,
	// Data signals in
	input [31:0] PC_plus_4_in,
	input [31:0] ReadData1_in,
	input [31:0] ReadData2_in,
	input [31:0] SignExtImm_in,
	input [4:0] Rs_in,
	input [4:0] Rt_in,
	input [4:0] Rd_in,
	// Control signals out
	output reg RegDst_out,
	output reg [1:0] ALUOp_out,
	output reg ALUSrc_out,
	output reg Branch_out,
	output reg BranchNotEqual_out,
	output reg MemRead_out,
	output reg MemWrite_out,
	output reg RegWrite_out,
	output reg MemtoReg_out,
	// Data signals out
	output reg [31:0] PC_plus_4_out,
	output reg [31:0] ReadData1_out,
	output reg [31:0] ReadData2_out,
	output reg [31:0] SignExtImm_out,
	output reg [4:0] Rs_out,
	output reg [4:0] Rt_out,
	output reg [4:0] Rd_out
);

	always @(posedge clk or posedge reset) begin
		if (reset || flush) begin
			RegDst_out         <= 1'b0;
			ALUOp_out          <= 2'b0;
			ALUSrc_out         <= 1'b0;
			Branch_out         <= 1'b0;
			BranchNotEqual_out <= 1'b0;
			MemRead_out        <= 1'b0;
			MemWrite_out       <= 1'b0;
			RegWrite_out       <= 1'b0;
			MemtoReg_out       <= 1'b0;
			PC_plus_4_out      <= 32'b0;
			ReadData1_out      <= 32'b0;
			ReadData2_out      <= 32'b0;
			SignExtImm_out     <= 32'b0;
			Rs_out             <= 5'b0;
			Rt_out             <= 5'b0;
			Rd_out             <= 5'b0;
		end else if (write_en) begin
			RegDst_out         <= RegDst_in;
			ALUOp_out          <= ALUOp_in;
			ALUSrc_out         <= ALUSrc_in;
			Branch_out         <= Branch_in;
			BranchNotEqual_out <= BranchNotEqual_in;
			MemRead_out        <= MemRead_in;
			MemWrite_out       <= MemWrite_in;
			RegWrite_out       <= RegWrite_in;
			MemtoReg_out       <= MemtoReg_in;
			PC_plus_4_out      <= PC_plus_4_in;
			ReadData1_out      <= ReadData1_in;
			ReadData2_out      <= ReadData2_in;
			SignExtImm_out     <= SignExtImm_in;
			Rs_out             <= Rs_in;
			Rt_out             <= Rt_in;
			Rd_out             <= Rd_in;
		end
	end

endmodule

