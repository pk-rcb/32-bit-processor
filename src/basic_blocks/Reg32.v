module reg_32bit(
	input clk,
	input reset,
	input enable,
	input [31:0] d,
	output reg [31:0] q
);

	always @(posedge clk or posedge reset) begin
		if (reset)
			q <= 32'b0;
		else if (enable)
			q <= d;
	end

endmodule