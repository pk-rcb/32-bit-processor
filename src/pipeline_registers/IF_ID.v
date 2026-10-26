module IF_ID(
	input clk,
	input reset,
	input write_en,
	input flush,
	input [31:0] PC_plus_4_in,
	input [31:0] instruction_in,
	output reg [31:0] PC_plus_4_out,
	output reg [31:0] instruction_out
);

	always @(posedge clk or posedge reset) begin
		if (reset || flush) begin
			PC_plus_4_out   <= 32'b0;
			instruction_out <= 32'b0; // NOP
		end else if (write_en) begin
			PC_plus_4_out   <= PC_plus_4_in;
			instruction_out <= instruction_in;
		end
		// if !write_en, hold previous state (stall)
	end

endmodule

