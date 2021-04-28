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
	input sample_load_en,
        input new_row,
        input coeff_load_en,
        output modwait,
        output sample_stream,
        output sample_shift,
        output convolve_en,
        output coeff_ld,
        output [1:0] coeff_sel
);

// State
logic [3:0] state, next_state;

// Outputs
logic mod, stream, shift, conv, load;
logic [1:0] sel;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
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
    4'b0000: begin // IDLE
      if (sample_load_en == 1'b1)
        next_state = 4'b0001;
    end
    4'b0001: begin // S0 LOAD
      next_state = 4'b0010;
    end
    4'b0010: begin // S1 WAIT
      if (sample_load_en == 1'b1)
        next_state = 4'b0011;
    end
    4'b0011: begin // S1 LOAD
      next_state = 4'b0100;
    end
    4'b0100: begin // S2 WAIT
      if (sample_load_en == 1'b1)
        next_state = 4'b0101;
    end
    4'b0101: begin // S2 LOAD
      next_state = 4'b0110;
    end
    4'b0110: begin // CONVOLVE
      if (new_row == 1'b1 && sample_load_en == 1'b1)
        next_state = 4'b0000;
      else if (coeff_load_en == 1'b1)
        next_state = 4'b1000;
      else if (new_row == 1'b1)
        next_state = 4'b0001;
      else if (sample_load_en == 1'b1)
        next_state = 4'b0111;
    end
    4'b0111: begin // SAMPLE STREAM
      next_state = 4'b0110;
    end
    4'b1000: begin // CF0 LOAD
      next_state = 4'b1001;
    end
    4'b1001: begin // CF1 LOAD
      next_state = 4'b1010;
    end
    4'b1010: begin // CF2 LOAD
      next_state = 4'b0000;
    end
		4'b1011: begin // CONVOLVE WAIT
		if (new_row == 1'b1 && sample_load_en == 1'b1)
			next_state = 4'b0000;
		else if (coeff_load_en == 1'b1)
			next_state = 4'b1000;
		else if (new_row == 1'b1)
			next_state = 4'b0001;
		else if (sample_load_en == 1'b1)
			next_state = 4'b0111;
		end
  endcase

end

// Output logic
always_comb begin
  mod = 1'b0; // default
  stream = 1'b0; // default
  shift = 1'b0; // default
  conv = 1'b0; // default
  load = 1'b0; // default
  sel = 2'b00; // default

  case (state)
    4'b0001: begin // S0 LOAD
      mod = 1'b1;
      shift = 1'b1;
    end
    4'b0011: begin // S1 LOAD
      mod = 1'b1;
      shift = 1'b1;
    end
    4'b0101: begin // S2 LOAD
      mod = 1'b1;
      shift = 1'b1;
    end
    4'b0110: begin // CONVOLVE
      conv = 1'b1;
      stream = 1'b1;
    end
    4'b0111: begin // SAMPLE STREAM
      mod = 1'b1;
      shift = 1'b1;
    end
    4'b1000: begin // CF0 LOAD
      mod = 1'b1;
      load = 1'b1;
      sel = 2'b00;
    end
    4'b1001: begin // CF1 LOAD
      mod = 1'b1;
      load = 1'b1;
      sel = 2'b01;
    end
    4'b1010: begin // CF2 LOAD
      mod = 1'b1;
      load = 1'b1;
      sel = 2'b10;
    end
		4'b1011: begin // CONVOLVE WAIT
		  stream = 1'b1;
		end
  endcase

end

assign modwait = mod;
assign sample_stream = stream;
assign sample_shift = shift;
assign convolve_en = conv;
assign coeff_ld = load;
assign coeff_sel = sel;

endmodule
