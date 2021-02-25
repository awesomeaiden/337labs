// $Id: $
// File name:   mealy.sv
// Created:     2/24/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Mealy Machine '1101' Detector

module mealy
(
	input clk,
	input n_rst,
	input i,
	output o
);

logic [1:0] state, next_state;
logic out;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      state <= 2'b00;
    end
    else begin
      state <= next_state;
     end
  end

// Next state logic
always_comb begin
  next_state = state; // default is current state
  out = 1'b0; // default is 0
  
  case (state)
    2'b00: begin
      if (i == 1)
        next_state = 2'b01;
    end
    2'b01: begin
      if (i == 1)
        next_state = 2'b10;
      else
        next_state = 2'b00;
    end
    2'b10: begin
      if (i == 0)
        next_state = 2'b11;
    end
    2'b11: begin
      if (i == 1) begin
        next_state = 2'b01;
        out = 1'b1;
      end
      else
        next_state = 2'b00;
    end
  endcase
  
end

assign o = out;

endmodule

