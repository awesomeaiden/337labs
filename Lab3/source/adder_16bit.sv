// $Id: $
// File name:   adder_16bit.sv
// Created:     2/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 16-bit Adder Wrapper File

module adder_16bit
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);

	// STUDENT: Fill in the correct port map with parameter override syntax for using your n-bit ripple carry adder design to be an 16-bit ripple carry adder design
adder_nbit #(.BIT_WIDTH(16)) DUT (.a(a), .b(b), .carry_in(carry_in), .sum(sum), .overflow(overflow));
endmodule
