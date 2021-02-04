// $Id: $
// File name:   adder_1bit.sv
// Created:     1/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 1-bit Full Adder

module adder_1bit (a, b, carry_in, sum, carry_out);
  input a, b, carry_in;
  output sum, carry_out;

  assign sum = carry_in ^ (a ^ b);
  assign carry_out = ((~carry_in) & a & b) | (carry_in & (a | b));
endmodule
