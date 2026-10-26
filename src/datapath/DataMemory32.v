module DataMemory32(
	input clk,
	input reset,
	input MemRead,
	input MemWrite,
	input [31:0] Address,
	input [31:0] WriteData,
	output [31:0] ReadData
);

	reg [31:0] data [0:63];
	integer i;

	initial begin
		for (i = 0; i < 64; i = i + 1) begin
			data[i] = 32'b0;
		end
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			for (i = 0; i < 64; i = i + 1) begin
				data[i] <= 32'b0;
			end
		end else if (MemWrite) begin
			if (Address[31:2] < 64)
				data[Address[31:2]] <= WriteData;
		end
	end

	// Asynchronous read when MemRead is high
	assign ReadData = (MemRead && (Address[31:2] < 64)) ? data[Address[31:2]] : 32'b0;

endmodule