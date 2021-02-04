// $Id: $
// File name:   adder_8bit.sv
// Created:     2/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 8-bit Adder Wrapper File

module adder_8bit
(
	input wire [7:0] a,
	input wire [7:0] b,
	input wire carry_in,
	output wire [7:0] sum,
	output wire overflow
);

	// STUDENT: Fill in the correct port map with parameter override syntax for using your n-bit ripple carry adder design to be an 8-bit ripple carry adder design
adder_nbit #(.BIT_WIDTH(8)) DUT (.a(a), .b(b), .carry_in(carry_in), .sum(sum), .overflow(overflow));
endmodule
