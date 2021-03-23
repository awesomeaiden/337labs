// $Id: $
// File name:   rcv_block.sv
// Created:     3/23/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: RCV Block (Extended)

module rcv_block
(
	input clk,
	input n_rst,
        input [3:0] data_size,
        input [13:0] bit_period,
	input serial_in,
	input data_read,
	output [7:0] rx_data,
        output data_ready,
	output overrun_error,
        output framing_error
);

  wire shift_str, tim_en, start, stop, packet_end, frame_err;
  wire sbc_clr, sbc_en, ld_buff;
  wire [7:0] packet;

  // 9-bit Shift Register
  sr_9bit SHIFTR (
    .clk(clk),
    .n_rst(n_rst),
    .shift_strobe(shift_str),
    .serial_in(serial_in),
    .packet_data(packet),
    .stop_bit(stop)
  );

  // Start-Bit Detector
  start_bit_det STRTDET (
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(serial_in),
    .start_bit_detected(start)
  );

  // Timing Controller
  timer TIMCON (
    .clk(clk),
    .n_rst(n_rst),
    .enable_timer(tim_en),
    .bit_period(bit_period),
    .data_size(data_size),
    .shift_enable(shift_str),
    .packet_done(packet_end)
  );

  // Receiver Control Unit (RCU)
  rcu RECVCON (
    .clk(clk),
    .n_rst(n_rst),
    .start_bit_detected(start),
    .packet_done(packet_end),
    .framing_error(frame_err),
    .sbc_clear(sbc_clr),
    .sbc_enable(sbc_en),
    .load_buffer(ld_buff),
    .enable_timer(tim_en)
  );

  // Stop-Bit Checker
  stop_bit_chk STOPCHK (
    .clk(clk),
    .n_rst(n_rst),
    .sbc_clear(sbc_clr),
    .sbc_enable(sbc_en),
    .stop_bit(stop),
    .framing_error(frame_err)
  );

  // RX Data Buffer
  rx_data_buff RXBUFF (
    .clk(clk),
    .n_rst(n_rst),
    .load_buffer(ld_buff),
    .packet_data(packet),
    .data_read(data_read),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error)
  );

assign framing_error = frame_err;
  
endmodule

