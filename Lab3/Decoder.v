module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o,
    Jal_o,
    Rt_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;
  output Jal_o;
  output Rt_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  //parameter Op Field[31:26]
  parameter RType= 6'b000000;
  parameter addi = 6'b010011;
  parameter lw   = 6'b011000;
  parameter sw   = 6'b101000;
  parameter beq  = 6'b011001;
  parameter bne  = 6'b011010;
  parameter jump = 6'b001100;
  parameter jal  = 6'b001111;
  parameter blt  = 6'b011100;
  parameter bnez = 6'b011101;
  parameter bgez = 6'b011110;
  
  //Main function
  /*your code here*/
  assign RegWrite_o = (instr_op_i == RType) || (instr_op_i == addi) || (instr_op_i == lw) || (instr_op_i == jal);
  assign ALUOp_o =  (instr_op_i == RType) ? 3'b010 :
                    (instr_op_i == addi) ? 3'b011 :
                    (instr_op_i == lw) || (instr_op_i == sw) ? 3'b000 :
                    (instr_op_i == beq) ? 3'b001 :
                    (instr_op_i == bne) || (instr_op_i == bnez) ? 3'b110 :
                    (instr_op_i == blt) ? 3'b100 :
                    (instr_op_i == bgez) ? 3'b101 : 3'b000;
  assign ALUSrc_o = (instr_op_i == RType) ? 1'b0 :
                    (instr_op_i == addi) || (instr_op_i == lw) || (instr_op_i == sw) ? 1'b1 : 1'b0;
  assign RegDst_o = (instr_op_i == RType) ? 1'b1 : 1'b0;
  assign Branch_o =  (instr_op_i == bne) || (instr_op_i == beq) || (instr_op_i == bnez) || (instr_op_i == blt) || (instr_op_i == bgez);
  assign MemRead_o = (instr_op_i == lw);
  assign MemWrite_o = (instr_op_i == sw);
  assign MemtoReg_o = (instr_op_i == lw);
  assign Jump_o =  (instr_op_i == jump) || (instr_op_i == jal);
  assign BranchType_o=(instr_op_i == beq) ? 1'b0 :
                      (instr_op_i == bne) || (instr_op_i == bnez) || (instr_op_i == blt) ? 1'b1 : 1'b0;
  assign Jal_o =		(instr_op_i == jal) ? 1'b1 : 1'b0;
  assign Rt_o =		(instr_op_i == bnez || instr_op_i == bgez) ? 1'b1 : 1'b0;

   
  

endmodule
