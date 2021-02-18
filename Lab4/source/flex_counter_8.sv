// $Id: $
// File name:   flex_counter_8.sv
// Created:     2/17/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 8-bit Flex Counter Wrapper File

module flex_counter_8
(
	input clk,
	input n_rst,
	input clear,
	input count_enable,
	input [7:0] rollover_val,
	output [7:0] count_out,
	output rollover_flag
);

flex_counter #(.NUM_CNT_BITS(7)) DUT (.clk(clk), 
                                      .n_rst(n_rst), 
                                      .clear(clear), 
                                      .count_enable(count_enable),
                                      .rollover_val(rollover_val),
                                      .count_out(count_out),
                                      .rollover_flag(rollover_flag));
endmodule
