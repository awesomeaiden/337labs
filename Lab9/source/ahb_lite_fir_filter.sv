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
  input haddr,
	input hsize,
  input [1:0] htrans,
	input hwrite,
	input [15:0] hwdata
	output [15:0] hrdata,
  output hresp
);

  // From RCV Block to APB "Slave" Interface
  wire [7:0] rx_data;
  wire data_ready, overrun_error, framing_error;

  // From APB "Slave" Interface to RCV Block
  wire data_read;
  wire [3:0] data_size;
  wire [13:0] bit_period;

  // RCV Block
  rcv_block RCV (
    .clk(clk),
    .n_rst(n_rst),
    .data_size(data_size),
    .bit_period(bit_period),
    .serial_in(serial_in),
    .data_read(data_read),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error)
  );

  // APB "Slave" Interface
  apb_slave APB (
    .clk(clk),
    .n_rst(n_rst),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error),
    .psel(psel),
    .paddr(paddr),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pslverr(pslverr),
    .data_size(data_size),
    .bit_period(bit_period),
    .data_read(data_read)
  );

endmodule
