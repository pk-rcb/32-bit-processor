module HazardDetectionUnit(
	input [4:0] IF_ID_Rs,
	input [4:0] IF_ID_Rt,
	input [4:0] ID_EX_Rt,
	input ID_EX_MemRead,
	input BranchTaken,
	output reg PCWrite,
	output reg IF_ID_Write,
	output reg ID_EX_Flush,
	output reg IF_ID_Flush
);

	always @(*) begin
		// Default: no stalls or flushes
		PCWrite     = 1'b1;
		IF_ID_Write = 1'b1;
		ID_EX_Flush = 1'b0;
		IF_ID_Flush = 1'b0;

		// 1. Branch hazard: flush instructions when branch is taken
		if (BranchTaken) begin
			IF_ID_Flush = 1'b1;
			ID_EX_Flush = 1'b1;
		end
		// 2. Load-Use Data Hazard:
		// When the instruction in ID depends on the destination of a 'lw' in EX
		else if (ID_EX_MemRead && (ID_EX_Rt != 5'd0) &&
		        ((ID_EX_Rt == IF_ID_Rs) || (ID_EX_Rt == IF_ID_Rt))) begin
			PCWrite     = 1'b0; // Hold Program Counter
			IF_ID_Write = 1'b0; // Hold IF/ID register
			ID_EX_Flush = 1'b1; // Insert stall bubble into ID/EX
		end
	end

endmodule

