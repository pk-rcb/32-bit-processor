module ALU(
	input [31:0] in1,
	input [31:0] in2,
	input [2:0] ALUControl,
	output reg [31:0] Result,
	output Zero,
	output reg Carry
);

	wire [32:0] sum_extended;
	wire [32:0] diff_extended;

	assign sum_extended = {1'b0, in1} + {1'b0, in2};
	assign diff_extended = {1'b0, in1} - {1'b0, in2};

	always @(*) begin
		Carry = 1'b0;
		case (ALUControl)
			3'b000: Result = in1 & in2;                         // AND
			3'b001: Result = in1 | in2;                         // OR
			3'b010: begin                                       // ADD
				Result = sum_extended[31:0];
				Carry = sum_extended[32];
			end
			3'b110: begin                                       // SUB
				Result = diff_extended[31:0];
				Carry = diff_extended[32];
			end
			3'b111: Result = ($signed(in1) < $signed(in2)) ? 32'd1 : 32'd0; // SLT
			3'b100: Result = ~(in1 | in2);                      // NOR
			3'b011: Result = in1 ^ in2;                         // XOR
			default: Result = 32'b0;
		endcase
	end

	assign Zero = (Result == 32'b0);

endmodule