// $Id: $
// File name:   mult_add.sv
// Created:     4/22/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Multiplier/Adder Block for AHB Convolver

module mult_add
(
  input wire clk,
  input wire n_rst,
  input wire [35:0] sample_in,
  input wire [35:0] coeff_in,
  input wire conv_en,
  output wire [15:0] result,
  output wire result_ready
);

// Result Ready
logic res_rdy;
logic state, next_state;

// Multipliers / Adders
assign result = (sample_in[3:0] * coeff_in[3:0]) 
              + (sample_in[7:4] * coeff_in[7:4])
              + (sample_in[11:8] * coeff_in[11:8])
              + (sample_in[15:12] * coeff_in[15:12])
              + (sample_in[19:16] * coeff_in[19:16])
              + (sample_in[23:20] * coeff_in[23:20])
              + (sample_in[27:24] * coeff_in[27:24])
              + (sample_in[31:28] * coeff_in[31:28])
              + (sample_in[35:32] * coeff_in[35:32]);

// State register
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    state <= 1'b0;
  end else begin
    state <= next_state;
  end
end

// Next state logic
always_comb begin
  next_state = state; // default

  case (state)
    1'b0: begin // idle
      if (conv_en == 1'b1) begin
        next_state = 1'b1;
      end
    end
    1'b1: begin // result
      next_state = 1'b0;
    end
  endcase
end

// Output logic
always_comb begin
  res_rdy = 1'b0; // default

  if (state == 1'b1) begin
    res_rdy = 1'b1;
  end
end

assign result_ready = res_rdy;

endmodule
