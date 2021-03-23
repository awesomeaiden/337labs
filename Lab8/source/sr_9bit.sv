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
  input wire [3:0] data_size,
  output wire [7:0] packet_data,
  output wire stop_bit
);

  logic [7:0] par_out;
  logic [7:0] padded_par_out;

  flex_stp_sr #(.NUM_BITS(9), .SHIFT_MSB(0))
  SHIFTR (
    .clk(clk),
    .n_rst(n_rst),
    .shift_enable(shift_strobe),
    .serial_in(serial_in),
    .parallel_out({stop_bit, par_out})
  );

  always_comb begin
    padded_par_out = par_out; // default
    if (data_size == 4'b0111) begin
      padded_par_out = {par_out[7:1], 1'b0};
    end else if (data_size == 4'b0101) begin
      padded_par_out = {par_out[7:3], 3'b000};
    end
  end

  assign packet_data = padded_par_out;

endmodule
