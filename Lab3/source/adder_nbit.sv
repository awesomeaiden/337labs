// $Id: $
// File name:   adder_nbit.sv
// Created:     2/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Parameterized Ripple Carry Adder

module adder_nbit 
#(parameter BIT_WIDTH = 4)
(
	input [(BIT_WIDTH - 1):0] a, 
	input [(BIT_WIDTH - 1):0] b, 
	input carry_in, 
	output [(BIT_WIDTH - 1):0] sum, 
	output overflow
);

  wire [BIT_WIDTH:0] carrys;
  genvar i;

  assign carrys[0] = carry_in;
  generate
  for (i = 0; i <= (BIT_WIDTH - 1); i = i + 1)
    begin
      adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i + 1]));
    end
  endgenerate
  assign overflow = carrys[BIT_WIDTH];
endmodule

