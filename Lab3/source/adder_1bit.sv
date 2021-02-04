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

  always @ (a, b)
  begin
    assert ((a == 1'b1) || (a == 1'b0))
    else $error("Input 'a' of component is not a digital logic value");
    assert ((b == 1'b1) || (b == 1'b0))
    else $error("Input 'b' of component is not a digital logic value");
  end
endmodule
