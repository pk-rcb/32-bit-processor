module ALUControlUnit (
	input [1:0] ALUOp,
	input [5:0] FuncField,
	output reg [2:0] Operation
);

	always @(*) begin
		case (ALUOp)
			2'b00: Operation = 3'b010; // ADD (lw, sw, addi)
			2'b01: Operation = 3'b110; // SUB (beq, bne)
			2'b10: begin               // R-format
				case (FuncField)
					6'b100000: Operation = 3'b010; // ADD
					6'b100010: Operation = 3'b110; // SUB
					6'b100100: Operation = 3'b000; // AND
					6'b100101: Operation = 3'b001; // OR
					6'b101010: Operation = 3'b111; // SLT
					6'b100111: Operation = 3'b100; // NOR
					6'b100110: Operation = 3'b011; // XOR
					default:   Operation = 3'b010; // Default ADD
				endcase
			end
			2'b11: begin               // I-type logical/comparison
				// For I-types, FuncField can carry Opcode or Immediate func
				case (FuncField)
					6'b001100: Operation = 3'b000; // ANDI
					6'b001101: Operation = 3'b001; // ORI
					6'b001010: Operation = 3'b111; // SLTI
					default:   Operation = 3'b001; // default ORI/ANDI
				endcase
			end
			default: Operation = 3'b010;
		endcase
	end

endmodule