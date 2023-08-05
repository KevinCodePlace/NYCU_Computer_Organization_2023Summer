module Program_Counter (
    clk_i,
    rst_n,
    pc_in_i,
    pc_out_o
);

  //I/O ports
  input clk_i; //input clock signal, triggering changes based on its clock edges (rising or falling)
  input rst_n; //reset signal. It's used to reset the state of the circuit to a known condition
  input [32-1:0] pc_in_i;// the value to be loaded into the program counter
  output [32-1:0] pc_out_o; //the current value of the program counter

  //Internal Signals
  reg [32-1:0] pc_out_o; //reg doesn't necessarily mean it's a physical register, it's just an element that can hold a value

  //Main function
  //Defines a block of code that gets evaluated every time there is a positive edge in the clock signal. If the reset signal is active, the program counter output is reset to 0, or gets updated with the new value from the input.
  always @(posedge clk_i) begin 
    if (~rst_n) pc_out_o <= 0;
    else pc_out_o <= pc_in_i;
  end

endmodule
