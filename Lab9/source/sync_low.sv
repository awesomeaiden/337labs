// $Id: $
// File name:   sync_low.sv
// Created:     2/11/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Reset to Logic Low Synchronizer

module sync_low (clk, n_rst, async_in, sync_out);
  input clk, n_rst, async_in;
  output sync_out;

  reg Q1, Q2;
  assign sync_out = Q2;

  always_ff @ (posedge clk, negedge n_rst)
  begin: FF1
    if (1'b0 == n_rst) begin
      Q1 <= 1'b0;
    end
    else begin
      Q1 <= async_in;
    end
  end

  always_ff @ (posedge clk, negedge n_rst)
  begin: FF2
    if (1'b0 == n_rst) begin
      Q2 <= 1'b0;
    end
    else begin
      Q2 <= Q1;
    end
  end
endmodule
