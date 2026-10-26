module ProgramCounter(out, in, clk, reset, write_enable);
	input [31:0] in;
	input reset, clk, write_enable;
	output reg [31:0] out;
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			out <= 32'b0;
		else if (write_enable)
			out <= in;
	end
endmodule

// Backward compatibility alias for any references with typo
module ProgamCounter(out, in, clk, reset);
	input [31:0] in;
	input reset, clk;
	output [31:0] out;
	
	ProgramCounter pc_inst(
		.out(out),
		.in(in),
		.clk(clk),
		.reset(reset),
		.write_enable(1'b1)
	);
endmodule