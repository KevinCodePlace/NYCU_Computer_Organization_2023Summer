module MUX2to1(input bit0, bit1, selectLine, output muxOutput );
    wire andResult0, andResult1;
    and (andResult0, bit0, ~selectLine),
        (andResult1, bit1, selectLine);
    or (muxOutput, andResult0, andResult1);
endmodule

