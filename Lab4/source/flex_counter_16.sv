// $Id: $
// File name:   flex_counter_16.sv
// Created:     2/17/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 16-bit Flex Counter Wrapper File

module flex_counter_16
(
	input clk,
	input n_rst,
	input clear,
	input count_enable,
	input [15:0] rollover_val,
	output [15:0] count_out,
	output rollover_flag
);

flex_counter #(.NUM_CNT_BITS(15)) DUT (.clk(clk), 
                                      .n_rst(n_rst), 
                                      .clear(clear), 
                                      .count_enable(count_enable),
                                      .rollover_val(rollover_val),
                                      .count_out(count_out),
                                      .rollover_flag(rollover_flag));
endmodule
