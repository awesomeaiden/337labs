// $Id: $
// File name:   rcu.sv
// Created:     3/3/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: RCU

module rcu
(
	input clk,
	input n_rst,
	input start_bit_detected,
	input packet_done,
	input framing_error,
	output sbc_clear,
        output sbc_enable,
	output load_buffer,
        output enable_timer
);

logic [3:0] state, next_state;

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
  next_state = state; // default

  case (state)
    3'b000: begin
      if (start_bit_detected == 1)
        next_state = 3'b001;
    end
    3'b001: begin
      next_state == 3'b010;
    end
    3'b010: begin
      if (packet_done == 1)
        next_state = 3'b011;
    end
    3'b011: begin
      if (framing_error == 1)
        next_state = 3'b000;
      else
        next_state = 3'b100;
    end
    3'b100: begin
      next_state = 3'b00;
    end
  endcase  
end

// Output logic
always_comb begin
  sbc_clear = 0; // default
  sbc_enable = 0; // default
  load_buffer = 0; // default
  enable_timer = 0; // default

  case (state)
    3'b001: begin
      sbc_clear = 1;
      enable_timer = 1;
    end
    3'b010: begin
      enable_timer = 1;
    end
    3'b011: begin
      sbc_enable = 1;
    end
    3'b100: begin
      load_buffer = 1;
    end
  endcase
end
  
endmodule

