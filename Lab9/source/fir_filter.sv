// $Id: $
// File name:   fir_filter.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: FIR filter

module fir_filter
(
  input clk,
  input n_reset,
  input [15:0] sample_data,
  input [15:0] fir_coefficient,
  input load_coeff,
  input data_ready,
  output one_k_samples,
  output modwait,
  output [15:0] fir_out,
  output err
);

  // Between controller and datapath
  wire overflow;
  wire [2:0] op;
  wire [3:0] src1, src2, dest;
  // Between controller and counter
  wire cnt_up, clear;
  // Between datapath and magnitude
  wire [16:0] outreg_data;

  // Removed synchronizers for new design

  controller CNTRLR (
    .clk(clk),
    .n_rst(n_reset),
    .dr(data_ready),
    .lc(load_coeff),
    .overflow(overflow),
    .cnt_up(cnt_up),
    .clear(clear),
    .modwait(modwait),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .err(err)
  );

  counter CNTR (
    .clk(clk),
    .n_rst(n_reset),
    .cnt_up(cnt_up),
    .clear(clear),
    .one_k_samples(one_k_samples)
  );

  datapath DATA (
    .clk(clk),
    .n_reset(n_reset),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .ext_data1(sample_data),
    .ext_data2(fir_coefficient),
    .outreg_data(outreg_data),
    .overflow(overflow)
  );

  magnitude MAG (
    .in(outreg_data),
    .out(fir_out)
  );
  
endmodule
