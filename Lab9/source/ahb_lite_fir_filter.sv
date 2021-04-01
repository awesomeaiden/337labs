// $Id: $
// File name:   ahb_lite_fir_filter.sv
// Created:     3/31/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: AHB Lite Fir Filter

module ahb_lite_fir_filter
(
	input clk,
	input n_rst,
  input hsel,
  input [3:0] haddr,
	input hsize,
  input [1:0] htrans,
	input hwrite,
	input [15:0] hwdata,
	output [15:0] hrdata,
  output hresp
);

  // Between Coefficient Loader and AHB-Lite Slave
  wire [1:0] coefficient_num;
  wire clear_new_coeff, new_coefficient_set;

  // Between FIR Filter and AHB-Lite Slave
  wire modwait, err, data_ready;
  wire [15:0] fir_out, sample_data, fir_coefficient;

  // Between Coefficient Loader and FIR Filter
  wire load_coeff;

  // AHB-Lite Slave
  ahb_lite_slave AHB (
    .clk(clk),
    .n_rst(n_rst),
    .coefficient_num(coefficient_num),
    .modwait(modwait),
    .fir_out(fir_out),
    .err(err),
    .hsel(hsel),
    .haddr(haddr),
    .hsize(hsize),
    .htrans(htrans),
    .hwrite(hwrite),
    .hwdata(hwdata),
    .clear_new_coeff(clear_new_coeff),
    .sample_data(sample_data),
    .data_ready(data_ready),
    .new_coefficient_set(new_coefficient_set),
    .fir_coefficient(fir_coefficient),
    .hrdata(hrdata),
    .hresp(hresp)
  );

  // Coefficient Loader
  coefficient_loader LDR (
    .clk(clk),
    .n_reset(n_rst),
    .new_coefficient_set(new_coefficient_set),
    .modwait(modwait),
    .load_coeff(load_coeff),
    .clear_new_coeff(clear_new_coeff),
    .coefficient_num(coefficient_num)
  );

  // FIR Filter
  fir_filter FIR (
    .clk(clk),
    .n_reset(n_rst),
    .sample_data(sample_data),
    .fir_coefficient(fir_coefficient),
    .load_coeff(load_coeff),
    .data_ready(data_ready),
    .modwait(modwait),
    .fir_out(fir_out),
    .err(err)
  );

endmodule
