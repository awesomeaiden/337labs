// $Id: $
// File name:   flex_counter.sv
// Created:     2/11/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter

module flex_counter
#(parameter NUM_CNT_BITS = 4)
(
	input clk,
	input n_rst,
	input clear,
	input count_enable,
	input [NUM_CNT_BITS:0] rollover_val,
	output [NUM_CNT_BITS:0] count_out,
	output rollover_flag
);

  
endmodule

