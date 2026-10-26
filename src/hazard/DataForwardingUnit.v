module DataForwardingUnit(
	input [4:0] ID_EX_Rs,
	input [4:0] ID_EX_Rt,
	input [4:0] EX_MEM_WriteReg,
	input EX_MEM_RegWrite,
	input [4:0] MEM_WB_WriteReg,
	input MEM_WB_RegWrite,
	output reg [1:0] ForwardA,
	output reg [1:0] ForwardB
);

	always @(*) begin
		// ForwardA Logic:
		// 1. EX hazard: EX/MEM has higher priority since it's the more recent result
		if (EX_MEM_RegWrite && (EX_MEM_WriteReg != 5'd0) && (EX_MEM_WriteReg == ID_EX_Rs)) begin
			ForwardA = 2'b10; // Forward from EX/MEM ALUResult
		end
		// 2. MEM hazard: MEM/WB
		else if (MEM_WB_RegWrite && (MEM_WB_WriteReg != 5'd0) && (MEM_WB_WriteReg == ID_EX_Rs)) begin
			ForwardA = 2'b01; // Forward from MEM/WB WriteData
		end
		else begin
			ForwardA = 2'b00; // No forwarding (use ID/EX register value)
		end

		// ForwardB Logic:
		// 1. EX hazard: EX/MEM has higher priority
		if (EX_MEM_RegWrite && (EX_MEM_WriteReg != 5'd0) && (EX_MEM_WriteReg == ID_EX_Rt)) begin
			ForwardB = 2'b10; // Forward from EX/MEM ALUResult
		end
		// 2. MEM hazard: MEM/WB
		else if (MEM_WB_RegWrite && (MEM_WB_WriteReg != 5'd0) && (MEM_WB_WriteReg == ID_EX_Rt)) begin
			ForwardB = 2'b01; // Forward from MEM/WB WriteData
		end
		else begin
			ForwardB = 2'b00; // No forwarding
		end
	end

endmodule

