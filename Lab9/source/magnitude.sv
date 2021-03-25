// $Id: $
// File name:   magnitude.sv
// Created:     3/9/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Magnitude

module magnitude
(
	input [16:0] in,
        output [15:0] out
);

logic [15:0] outvar;

always_comb begin
  outvar = in[15:0]; // default
  if (in[16] == 1'b1) // if in is negative
    outvar = (16'b1111111111111111 ^ in[15:0]) + 1;
end

assign out = outvar;
  
endmodule

