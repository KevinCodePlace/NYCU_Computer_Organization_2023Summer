module Shifter(leftRight, shamt, sftSrc, result);
    
  output [31:0] result;

  input leftRight;
  input [4:0] shamt;
  input [31:0] sftSrc ;
 
  wire [31:0] leftShift0, leftShift1, leftShift2, leftShift3, leftShift4;
  wire [31:0] rightShift0, rightShift1, rightShift2, rightShift3, rightShift4;
 
// Declare genvar
  genvar i;
  
  generate
    for(i = 0; i < 32; i = i + 1)
    begin
        // Instantiate a 2-to-1 multiplexer for every bit in the 32-bit inputs
        MUX2to1 muxInstanceLeft0( sftSrc[i], i > 0 ? sftSrc[i-1] : 1'b0, shamt[0], leftShift0[i] );
        MUX2to1 muxInstanceLeft1( leftShift0[i], i > 1 ? leftShift0[i-2] : 1'b0, shamt[1], leftShift1[i] );
        MUX2to1 muxInstanceLeft2( leftShift1[i], i > 3 ? leftShift1[i-4] : 1'b0, shamt[2], leftShift2[i] );
        MUX2to1 muxInstanceLeft3( leftShift2[i], i > 7 ? leftShift2[i-8] : 1'b0, shamt[3], leftShift3[i] );
        MUX2to1 muxInstanceLeft4( leftShift3[i], i > 15 ? leftShift3[i-16] : 1'b0, shamt[4], leftShift4[i] );
        
        MUX2to1 muxInstanceRight0( sftSrc[i], i < 31 ? sftSrc[i+1] : 1'b0, shamt[0], rightShift0[i] );
        MUX2to1 muxInstanceRight1( rightShift0[i], i < 30 ? rightShift0[i+2] : 1'b0, shamt[1], rightShift1[i] );
        MUX2to1 muxInstanceRight2( rightShift1[i], i < 28 ? rightShift1[i+4] : 1'b0, shamt[2], rightShift2[i] );
        MUX2to1 muxInstanceRight3( rightShift2[i], i < 24 ? rightShift2[i+8] : 1'b0, shamt[3], rightShift3[i] );
        MUX2to1 muxInstanceRight4( rightShift3[i], i < 16 ? rightShift3[i+16] : 1'b0, shamt[4], rightShift4[i] );
        
        // Select between left and right shift
        MUX2to1 finalMux( leftShift4[i], rightShift4[i], leftRight, result[i] );
    end
  endgenerate
endmodule

