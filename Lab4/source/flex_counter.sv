// $Id: $
// File name:   flex_counter.sv
// Created:     2/11/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter

module flex_counter
#(parameter NUM_CNT_BITS = 3)
(
	input clk,
	input n_rst,
	input clear,
	input count_enable,
	input [NUM_CNT_BITS:0] rollover_val,
	output [NUM_CNT_BITS:0] count_out,
	output rollover_flag
);

logic [NUM_CNT_BITS:0] count, next_count;
logic roll_flag;

// Count register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      count <= 0;
    end
    else
      count <= next_count;
  end

// Next state logic - dataflow or behavioral
// Also where our roll_flag is registered
always_comb begin
  next_count = count; // default is current count
  roll_flag = 0; // default is 0

  if (clear == 1) begin
    next_count = 0;
  end
  else begin
    if ((next_count + 1) > rollover_val) begin
      roll_flag = 1;
    end
    if (count_enable == 1) begin
      next_count = count + 1;
    end
    if (next_count > rollover_val) begin
      next_count = 1;
    end
  end

end

assign count_out = count;
assign rollover_flag = roll_flag;

  
endmodule

