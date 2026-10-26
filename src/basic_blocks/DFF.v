module dff_async_clear(q, d, clk, reset);
	input d, reset, clk;
	output reg q;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
			q <= 1'b0;
		else
			q <= d;
	end
	
endmodule

