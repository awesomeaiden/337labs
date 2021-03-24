// $Id: $
// File name:   timer.sv
// Created:     3/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Timer for UART Receiver

module timer
(
  input wire clk,
  input wire n_rst,
  input wire enable_timer,
  input wire [13:0] bit_period,
  input wire [3:0] data_size,
  output wire shift_enable,
  output wire packet_done,
  output wire [13:0] CNT1_out,
  output wire [3:0] CNT2_out
);

  // make timers reset after packet_done

  wire CNT1_roll, tim_clr;
  assign shift_enable = CNT1_roll;
  assign tim_clr = packet_done;

  logic [3:0] cnt2_roll;

  always_comb begin
    cnt2_roll = data_size + 1;
  end

  flex_counter #(.NUM_CNT_BITS(14))
  CNT1 (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(enable_timer),
    .rollover_val(bit_period),
    .clear(tim_clr),
    .count_out(CNT1_out),
    .rollover_flag(CNT1_roll)
  );

  flex_counter #(.NUM_CNT_BITS(4))
  CNT2 (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(CNT1_roll),
    .rollover_val(cnt2_roll),
    .clear(tim_clr),
    .count_out(CNT2_out),
    .rollover_flag(packet_done)
  );
  
endmodule
