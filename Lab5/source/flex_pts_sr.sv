// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/23/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Parallel-to-Serial Shift Register

module flex_pts_sr
#(parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1)
(
	input clk,
	input n_rst,
	input shift_enable,
        input load_enable,
	input [(NUM_BITS - 1):0] parallel_in,
	output serial_out
);

logic [(NUM_BITS - 1):0] state, next_state;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      state <= 0;
    end
    else begin
      state <= next_state;
     end
  end

// Next state logic
always_comb begin
  next_state = state; // default is current state

  if (load_enable == 1) begin
    next_state = parallel_in;
  end else if (shift_enable == 1) begin
    next_state = {0, state[(NUM_BITS - 1):1]};
  end
end

assign serial_out = state[0];

endmodule

