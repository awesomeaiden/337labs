// $Id: $
// File name:   ahb_convolver.sv
// Created:     4/29/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: AHB Convolver

module ahb_convolver
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

  // Between AHB Slave and Controller
  wire modwait, sample_load_en, new_row, sample_stream, coeff_load_en;
  wire [1:0] coeff_sel;

  // Between AHB Slave and Sample Shift Register
  wire [15:0] col_out;

  // Between AHB Slave and Result FIFO
  wire read_enable, empty;
  wire [15:0] result_in;

  // Between AHB Slave and Coefficient Register
  wire [15:0] coeff_out;

  // Between Controller and Coefficient Register
  wire coeff_ld;

  // Between Controller and Multipliers/Adder Tree
  wire convolve_en;

  // Between Controller and Sample Shift Register
  wire sample_shift;

  // Between Sample Shift Register and Multipliers/Adder Tree
  wire [35:0] sample_out;

  // Between Coefficient Register and Multipliers/Adder Tree
  wire [35:0] coeff;

  // Between Multipliers/Adder Tree and Result FIFO
  wire [15:0] result;
  wire result_ready;

  // AHB Slave
  ahb_slave AHB (
    .clk(clk),
    .n_rst(n_rst),
    .hsel(hsel),
    .haddr(haddr),
    .htrans(htrans),
    .hsize(hsize),
    .hwrite(hwrite),
    .hwdata(hwdata),
    .modwait(modwait),
    .sample_stream(sample_stream),
    .coeff_sel(coeff_sel),
    .empty(empty),
    .result_in(result_in),
    .col_out(col_out),
    .sample_load_en(sample_load_en),
    .new_row(new_row),
    .coeff_load_en(coeff_load_en),
    .coeff_out(coeff_out),
    .read_enable(read_enable),
    .hrdata(hrdata),
    .hresp(hresp)
  );

  // Controller
  conv_controller CTRL (
    .clk(clk),
    .n_rst(n_rst),
    .sample_load_en(sample_load_en),
    .new_row(new_row),
    .coeff_load_en(coeff_load_en),
    .modwait(modwait),
    .sample_stream(sample_stream),
    .sample_shift(sample_shift),
    .convolve_en(convolve_en),
    .coeff_ld(coeff_ld),
    .coeff_sel(coeff_sel)
  );

  // Result FIFO
  res_fifo FIFO (
    .clk(clk),
    .n_rst(n_rst),
    .wenable(wenable),
    .renable(renable),
    .result_in(result),
    .empty(empty),
    .result_out(result_in)
  );

  // Coefficient Register
  coeff_reg COEFF (
    .clk(clk),
    .n_rst(n_rst),
    .coeff_ld(coeff_ld),
    .coeff_in(coeff_out),
    .coeff_sel(coeff_sel),
    .coeff_out(coeff)
  );

  // Sample Shift Register
  samp_shift_reg SAMP (
    
  );

  // Multipliers/Adder Tree
  mult_add MULTADD (
    .clk(clk),
    .n_rst(n_rst),
    .sample_in(sample_out),
    .coeff_in(coeff),
    .conv_en(convolve_en),
    .result(result),
    .result_ready(result_ready)
  );

endmodule
