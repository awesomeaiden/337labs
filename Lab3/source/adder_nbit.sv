// $Id: $
// File name:   adder_nbit.sv
// Created:     2/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Parameterized Ripple Carry Adder

`timescale 1ns / 100ps

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
      always @ (a[i], b[i])
      begin
        assert ((a[i] == 1'b1) || (a[i] == 1'b0))
        else $error("Input 'a' of component is not a digital logic value");
        assert ((b[i] == 1'b1) || (b[i] == 1'b0))
        else $error("Input 'b' of component is not a digital logic value");
      end
      adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i + 1]));
      always @ (a[i], b[i], carrys[i])
      begin
        #(2) assert (((a[i] + b[i] + carrys[i]) % 2) == sum[i])
        else $error("Output 'sum' of 1 bit adder is not correct");
        #(2) assert (((a[i] & b[i]) | (carrys[i] & (a[i] ^ b[i]))) == carrys[i+1])
        else $error("Output 'carry_out' of 1 bit adder is not correct");
      end
    end
  endgenerate
  assign overflow = carrys[BIT_WIDTH];
endmodule

