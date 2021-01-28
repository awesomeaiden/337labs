// $Id: $
// File name:   sensor_d.sv
// Created:     1/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Dataflow Style Sensor Error Detector

module sensor_d (sensors, error);
  input [3:0] sensors;
  output error;

  wire or1out;
  wire or2out;
  wire and1out;

  assign or2out = sensors[2] | sensors[3];
  assign and1out = sensors[1] & or2out;
  assign or1out = sensors[0] | and1out;

  assign error = or1out;
endmodule
