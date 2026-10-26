module MainControlUnit (
	input [5:0] Op,
	output RegDst,
	output ALUSrc,
	output MemtoReg,
	output RegWrite,
	output MemRead,
	output MemWrite,
	output Branch,
	output BranchNotEqual,
	output Jump,
	output [1:0] ALUOp
);

	wire Rformat = (Op == 6'b000000);
	wire lw      = (Op == 6'b100011);
	wire sw      = (Op == 6'b101011);
	wire beq     = (Op == 6'b000100);
	wire bne     = (Op == 6'b000101);
	wire addi    = (Op == 6'b001000);
	wire andi    = (Op == 6'b001100);
	wire ori     = (Op == 6'b001101);
	wire slti    = (Op == 6'b001010);
	wire j       = (Op == 6'b000010);

	assign RegDst         = Rformat;
	assign ALUSrc         = lw | sw | addi | andi | ori | slti;
	assign MemtoReg       = lw;
	assign RegWrite       = Rformat | lw | addi | andi | ori | slti;
	assign MemRead        = lw;
	assign MemWrite       = sw;
	assign Branch         = beq;
	assign BranchNotEqual = bne;
	assign Jump           = j;

	// ALUOp encoding:
	// 2'b00: lw, sw, addi (ADD)
	// 2'b01: beq, bne (SUB)
	// 2'b10: R-format (decode from func)
	// 2'b11: andi, ori, slti (Immediate logical/comparison)
	assign ALUOp[1] = Rformat | andi | ori | slti;
	assign ALUOp[0] = beq | bne | andi | ori | slti;

endmodule