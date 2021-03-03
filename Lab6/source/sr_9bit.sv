// $Id: $
// File name:   sr_9bit.sv
// Created:     3/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 9-bit shift register

module sr_9bit
(
  input wire clk,
  input wire n_rst,
  input wire shift_strobe,
  input wire serial_in,
  output wire [7:0] packet_data,
  output wire stop_bit
);

  logic [8:0] reg_data;

  flex_stp_sr #(.NUM_BITS(9), .SHIFT_MSB(0))
  SHIFTR (
    .clk(clk),
    .n_rst(n_rst),
    .shift_enable(shift_strobe),
    .serial_in(serial_in),
    .parallel_out(reg_data)
  );

  assign packet_data = reg_data[7:0];
  assign stop_bit = reg_data[8];

endmodule
