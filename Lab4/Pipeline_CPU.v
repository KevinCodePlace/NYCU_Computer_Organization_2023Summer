`include "Program_Counter.v"
`include "Pipe_Reg.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  //IF stages
  wire [32-1:0] IF_added_pc;
  wire [32-1:0] IF_pc_to_im;
  wire [32-1:0] IF_instruction_output;
  // IF_ID Pipeline
  wire [32-1:0] ID_instruction_input;
  // ID stages
  // Decoder
  wire [3-1:0] ID_ALUOp_signal;
  wire ID_RegWrite_signal;
  wire ID_ALUSrc_signal;
  wire ID_RegDst_signal;
  wire ID_Jump_signal;
  wire ID_Branch_signal;
  wire ID_BranchType_signal;
  wire ID_MemRead_signal;
  wire ID_MemWrite_signal;
  wire ID_MemtoReg_signal;
  // Register_File
  wire [32-1:0] ID_rs_data;
  wire [32-1:0] ID_rt_data;
  // Sign_Extended
  wire [32-1:0] ID_signed_instr;
  // Zero_filled
  wire [32-1:0] ID_zero_filled_instr;
  // ID_EX Pipeline
  wire [3-1:0] EX_ALUOp_signal;
  wire EX_RegWrite_signal;
  wire EX_ALUSrc_signal;
  wire EX_RegDst_signal;
  wire EX_MemRead_signal;
  wire EX_MemWrite_signal;
  wire EX_MemtoReg_signal;
  wire [32-1:0] EX_rs_data;
  wire [32-1:0] EX_rt_data;
  wire [32-1:0] EX_signed_instr;
  wire [32-1:0] EX_zero_filled_instr;
  wire [32-1:0] EX_instruction_input;
  // EX stages
  //ALUCtrl
  wire [4-1:0]  EX_ALU_control_signal;
  wire [2-1:0]  EX_FURslt_signal;
  wire EX_leftRight_signal;
  // ALU
  wire [32-1:0] EX_ALUSrc_result;
  wire [32-1:0] EX_ALU_result;
  wire EX_zero_flag;
  wire EX_overflow_flag;
  //Shifter
  wire [32-1:0] EX_shifter_result;
  wire [5-1:0]  EX_write_to_register; 
  wire [32-1:0] EX_write_data;
  // EX_MEM Pipeline
  wire MEM_RegWrite_signal;
  wire MEM_MemRead_signal;
  wire MEM_MemWrite_signal;
  wire MEM_MemtoReg_signal;
  wire [32-1:0] MEM_write_data;
  wire [32-1:0] MEM_rt_data;
  wire [5-1:0]  MEM_write_to_register; 
  // MEM stages
  wire [32-1:0] Mem_read_data;
  // MEM_WB Pipeline
  wire WB_RegWrite_signal;
  wire WB_MemtoReg_signal;
  wire [32-1:0] WB_write_data;
  wire [32-1:0] WB_MemReadData;
  wire [5-1:0]  WB_write_to_register; 
  // WB stages
  wire [32-1:0] WB_write_back_data;
   
  //modules
  //IF stages
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(IF_added_pc),
      .pc_out_o(IF_pc_to_im)
  );

  Adder Adder1 (
      .src1_i(IF_pc_to_im),
      .src2_i(32'd4),
      .sum_o (IF_added_pc)
  );
 
  Instr_Memory IM (
      .pc_addr_i(IF_pc_to_im),
      .instr_o  (IF_instruction_output)
  );

  //IF_ID pipeline
  Pipe_Reg #(.size(32)) Pipeline_IF_ID (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(IF_instruction_output),
    .data_o(ID_instruction_input)
  );
  
  //ID stages
  Decoder Decoder (
      .instr_op_i(ID_instruction_input[32-1:26]),
      .RegWrite_o(ID_RegWrite_signal),
      .ALUOp_o(ID_ALUOp_signal),
      .ALUSrc_o(ID_ALUSrc_signal),
      .RegDst_o(ID_RegDst_signal),
      .Jump_o(ID_Jump_signal),
      .Branch_o(ID_Branch_signal),
      .BranchType_o(ID_BranchType_signal),
      .MemRead_o(ID_MemRead_signal),
      .MemWrite_o(ID_MemWrite_signal),
      .MemtoReg_o(ID_MemtoReg_signal)
  );
  
  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(ID_instruction_input[25:21]),
      .RTaddr_i(ID_instruction_input[20:16]),
      .RDaddr_i(WB_write_to_register),
      .RDdata_i(WB_write_back_data),
      .RegWrite_i(WB_RegWrite_signal),
      .RSdata_o(ID_rs_data),
      .RTdata_o(ID_rt_data)
  );
  
  Sign_Extend SE (
      .data_i(ID_instruction_input[15:0]),
      .data_o(ID_signed_instr)
  );

  Zero_Filled ZF (
      .data_i(ID_instruction_input[15:0]),
      .data_o(ID_zero_filled_instr)
  );

  //ID_EX pipeline
  Pipe_Reg #(.size(9)) Pipeline_ID_EX_Control (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({ID_RegWrite_signal, ID_ALUOp_signal, ID_ALUSrc_signal, ID_RegDst_signal, ID_MemRead_signal, ID_MemWrite_signal, ID_MemtoReg_signal}),
    .data_o({EX_RegWrite_signal, EX_ALUOp_signal, EX_ALUSrc_signal, EX_RegDst_signal, EX_MemRead_signal, EX_MemWrite_signal, EX_MemtoReg_signal})
  );

  Pipe_Reg #(.size(32)) Pipeline_ID_EX_rsdata (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(ID_rs_data),
    .data_o(EX_rs_data)
  );

  Pipe_Reg #(.size(32)) Pipeline_ID_EX_rtdata (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(ID_rt_data),
    .data_o(EX_rt_data)
  );

  Pipe_Reg #(.size(32)) Pipeline_ID_EX_SE (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(ID_signed_instr),
    .data_o(EX_signed_instr)
  );

  Pipe_Reg #(.size(32)) Pipeline_ID_EX_ZF (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(ID_zero_filled_instr),
    .data_o(EX_zero_filled_instr)
  );

  Pipe_Reg #(.size(32)) Pipeline_ID_EX_ID_instr (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(ID_instruction_input),
    .data_o(EX_instruction_input)
  );
  
  
  //EX stages
  ALU_Ctrl AC (
      .funct_i(EX_instruction_input[6-1:0]),
      .ALUOp_i(EX_ALUOp_signal),
      .ALU_operation_o(EX_ALU_control_signal),
      .FURslt_o(EX_FURslt_signal),
      .leftRight_o(EX_leftRight_signal)
  );


  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (EX_rt_data),
      .data1_i (EX_signed_instr),
      .select_i(EX_ALUSrc_signal),
      .data_o  (EX_ALUSrc_result)
  );

  ALU ALU (
      .aluSrc1(EX_rs_data),
      .aluSrc2(EX_ALUSrc_result),
      .ALU_operation_i(EX_ALU_control_signal),
      .result(EX_ALU_result),
      .zero(EX_zero_flag),
      .overflow(EX_overflow_flag)
  );

  Shifter shifter (
      .result(EX_shifter_result),
      .leftRight(EX_leftRight_signal),
      .shamt(EX_instruction_input[10:6]),
      .sftSrc(EX_ALUSrc_result)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (EX_ALU_result),
      .data1_i (EX_shifter_result),
      .data2_i (EX_zero_filled_instr),
      .select_i(EX_FURslt_signal),
      .data_o  (EX_write_data)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_RegDst (
      .data0_i (EX_instruction_input[20:16]),
      .data1_i (EX_instruction_input[15:11]),
      .select_i(EX_RegDst_signal),
      .data_o  (EX_write_to_register)
  );


  //EX_MEM pipeline
  Pipe_Reg #(.size(4)) Pipeline_EX_MEM_Control (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({EX_RegWrite_signal, EX_MemRead_signal, EX_MemWrite_signal, EX_MemtoReg_signal}),
    .data_o({MEM_RegWrite_signal, MEM_MemRead_signal, MEM_MemWrite_signal, MEM_MemtoReg_signal})
  );

  Pipe_Reg #(.size(32)) Pipeline_EX_MEM_WriteData (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(EX_write_data),
    .data_o(MEM_write_data)
  );

  Pipe_Reg #(.size(32)) Pipeline_EX_MEM_rtdata (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(EX_rt_data),
    .data_o(MEM_rt_data)
  );

  Pipe_Reg #(.size(5)) Pipeline_EX_MEM_write_to_register(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i(EX_write_to_register),
    .data_o(MEM_write_to_register)
  );

  //Mem stages
  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(MEM_write_data),
      .data_i(MEM_rt_data),
      .MemRead_i(MEM_MemRead_signal),
      .MemWrite_i(MEM_MemWrite_signal),
      .data_o(Mem_read_data)
  );
  
  //MEM_WB pipeline
  Pipe_Reg #(.size(2)) Pipeline_MEM_WB_Control (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({MEM_RegWrite_signal, MEM_MemtoReg_signal}),
    .data_o({WB_RegWrite_signal, WB_MemtoReg_signal})
  );

  Pipe_Reg #(.size(32)) Pipeline_MEM_WB_WriteData( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(MEM_write_data),
		.data_o(WB_write_data)
		);

  Pipe_Reg #(.size(32)) Pipeline_MEM_WB_MemReadData( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(Mem_read_data),
		.data_o(WB_MemReadData)
		);

  Pipe_Reg #(.size(5)) Pipeline_MEM_WB_Writeto_reg( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(MEM_write_to_register),
		.data_o(WB_write_to_register)
		);		
  // WB stages
  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(WB_write_data),
      .data1_i(WB_MemReadData),
      .select_i(WB_MemtoReg_signal),
      .data_o(WB_write_back_data)
  );
  
endmodule



