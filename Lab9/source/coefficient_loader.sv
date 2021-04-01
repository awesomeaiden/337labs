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
	output clear_new_coeff,
  output [1:0] coefficient_num
);

logic [3:0] state, next_state;
logic ld_cf, clr_cf;
logic [1:0] cf_num;

// State register
always_ff @ (posedge clk, negedge n_reset)
  begin
    if (n_reset == 0) begin
      state <= 4'b000;
    end
    else begin
      state <= next_state;
     end
  end

// Next state logic
always_comb begin
  next_state = state; // default

  case (state)
    4'b0000: begin // idle
      if (new_coefficient_set == 1'b1) begin
        next_state = 4'b0001;
      end
    end
    4'b0001: begin // load f0
      next_state = 4'b0010;
    end
    4'b0010: begin // wait
      if (modwait == 1'b0) begin
	next_state = 4'b0011;
      end
    end
    4'b0011: begin // load f1
      next_state = 4'b0100;
    end
    4'b0100: begin // wait
      if (modwait == 1'b0) begin
        next_state = 4'b0101;
      end
    end
    4'b0101: begin // load f2
      next_state = 4'b0110;
    end
    4'b0110: begin // wait
      if (modwait == 1'b0) begin
        next_state = 4'b0111;
      end
    end
    4'b0111: begin // load f3
      next_state = 4'b1000;
    end
    4'b1000: begin // wait
      if (modwait == 1'b0) begin
        next_state = 4'b1001;
      end
    end
		4'b1001: begin // clear
		  next_state = 4'b0000;
		end
  endcase
end

// Output logic
always_comb begin
  ld_cf = 1'b0; // default
	clr_cf = 1'b0; // default
  cf_num = 2'b00; // default

  case (state)
    4'b0001: begin // load f0
      ld_cf = 1'b1;
      cf_num = 2'b00;
    end
    4'b0010: begin // wait f0
      cf_num = 2'b00;
    end
    4'b0011: begin // load f1
      ld_cf = 1'b1;
      cf_num = 2'b01;
    end
    4'b0100: begin // wait f1
      cf_num = 2'b01;
    end
    4'b0101: begin // load f2
      ld_cf = 1'b1;
      cf_num = 2'b10;
    end
    4'b0110: begin // wait f2
      cf_num = 2'b10;
    end
    4'b0111: begin // load f3
      ld_cf = 1'b1;
      cf_num = 2'b11;
    end
    4'b1000: begin // wait f3
      cf_num = 2'b11;
    end
		4'b1001: begin // clear
		  clr_cf = 1'b1;
		end
  endcase
end

assign load_coeff = ld_cf;
assign clear_new_coeff = clr_cf;
assign coefficient_num = cf_num;

endmodule
