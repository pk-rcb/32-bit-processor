module bit32And (out, in1, in2);
	input [31:0] in1, in2;
	output [31:0] out;
	
	assign out = in1 & in2;
endmodule

module bit32Or (out, in1, in2);
	input [31:0] in1, in2;
	output [31:0] out;
	
	assign out = in1 | in2;
endmodule

module bit32Not (out, in);
	input [31:0] in;
	output [31:0] out;
	
	assign out = ~in;
endmodule

module bit32Xor (out, in1, in2);
	input [31:0] in1, in2;
	output [31:0] out;
	
	assign out = in1 ^ in2;
endmodule

module bit32Nor (out, in1, in2);
	input [31:0] in1, in2;
	output [31:0] out;
	
	assign out = ~(in1 | in2);
endmodule

module bit1_3to1and (out, in1, in2, in3);
	input in1, in2, in3;
	output out;
	
	assign out = in1 & in2 & in3;
endmodule

module bit1_2to4decoder (out, in0, in1);
	input in0, in1;
	output [3:0] out;
	
	assign out[0] = (~in1) & (~in0);
	assign out[1] = (~in1) & ( in0);
	assign out[2] = ( in1) & (~in0);
	assign out[3] = ( in1) & ( in0);
endmodule