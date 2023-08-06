module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output reg [32-1:0] result;
  output wire zero;
  output wire overflow;

  //Main function
  /*your code here*/
  assign zero = (result==0);
  always @(ALU_operation_i, aluSrc1, aluSrc2) begin
    case (ALU_operation_i)
      4'b0001: result <= aluSrc1 & aluSrc2;
      4'b0011: result <= aluSrc1 | aluSrc2;
      4'b0110: result <= $signed(aluSrc1) + $signed(aluSrc2);
      4'b1001: result <= $signed(aluSrc1) - $signed(aluSrc2);
      4'b1100: result <= $signed(aluSrc1) < $signed(aluSrc2) ? 32'h00000001 : 32'h00000000;
      4'b1111: result <= ~(aluSrc1 | aluSrc2);
      default: result <= 32'h00000000;
    endcase
  end

endmodule
