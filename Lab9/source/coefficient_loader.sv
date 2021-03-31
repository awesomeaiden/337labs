// $Id: $
// File name:   coefficient_loader.sv
// Created:     3/31/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Coefficient loader

module coefficient_loader
(
	input clk,
	input n_reset,
	input new_coefficient_set,
        input modwait,
        output load_coeff,
        output [1:0] coefficient_num
);

logic [2:0] state, next_state;
logic ld_cf;
logic [1:0] cf_num;

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
    3'b000: begin // idle
      if (new_coefficient_set == 1'b1) begin
        next_state = 3'b001;
      end
    end
    3'b001: begin // load f0
      next_state = 3'b010;
    end
    3'b010: begin // wait
  endcase  
end

// Output logic
always_comb begin
  load_coeff = 1'b0; // default
  coefficient_num = 2'b00; // default

  case (state)
    3'b000: begin
    end
  endcase
end


endmodule

