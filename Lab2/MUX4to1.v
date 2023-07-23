module MUX4to1(input [0:3] inputData, input [1:0] selectLine, output muxOutput );

	wire intermediateResultX, intermediateResultY;
	
	// Implement a 4-to-1 MUX using three 2-to-1 MUXs
	MUX2to1 stagetwoMux1( intermediateResultX, intermediateResultY, selectLine[1], muxOutput );
	MUX2to1 stageoneMux1( inputData[0], inputData[1], selectLine[0], intermediateResultX );
	MUX2to1 stageoneMux2( inputData[2], inputData[3], selectLine[0], intermediateResultY );
	
endmodule
