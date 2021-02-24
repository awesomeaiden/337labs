// $Id: $
// File name:   moore.sv
// Created:     2/24/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Moore Machine '1101' Detector

module moore
(
	input clk,
	input n_rst,
	input i,
	output o
);

logic [2:0] state, next_state;

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
  next_state = state; // default is current state
  
  case (state)
    3'b000: begin
      if (i == 1)
        next_state = 3'b001;
    end
    3'b001: begin
      if (i == 1)
        next_state = 3'b010;
      else
        next_state = 3'b000;
    end
    3'b010: begin
      if (i == 0)
        next_state = 3'b011;
    end
    3'b011: begin
      if (i == 1)
        next_state = 3'b100;
      else
        next_state = 3'b000;
    end
    3'b100: begin
      if (i == 1)
        next_state = 3'b010;
      else
        next_state = 3'b000;
    end
  endcase
  
end

assign o = (state == 3'b100);

endmodule

