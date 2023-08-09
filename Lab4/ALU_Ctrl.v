module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output wire [4-1:0] ALU_operation_o;
  output wire [2-1:0] FURslt_o;
  output wire leftRight_o;


  //Main function
  /*your code here*/
  //parameter

parameter add_func = 6'b100011;
parameter sub_func = 6'b010011;
parameter and_func = 6'b011111;
parameter or_func = 6'b101111;
parameter nor_func = 6'b010000;
parameter slt_func = 6'b010100;
parameter sll_func = 6'b010010;
parameter srl_func = 6'b100010;
parameter sllv_func = 6'b011000;
parameter srlv_func = 6'b101000;
parameter R_type = 3'b010;
parameter addi = 3'b011;
parameter lw  = 3'b000;
parameter sw  = 3'b000;
parameter beq  = 3'b001;
parameter bne  = 3'b110;
parameter blt  = 3'b100;
parameter bnez  = 3'b110;
parameter bgez = 3'b101;


function [0:0] is_rtype_func;
    input [6-1:0] funct_param;
    begin
        is_rtype_func = (ALUOp_i == R_type) && (funct_i == funct_param);
    end
endfunction

//Main function
assign ALU_operation_o =  ({ALUOp_i,funct_i} == {R_type, add_func} || ALUOp_i == addi || ALUOp_i == lw || ALUOp_i == sw) ? 4'b0110 : //add
                           ({ALUOp_i,funct_i} == {R_type, sub_func} || ALUOp_i == beq || ALUOp_i == bne) ? 4'b1001 :  //sub
                           ({ALUOp_i,funct_i} == {R_type, and_func}) ? 4'b0001 :  //and
                           ({ALUOp_i,funct_i} == {R_type, or_func}) ? 4'b0011 :  //or 
                           ({ALUOp_i,funct_i} == {R_type, nor_func}) ? 4'b1111 :  //nor 
                           ({ALUOp_i,funct_i} == {R_type, slt_func} || ALUOp_i == blt || ALUOp_i == bgez) ? 4'b1100 :  //slt
                           ({ALUOp_i,funct_i} == {R_type, sll_func}) ? 4'b0001 :  //sll
                           ({ALUOp_i,funct_i} == {R_type, srl_func}) ? 4'b0011 :  //srl
                           ({ALUOp_i,funct_i} == {R_type, sllv_func}) ? 4'b0110 :  //sllv
                           ({ALUOp_i,funct_i} == {R_type, srlv_func}) ? 4'b0010 : 4'b0000;  //srlv others

//00: lw, sw, beq, bne, blt, bnez, bgez, addi, add, sub, and, or, nor, slt
//01: sll, srl, sllv, srlv
assign FURslt_o = (ALUOp_i == lw || ALUOp_i == sw || ALUOp_i == beq || ALUOp_i == bne || ALUOp_i == blt || ALUOp_i == bnez || ALUOp_i == bgez || ALUOp_i == addi || 
                  {ALUOp_i,funct_i} == {R_type, add_func} || {ALUOp_i,funct_i} == {R_type, sub_func} || {ALUOp_i,funct_i} == {R_type, and_func} || {ALUOp_i,funct_i} == {R_type, or_func} || {ALUOp_i,funct_i} == {R_type, nor_func} || {ALUOp_i,funct_i} == {R_type, slt_func}) ? 2'b00 :
                  ({ALUOp_i,funct_i} == {R_type, sll_func} || {ALUOp_i,funct_i} == {R_type, srl_func} || {ALUOp_i,funct_i} == {R_type, sllv_func} || {ALUOp_i,funct_i} == {R_type, srlv_func}) ? 2'b01 :
                  2'b10;  // others

assign leftRight_o = ({ALUOp_i,funct_i} == {R_type, sll_func} || {ALUOp_i,funct_i} == {R_type, sllv_func}) ? 1'b1:
                     ({ALUOp_i,funct_i} == {R_type, srl_func} || {ALUOp_i,funct_i} == {R_type, srlv_func}) ? 1'b0: 1'b0;

endmodule     

