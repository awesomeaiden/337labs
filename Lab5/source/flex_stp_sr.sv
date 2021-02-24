// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/18/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Serial-to-Parallel Shift Register

module flex_stp_sr
#(parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1)
(
	input clk,
	input n_rst,
	input shift_enable,
	input serial_in,
	output [(NUM_BITS - 1):0] parallel_out
);

logic [(NUM_BITS- 1):0] state, next_state;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      state <= ~0;
    end
    else begin
      state <= next_state;
     end
  end

// Next state logic
always_comb begin
  next_state = state; // default is current state

  if (shift_enable == 1) begin
    if (SHIFT_MSB == 1) begin
      next_state = {state[(NUM_BITS - 2):0], serial_in};
    end else begin
      next_state = {serial_in, state[(NUM_BITS - 1):1]};
    end
  end
end

assign parallel_out = state;

endmodule

