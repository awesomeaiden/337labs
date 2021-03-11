// $Id: $
// File name:   counter.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Counter for FIR filter

module counter
(
  input wire clk,
  input wire n_rst,
  input wire cnt_up,
  input wire clear,
  output wire [9:0] cnt,
  output wire one_k_samples
);

  flex_counter #(.NUM_CNT_BITS(10))
  CNT1 (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(cnt_up),
    .rollover_val(10'b1111101000),
    .clear(clear),
    .count_out(cnt),
    .rollover_flag(one_k_samples)
  );
  
endmodule
