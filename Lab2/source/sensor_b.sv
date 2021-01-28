// $Id: $
// File name:   sensor_b.sv
// Created:     1/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Behavioral Style Sensor Error Detector

module sensor_b (sensors, error);
  input [3:0] sensors;
  output reg error;

  reg or1out;
  reg or2out;
  reg and1out;

  always_comb begin
    if (sensors[2] | sensors[3]) begin
      or2out = 1'b1;
    end else begin
      or2out = 1'b0;
    end
    if (sensors[1] & or2out) begin
      and1out = 1'b1;
    end else begin
      and1out = 1'b0;
    end
    if (sensors[0] | and1out) begin
      or1out = 1'b1;
    end else begin
      or1out = 1'b0;
    end
    
    error = or1out;
  end

endmodule
