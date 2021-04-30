// $Id: $
// File name:   samp_shift_reg.sv
// Created:     4/29/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Sample Shift Register for AHB Convolver

module samp_shift_reg
#(parameter SHIFT_MSB = 0)
(
  input clk,
  input n_rst,
  input shift_en,
  input [15:0] col_in,
  output [35:0] sample_out
);

logic [11:0] state[2:0], next_state[2:0];

// State register
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    state[0] <= ~0;
    state[1] <= ~0;
    state[2] <= ~0;
  end else begin
    state <= next_state;
  end
end

// Next state logic
always_comb begin
  next_state = state; // default is current state

  if (shift_en == 1) begin
    if (SHIFT_MSB == 1) begin
      next_state = {state[1], state[0], col_in[11:0]};
    end else begin
      next_state = {col_in[11:0], state[2], state[1]};
    end
  end
end

assign sample_out = {state[2], state[1], state[0]};

endmodule

