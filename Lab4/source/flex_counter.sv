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
// Also rollover flag register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      count <= 0;
      roll_flag <= 0;
    end
    else begin
      count <= next_count;
      if (next_count == rollover_val) begin
        roll_flag <= 1;
      end else begin
        roll_flag <= 0;
      end
     end
  end

// Next state logic
always_comb begin
  next_count = count; // default is current count

  if (clear == 1) begin
    next_count = 0;
  end
  else begin
    if (count_enable == 1) begin
      if (count < rollover_val) begin
        next_count = count + 1;
      end else begin
        next_count = 1;
      end
    end
  end

end

assign count_out = count;
assign rollover_flag = roll_flag;

  
endmodule

