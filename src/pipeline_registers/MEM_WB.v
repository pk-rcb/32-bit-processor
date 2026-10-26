module MEM_WB(
	input clk,
	input reset,
	input write_en,
	// Control signals in
	input RegWrite_in,
	input MemtoReg_in,
	// Data signals in
	input [31:0] MemReadData_in,
	input [31:0] ALUResult_in,
	input [4:0] WriteReg_in,
	// Control signals out
	output reg RegWrite_out,
	output reg MemtoReg_out,
	// Data signals out
	output reg [31:0] MemReadData_out,
	output reg [31:0] ALUResult_out,
	output reg [4:0] WriteReg_out
);

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			RegWrite_out    <= 1'b0;
			MemtoReg_out    <= 1'b0;
			MemReadData_out <= 32'b0;
			ALUResult_out   <= 32'b0;
			WriteReg_out    <= 5'b0;
		end else if (write_en) begin
			RegWrite_out    <= RegWrite_in;
			MemtoReg_out    <= MemtoReg_in;
			MemReadData_out <= MemReadData_in;
			ALUResult_out   <= ALUResult_in;
			WriteReg_out    <= WriteReg_in;
		end
	end

endmodule

