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

logic [2:0] state, next_state;
logic clear, enable, buffer, timer;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      state <= 3'b000;
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
      next_state = 3'b010;
    end
    3'b010: begin
      if (packet_done == 1)
        next_state = 3'b011;
    end
    3'b011: begin
      next_state = 3'b100;
    end
    3'b100: begin
      if (framing_error == 1) begin
        next_state = 3'b000;
      end else begin
        next_state = 3'b101;
      end
    end
    3'b101: begin
      next_state = 3'b000;
    end
  endcase  
end

// Output logic
always_comb begin
  clear = 0; // default
  enable = 0; // default
  buffer = 0; // default
  timer = 0; // default

  case (state)
    3'b001: begin
      clear = 1;
      timer = 1;
    end
    3'b010: begin
      timer = 1;
    end
    3'b011: begin
      enable = 1;
    end
    3'b100: begin
      enable = 1;
    end
    3'b101: begin
      buffer = 1;
    end
  endcase
end

assign sbc_clear = clear;
assign sbc_enable = enable;
assign load_buffer = buffer;
assign enable_timer = timer;
  
endmodule

