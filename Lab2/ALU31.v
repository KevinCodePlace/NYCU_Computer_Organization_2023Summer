module ALU31 (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut,
	set,
	overflow
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;
  output set;
  output overflow;
  
  // Inverting Inputs if needed
  wire invertedA, invertedB;
  
  // 2-to-1 Multiplexer for deciding whether to invert input A or not
  MUX2to1 muxForInvertA(a, ~a, invertA, invertedA);
  
  // 2-to-1 Multiplexer for deciding whether to invert input B or not
  MUX2to1 muxForInvertB(b, ~b, invertB, invertedB);
  
  // Calculation results for OR, AND, and Addition operations
  wire orResult, andResult, addResult;
  
  or (orResult, invertedA, invertedB); // OR operation
  and (andResult, invertedA, invertedB); // AND operation
  
  // Full Adder for addition operation
  Full_adder adder(carryIn, invertedA, invertedB, addResult, carryOut);
  
  // Selecting the set result
  MUX4to1 setSelectMux({addResult, 1'b0, 1'b1, addResult}, {a, b}, set );
  
  // 4-to-1 Multiplexer for selecting the result based on the operation code
  MUX4to1 resultSelectMux({orResult, andResult, addResult, less}, operation, result );
  
  // Detecting overflow condition
  wire overflowDetected;
  xor (overflowDetected, carryIn, carryOut);
  MUX4to1 overflowSelectMux({1'b0, 1'b0, overflowDetected, overflowDetected}, operation, overflow);
  
endmodule
