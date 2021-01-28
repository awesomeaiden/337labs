// $Id: $
// File name:   sensor_s.sv
// Created:     1/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Structural Style Sensor Error Detector

module sensor_s (sensors, error);
  input [3:0] sensors;
  output error;

  wire or1out;
  wire or2out;
  wire and1out;

  OR2X1 O2 (.Y(or2out), .A(sensors[2]), .B(sensors[3]));
  AND2X1 A1 (.Y(and1out), .A(sensors[1]), .B(or2out));  
  OR2X1 O1 (.Y(or1out), .A(sensors[0]), .B(and1out));

  assign error = or1out;
endmodule
