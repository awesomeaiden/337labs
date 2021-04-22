// $Id: $
// File name:   coeff_reg.sv
// Created:     4/22/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Coefficient Register for AHB Convolver

module coeff_reg
(
  input wire clk,
  input wire n_rst,
  input wire coeff_ld,
  input wire [15:0] coeff_in,
  input wire [1:0] coeff_sel,
  output wire [35:0] coeff_out
);

// Registers
logic [15:0] coeff_0, coeff_1, coeff_2;

always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    coeff_0 <= 16'd0;
    coeff_1 <= 16'd0;
    coeff_2 <= 16'd0;
  end else begin
    if (coeff_ld == 1'b1) begin
      if (coeff_sel == 2'b00)
        coeff_0 <= coeff_in;
      else if (coeff_sel == 2'b01)
        coeff_1 <= coeff_in;
      else if (coeff_sel == 2'b10)
        coeff_2 <= coeff_in;
    end
  end
end

assign coeff_out = {coeff_2[11:0], coeff_1[11:0], coeff_0[11:0]};

endmodule
