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

assign result_ready = conv_en;

endmodule
