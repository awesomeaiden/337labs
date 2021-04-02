// $Id: $
// File name:   conv_controller.sv
// Created:     4/2/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Convolution Controller

module conv_controller
(
	input clk,
	input n_rst,
	input conv_en,
        input coeff_loaded,
        input sample_loaded,
        input conv_complete,
        input sample_complete,
        output load_coeff,
        output load_sample,
        output start_conv,
        output shift,
        output result_ready
);

// State
logic [2:0] state, next_state;

// Outputs
logic ld_cf, ld_smp, st_cv, sh, rs_rdy;

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
    3'b000: begin // Idle
      if (conv_en == 1'b1)
        next_state = 3'b001;
    end
    3'b001: begin // Coeff Load
      if (coeff_loaded == 1'b1)
        next_state = 3'b010;
    end
    3'b010: begin // Sample Load
      if (sample_loaded == 1'b1)
        next_state = 3'b011;
    end
    3'b011: begin // Convolve
      if (conv_complete == 1'b1)
        next_state = 3'b100;
    end
    3'b100: begin // Shift
      if (sample_complete == 1'b1)
        next_state = 3'b101;
      else if (sample_loaded == 1'b1)
        next_state = 3'b011;
    end
    3'b101: begin // Done
      next_state = 3'b000;
    end
  endcase
  
end

// Output logic
always_comb begin
  ld_cf = 1'b0; // default
  ld_smp = 1'b0; // default
  st_cv = 1'b0; // default
  sh = 1'b0; // default
  rs_rdy = 1'b0; // default

  case (state)
    3'b001: begin // Coeff Load
      ld_cf = 1'b1;
    end
    3'b010: begin // Sample Load
      ld_smp = 1'b1;
    end
    3'b011: begin // Convolve
      st_cv = 1'b1;
    end
    3'b100: begin // Shift
      sh = 1'b1;
    end
    3'b101: begin // Done
      rs_rdy = 1'b1;
    end
  endcase

end

assign load_coeff = ld_cf;
assign load_sample = ld_smp;
assign start_conv = st_cv;
assign shift = sh;
assign result_ready = rs_rdy;

endmodule

