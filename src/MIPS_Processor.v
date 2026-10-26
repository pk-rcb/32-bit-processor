`timescale 1ns / 1ps

`include "src/basic_blocks/Gates.v"
`include "src/control/MainController.v"
`include "src/control/ALUController.v"
`include "src/datapath/Mux.v"
`include "src/datapath/SignExtend.v"
`include "src/datapath/LeftShift.v"
`include "src/datapath/ProgramCounter.v"
`include "src/datapath/RegFile32.v"
`include "src/datapath/ALU.v"
`include "src/datapath/InstructionMemory32.v"
`include "src/datapath/DataMemory32.v"
`include "src/pipeline_registers/IF_ID.v"
`include "src/pipeline_registers/ID_EX.v"
`include "src/pipeline_registers/EX_MEM.v"
`include "src/pipeline_registers/MEM_WB.v"
`include "src/hazard/DataForwardingUnit.v"
`include "src/hazard/HazardDetectionUnit.v"

module MIPS_Processor(
    input clk,
    input reset,
    // Diagnostic / Verification Probe Outputs
    output [31:0] probe_PC,
    output [31:0] probe_instruction,
    output [31:0] probe_ALUResult,
    output [4:0]  probe_WriteReg,
    output [31:0] probe_WriteData,
    output        probe_RegWrite,
    output        probe_Stall
);

    // =========================================================================
    // 1. IF (Instruction Fetch) Stage
    // =========================================================================
    wire [31:0] PC_current;
    wire [31:0] PC_next;
    wire [31:0] PC_plus_4;
    wire [31:0] IF_instruction;
    wire        PCWrite;
    wire        IF_ID_Write;
    wire        IF_ID_Flush;
    wire        PCSrc;
    wire [31:0] EX_MEM_BranchTarget;

    assign PC_plus_4 = PC_current + 32'd4;
    assign PC_next   = PCSrc ? EX_MEM_BranchTarget : PC_plus_4;

    ProgramCounter pc_inst(
        .out(PC_current),
        .in(PC_next),
        .clk(clk),
        .reset(reset),
        .write_enable(PCWrite)
    );

    InstructionMemory32 imem_inst(
        .ProgramCounter(PC_current),
        .clk(clk),
        .instruction(IF_instruction)
    );

    // IF/ID Pipeline Register
    wire [31:0] IF_ID_PC_plus_4;
    wire [31:0] IF_ID_instruction;

    IF_ID if_id_reg(
        .clk(clk),
        .reset(reset),
        .write_en(IF_ID_Write),
        .flush(IF_ID_Flush),
        .PC_plus_4_in(PC_plus_4),
        .instruction_in(IF_instruction),
        .PC_plus_4_out(IF_ID_PC_plus_4),
        .instruction_out(IF_ID_instruction)
    );

    // =========================================================================
    // 2. ID (Instruction Decode) Stage
    // =========================================================================
    wire [5:0]  ID_Opcode = IF_ID_instruction[31:26];
    wire [4:0]  ID_Rs     = IF_ID_instruction[25:21];
    wire [4:0]  ID_Rt     = IF_ID_instruction[20:16];
    wire [4:0]  ID_Rd     = IF_ID_instruction[15:11];
    wire [15:0] ID_Imm16  = IF_ID_instruction[15:0];

    wire        ID_RegDst;
    wire        ID_ALUSrc;
    wire        ID_MemtoReg;
    wire        ID_RegWrite;
    wire        ID_MemRead;
    wire        ID_MemWrite;
    wire        ID_Branch;
    wire        ID_BranchNotEqual;
    wire        ID_Jump;
    wire [1:0]  ID_ALUOp;

    MainControlUnit main_control(
        .Op(ID_Opcode),
        .RegDst(ID_RegDst),
        .ALUSrc(ID_ALUSrc),
        .MemtoReg(ID_MemtoReg),
        .RegWrite(ID_RegWrite),
        .MemRead(ID_MemRead),
        .MemWrite(ID_MemWrite),
        .Branch(ID_Branch),
        .BranchNotEqual(ID_BranchNotEqual),
        .Jump(ID_Jump),
        .ALUOp(ID_ALUOp)
    );

    wire        ID_EX_Flush;
    wire [4:0]  ID_EX_Rt;
    wire        ID_EX_MemRead;

    HazardDetectionUnit hazard_unit(
        .IF_ID_Rs(ID_Rs),
        .IF_ID_Rt(ID_Rt),
        .ID_EX_Rt(ID_EX_Rt),
        .ID_EX_MemRead(ID_EX_MemRead),
        .BranchTaken(PCSrc),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .ID_EX_Flush(ID_EX_Flush),
        .IF_ID_Flush(IF_ID_Flush)
    );

    wire [31:0] ID_ReadData1;
    wire [31:0] ID_ReadData2;
    wire [4:0]  MEM_WB_WriteReg;
    wire [31:0] WB_WriteData;
    wire        MEM_WB_RegWrite;

    RegFile32 regfile(
        .clk(clk),
        .reset(reset),
        .ReadReg1(ID_Rs),
        .ReadReg2(ID_Rt),
        .WriteReg(MEM_WB_WriteReg),
        .WriteData(WB_WriteData),
        .RegWrite(MEM_WB_RegWrite),
        .ReadData1(ID_ReadData1),
        .ReadData2(ID_ReadData2)
    );

    wire [31:0] ID_SignExtImm;
    SignExtend sign_extend(
        .out(ID_SignExtImm),
        .in(ID_Imm16)
    );

    // ID/EX Pipeline Register
    wire        ID_EX_RegDst;
    wire [1:0]  ID_EX_ALUOp;
    wire        ID_EX_ALUSrc;
    wire        ID_EX_Branch;
    wire        ID_EX_BranchNotEqual;
    wire        ID_EX_MemWrite;
    wire        ID_EX_RegWrite;
    wire        ID_EX_MemtoReg;
    wire [31:0] ID_EX_PC_plus_4;
    wire [31:0] ID_EX_ReadData1;
    wire [31:0] ID_EX_ReadData2;
    wire [31:0] ID_EX_SignExtImm;
    wire [4:0]  ID_EX_Rs;
    wire [4:0]  ID_EX_Rd;

    ID_EX id_ex_reg(
        .clk(clk),
        .reset(reset),
        .write_en(1'b1),
        .flush(ID_EX_Flush),
        .RegDst_in(ID_RegDst),
        .ALUOp_in(ID_ALUOp),
        .ALUSrc_in(ID_ALUSrc),
        .Branch_in(ID_Branch),
        .BranchNotEqual_in(ID_BranchNotEqual),
        .MemRead_in(ID_MemRead),
        .MemWrite_in(ID_MemWrite),
        .RegWrite_in(ID_RegWrite),
        .MemtoReg_in(ID_MemtoReg),
        .PC_plus_4_in(IF_ID_PC_plus_4),
        .ReadData1_in(ID_ReadData1),
        .ReadData2_in(ID_ReadData2),
        .SignExtImm_in(ID_SignExtImm),
        .Rs_in(ID_Rs),
        .Rt_in(ID_Rt),
        .Rd_in(ID_Rd),
        .RegDst_out(ID_EX_RegDst),
        .ALUOp_out(ID_EX_ALUOp),
        .ALUSrc_out(ID_EX_ALUSrc),
        .Branch_out(ID_EX_Branch),
        .BranchNotEqual_out(ID_EX_BranchNotEqual),
        .MemRead_out(ID_EX_MemRead),
        .MemWrite_out(ID_EX_MemWrite),
        .RegWrite_out(ID_EX_RegWrite),
        .MemtoReg_out(ID_EX_MemtoReg),
        .PC_plus_4_out(ID_EX_PC_plus_4),
        .ReadData1_out(ID_EX_ReadData1),
        .ReadData2_out(ID_EX_ReadData2),
        .SignExtImm_out(ID_EX_SignExtImm),
        .Rs_out(ID_EX_Rs),
        .Rt_out(ID_EX_Rt),
        .Rd_out(ID_EX_Rd)
    );

    // =========================================================================
    // 3. EX (Execute) Stage
    // =========================================================================
    wire [31:0] EX_BranchTarget;
    assign EX_BranchTarget = ID_EX_PC_plus_4 + (ID_EX_SignExtImm << 2);

    wire [1:0]  ForwardA;
    wire [1:0]  ForwardB;
    wire [4:0]  EX_MEM_WriteReg;
    wire        EX_MEM_RegWrite;
    wire [31:0] EX_MEM_ALUResult;

    DataForwardingUnit forwarding_unit(
        .ID_EX_Rs(ID_EX_Rs),
        .ID_EX_Rt(ID_EX_Rt),
        .EX_MEM_WriteReg(EX_MEM_WriteReg),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_WriteReg(MEM_WB_WriteReg),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // ALU Input Muxes with Data Forwarding
    reg [31:0] EX_ALU_InA;
    always @(*) begin
        case (ForwardA)
            2'b00: EX_ALU_InA = ID_EX_ReadData1;
            2'b10: EX_ALU_InA = EX_MEM_ALUResult;
            2'b01: EX_ALU_InA = WB_WriteData;
            default: EX_ALU_InA = ID_EX_ReadData1;
        endcase
    end

    reg [31:0] EX_Forwarded_DataB;
    always @(*) begin
        case (ForwardB)
            2'b00: EX_Forwarded_DataB = ID_EX_ReadData2;
            2'b10: EX_Forwarded_DataB = EX_MEM_ALUResult;
            2'b01: EX_Forwarded_DataB = WB_WriteData;
            default: EX_Forwarded_DataB = ID_EX_ReadData2;
        endcase
    end

    wire [31:0] EX_ALU_InB = ID_EX_ALUSrc ? ID_EX_SignExtImm : EX_Forwarded_DataB;

    wire [2:0]  EX_ALUControl;
    ALUControlUnit alu_control(
        .ALUOp(ID_EX_ALUOp),
        .FuncField(ID_EX_SignExtImm[5:0]),
        .Operation(EX_ALUControl)
    );

    wire [31:0] EX_ALUResult;
    wire        EX_Zero;
    wire        EX_Carry;

    ALU alu_inst(
        .in1(EX_ALU_InA),
        .in2(EX_ALU_InB),
        .ALUControl(EX_ALUControl),
        .Result(EX_ALUResult),
        .Zero(EX_Zero),
        .Carry(EX_Carry)
    );

    wire [4:0] EX_WriteReg = ID_EX_RegDst ? ID_EX_Rd : ID_EX_Rt;

    // EX/MEM Pipeline Register
    wire        EX_MEM_Branch;
    wire        EX_MEM_BranchNotEqual;
    wire        EX_MEM_MemRead;
    wire        EX_MEM_MemWrite;
    wire        EX_MEM_MemtoReg;
    wire        EX_MEM_Zero;
    wire [31:0] EX_MEM_WriteData;

    EX_MEM ex_mem_reg(
        .clk(clk),
        .reset(reset),
        .write_en(1'b1),
        .flush(PCSrc),
        .Branch_in(ID_EX_Branch),
        .BranchNotEqual_in(ID_EX_BranchNotEqual),
        .MemRead_in(ID_EX_MemRead),
        .MemWrite_in(ID_EX_MemWrite),
        .RegWrite_in(ID_EX_RegWrite),
        .MemtoReg_in(ID_EX_MemtoReg),
        .BranchTarget_in(EX_BranchTarget),
        .Zero_in(EX_Zero),
        .ALUResult_in(EX_ALUResult),
        .WriteData_in(EX_Forwarded_DataB),
        .WriteReg_in(EX_WriteReg),
        .Branch_out(EX_MEM_Branch),
        .BranchNotEqual_out(EX_MEM_BranchNotEqual),
        .MemRead_out(EX_MEM_MemRead),
        .MemWrite_out(EX_MEM_MemWrite),
        .RegWrite_out(EX_MEM_RegWrite),
        .MemtoReg_out(EX_MEM_MemtoReg),
        .BranchTarget_out(EX_MEM_BranchTarget),
        .Zero_out(EX_MEM_Zero),
        .ALUResult_out(EX_MEM_ALUResult),
        .WriteData_out(EX_MEM_WriteData),
        .WriteReg_out(EX_MEM_WriteReg)
    );

    // =========================================================================
    // 4. MEM (Memory Access) Stage
    // =========================================================================
    assign PCSrc = (EX_MEM_Branch & EX_MEM_Zero) | (EX_MEM_BranchNotEqual & ~EX_MEM_Zero);

    wire [31:0] MEM_MemReadData;

    DataMemory32 dmem_inst(
        .clk(clk),
        .reset(reset),
        .MemRead(EX_MEM_MemRead),
        .MemWrite(EX_MEM_MemWrite),
        .Address(EX_MEM_ALUResult),
        .WriteData(EX_MEM_WriteData),
        .ReadData(MEM_MemReadData)
    );

    // MEM/WB Pipeline Register
    wire        MEM_WB_MemtoReg;
    wire [31:0] MEM_WB_MemReadData;
    wire [31:0] MEM_WB_ALUResult;

    MEM_WB mem_wb_reg(
        .clk(clk),
        .reset(reset),
        .write_en(1'b1),
        .RegWrite_in(EX_MEM_RegWrite),
        .MemtoReg_in(EX_MEM_MemtoReg),
        .MemReadData_in(MEM_MemReadData),
        .ALUResult_in(EX_MEM_ALUResult),
        .WriteReg_in(EX_MEM_WriteReg),
        .RegWrite_out(MEM_WB_RegWrite),
        .MemtoReg_out(MEM_WB_MemtoReg),
        .MemReadData_out(MEM_WB_MemReadData),
        .ALUResult_out(MEM_WB_ALUResult),
        .WriteReg_out(MEM_WB_WriteReg)
    );

    // =========================================================================
    // 5. WB (Write Back) Stage
    // =========================================================================
    assign WB_WriteData = MEM_WB_MemtoReg ? MEM_WB_MemReadData : MEM_WB_ALUResult;

    // Probe Outputs for Testbench & Waveform Inspection
    assign probe_PC          = PC_current;
    assign probe_instruction = IF_instruction;
    assign probe_ALUResult   = EX_MEM_ALUResult;
    assign probe_WriteReg    = MEM_WB_WriteReg;
    assign probe_WriteData   = WB_WriteData;
    assign probe_RegWrite    = MEM_WB_RegWrite;
    assign probe_Stall       = ~PCWrite;

endmodule
