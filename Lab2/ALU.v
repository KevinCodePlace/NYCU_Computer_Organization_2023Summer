`include "ALU_1bit.v"
`include "MUX4to1.v"
`include "MUX2to1.v"
`include "ALU31.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  wire [32:1] carryOutBits; 
  wire setResult;
  
  //ALU0 carryIn is invertB, Get set from ALU31
  ALU_1bit firstALU( aluSrc1[0], aluSrc2[0], invertA, invertB, operation, invertB, setResult, result[0], carryOutBits[1] );

  //Generate 1~30ALU
  genvar index;
  generate
	  for(index = 1; index < 31; index = index + 1)
			ALU_1bit eachALUbit( aluSrc1[index], aluSrc2[index], invertA, invertB, operation, carryOutBits[index], 1'b0, result[index], carryOutBits[index + 1] );
  endgenerate
	
  //ALU31
  ALU31 finalALU( aluSrc1[31], aluSrc2[31], invertA, invertB, operation, carryOutBits[31], 1'b0 , result[31], carryOutBits[32], setResult, overflow );
	
  //Get zero
  nor (zero, result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]);
	
endmodule
