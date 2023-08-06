`include "Program_Counter.v"
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

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [32-1:0] incremented_pc;
  wire [32-1:0] pc_to_instr;
  wire [32-1:0] instruction_output;
  wire [5-1:0] write_to_register;
  wire reg_dest_signal;
  wire reg_write_signal;
  wire [3-1:0] alu_op_signal;
  wire alu_source_signal;
  wire [32-1:0] write_data_signal;
  wire [32-1:0] source_reg_data;
  wire [32-1:0] target_reg_data;
  wire [4-1:0] alu_control_signal;
  wire leftRight_signal;
  wire [2-1:0] fun_unit_res_signal;
  wire [32-1:0] signed_instr_signal;
  wire [32-1:0] zero_filled_instr_signal;
  wire [32-1:0] alu_shifter_source_signal;
  wire zero_flag;
  wire [32-1:0] alu_result_signal;
  wire [32-1:0] shifter_result_signal;
  wire overflow_flag;
  wire [5-1:0] shift_amount_source_signal;
  // MEM-WB
  wire [32-1:0] mem_read_data;
  wire [32-1:0] write_back_data;
  // Control decode signals
  wire branch_signal;
  wire mem_write_signal;
  wire mem_read_signal;
  wire mem_to_reg_signal;
  wire jump_signal;
  wire branch_type_signal;
  wire target_reg_signal;
  // PC signals
  wire [32-1:0] branch_add_pc;
  wire [32-1:0] branch_pc_signal;
  wire [32-1:0] jump_pc_signal;
  wire [32-1:0] jr_pc_signal;
  wire pc_source_signal;
  // Reg Jal
  wire [5-1:0] jal_write_to_register;
  wire [32-1:0] jal_write_back_data;
  wire jal_signal;


  //modules

  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(jr_pc_signal),
      .pc_out_o(pc_to_instr)
  );

  Adder Adder1 (
      .src1_i(pc_to_instr),
      .src2_i(32'd4),
      .sum_o (incremented_pc)
  );

  Adder Adder2 (
      .src1_i(incremented_pc),
      .src2_i(signed_instr_signal << 2),
      .sum_o (branch_add_pc)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (incremented_pc),
      .data1_i (branch_add_pc),
      .select_i(branch_signal & pc_source_signal),
      .data_o  (branch_pc_signal)
  );

  Mux2to1 #(.size(1)) BranchType_Mux(
    .data0_i(zero_flag),
    .data1_i(~zero_flag),
    .select_i(branch_type_signal),
    .data_o(pc_source_signal)
);

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (branch_pc_signal),
      .data1_i ({incremented_pc[31:28], instruction_output[27:0] << 2}),
      .select_i(jump_signal),
      .data_o  (jump_pc_signal)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jr (
      .data0_i (jump_pc_signal),
      .data1_i (source_reg_data),
      .select_i(~instruction_output[5] & ~instruction_output[4] & instruction_output[3] & ~instruction_output[2] & ~instruction_output[1] & ~instruction_output[0] & reg_dest_signal),
      .data_o  (jr_pc_signal)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_to_instr),
      .instr_o  (instruction_output)
  );

  Mux2to1 #(
      .size(5)
  ) Jal_Reg_Mux (
      .data0_i (write_to_register),
      .data1_i (5'b11111),
      .select_i(jal_signal),
      .data_o  (jal_write_to_register)
  );

  Mux2to1 #(
      .size(32)
  ) Jal_WB_Mux (
      .data0_i (write_back_data),
      .data1_i (incremented_pc),
      .select_i(jal_signal),
      .data_o  (jal_write_back_data)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (instruction_output[20:16]),
      .data1_i (instruction_output[15:11]),
      .select_i(reg_dest_signal),
      .data_o  (write_to_register)
  );
  
  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instruction_output[25:21]),
      .RTaddr_i(instruction_output[20:16]),
      .RDaddr_i(jal_write_to_register),
      .RDdata_i(jal_write_back_data),
      .RegWrite_i(reg_write_signal),
      .RSdata_o(source_reg_data),
      .RTdata_o(target_reg_data)
  );

  Decoder Decoder (
      .instr_op_i(instruction_output[32-1:26]),
      .RegWrite_o(reg_write_signal),
      .ALUOp_o(alu_op_signal),
      .ALUSrc_o(alu_source_signal),
      .RegDst_o(reg_dest_signal),
      .Jump_o(jump_signal),
      .Branch_o(branch_signal),
      .BranchType_o(branch_type_signal),
      .MemRead_o(mem_read_signal),
      .MemWrite_o(mem_write_signal),
      .MemtoReg_o(mem_to_reg_signal),
      .Jal_o(jal_signal),
      .Rt_o(target_reg_signal)
  );

  ALU_Ctrl AC (
      .funct_i(instruction_output[6-1:0]),
      .ALUOp_i(alu_op_signal),
      .ALU_operation_o(alu_control_signal),
      .FURslt_o(fun_unit_res_signal),
      .leftRight_o(leftRight_signal)
  );

  Sign_Extend SE (
      .data_i(instruction_output[15:0]),
      .data_o(signed_instr_signal)
  );

  Zero_Filled ZF (
      .data_i(instruction_output[15:0]),
      .data_o(zero_filled_instr_signal)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (target_reg_data),
      .data1_i (signed_instr_signal),
      .select_i(alu_source_signal),
      .data_o  (alu_shifter_source_signal)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (instruction_output[10:6]),
      .data1_i (source_reg_data[5-1:0]),
      .select_i(alu_control_signal[1]),
      .data_o  (shift_amount_source_signal)
  );

  ALU ALU (
      .aluSrc1(source_reg_data),
      .aluSrc2(target_reg_signal ? 32'b0 : alu_shifter_source_signal),
      .ALU_operation_i(alu_control_signal),
      .result(alu_result_signal),
      .zero(zero_flag),
      .overflow(overflow_flag)
  );

  Shifter shifter (
      .result(shifter_result_signal),
      .leftRight(leftRight_signal),
      .shamt(shift_amount_source_signal),
      .sftSrc(alu_shifter_source_signal)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (alu_result_signal),
      .data1_i (shifter_result_signal),
      .data2_i (zero_filled_instr_signal),
      .select_i(fun_unit_res_signal),
      .data_o  (write_data_signal)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(write_data_signal),
      .data_i(target_reg_data),
      .MemRead_i(mem_read_signal),
      .MemWrite_i(mem_write_signal),
      .data_o(mem_read_data)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(write_data_signal),
      .data1_i(mem_read_data),
      .select_i(mem_to_reg_signal),
      .data_o(write_back_data)
  );

endmodule



