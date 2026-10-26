module RegFile32(
	input clk,
	input reset,
	input [4:0] ReadReg1,
	input [4:0] ReadReg2,
	input [4:0] WriteReg,
	input [31:0] WriteData,
	input RegWrite,
	output [31:0] ReadData1,
	output [31:0] ReadData2
);

	reg [31:0] registers [31:0];
	integer i;

	// Synchronous reset and write on posedge (or active edge)
	always @(negedge clk or posedge reset) begin
		if (reset) begin
			for (i = 0; i < 32; i = i + 1) begin
				registers[i] <= 32'b0;
			end
		end else if (RegWrite && (WriteReg != 5'd0)) begin
			registers[WriteReg] <= WriteData;
		end
	end

	// Asynchronous read with Register 0 hardwired to 0 and internal forwarding
	assign ReadData1 = (ReadReg1 == 5'd0) ? 32'b0 :
	                   (RegWrite && (WriteReg == ReadReg1) && (WriteReg != 5'd0)) ? WriteData :
	                   registers[ReadReg1];

	assign ReadData2 = (ReadReg2 == 5'd0) ? 32'b0 :
	                   (RegWrite && (WriteReg == ReadReg2) && (WriteReg != 5'd0)) ? WriteData :
	                   registers[ReadReg2];

endmodule