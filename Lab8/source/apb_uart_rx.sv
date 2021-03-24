// $Id: $
// File name:   apb_uart_rx.sv
// Created:     3/23/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: APB UART Block

module apb_uart_rx
(
	input clk,
	input n_rst,
        input serial_in,
        input psel,
	input [2:0] paddr,
	input penable,
	input pwrite,
        input [7:0] pwdata,
	output [7:0] prdata,
        output pslverr
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

