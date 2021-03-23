// $Id: $
// File name:   apb_slave.sv
// Created:     3/21/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: APB Slave interface

module apb_slave
(
	input clk,
	input n_rst,
	input [7:0] rx_data,
	input data_ready,
	input overrun_error,
        input framing_error,
        output data_read,
        input psel,
        input [2:0] paddr,
        input penable,
        input pwrite,
        input [7:0] pwdata,
        output [7:0] prdata,
        output pslverr,
        output [3:0] data_size,
        output [13:0] bit_period
);

// Registers
logic [7:0] array[4:0], next_array[4:0];
logic [7:0] outreg, next_outreg;
logic d_read, next_d_read, slv_err;

// Array
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    array[0] <= 8'b00000000;
    array[1] <= 8'b00000000;
    array[2] <= 8'b00001010;
    array[3] <= 8'b00000000;
    array[4] <= 8'b00001000;
  end else begin
    array <= next_array;
  end
end

// Outreg and d_read
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    outreg <= 0;
    d_read <= 0;
  end else begin
    outreg <= next_outreg;
    d_read <= next_d_read;
  end
end

// Data Status Register
always_comb begin
  next_array[0] = {7'b0000000, data_ready}; // fill excess with 0s
end

// Error Status Register
always_comb begin
  if (overrun_error == 1'b0 && framing_error == 1'b0)
    next_array[1] = {6'b000000, 2'b00}; // fill excess with 0s
  else if (framing_error == 1'b1)
    next_array[1] = {6'b000000, 2'b01}; // fill excess with 0s
  else
    next_array[1] = {6'b000000, 2'b10}; // fill excess with 0s
end

// Bit period [7:0] configuration register
always_comb begin
  next_array[2] = array[2]; // Default
  if (psel == 1'b1 && pwrite == 1'b1 && paddr == 3'b010)
    next_array[2] = pwdata;
end

// Bit period [13:8] configuration register
always_comb begin
  next_array[3] = array[3]; // Default
  if (psel == 1'b1 && pwrite == 1'b1 && paddr == 3'b011)
    next_array[3] = {2'b00, pwdata[5:0]}; // fill excess with 0s
end

// Data Size [3:0] configuration register
always_comb begin
  next_array[4] = array[4]; // Default
  if (psel == 1'b1 && pwrite == 1'b1 && paddr == 3'b100)
    next_array[4] = {4'b0000, pwdata[3:0]}; // fill excess with 0s
end

// Outreg, data_read, and pslverr
always_comb begin
  next_d_read = 1'b0; // Default
  slv_err = 1'b0; // Default
  next_outreg = outreg; // Default
  if (psel == 1'b1 && pwrite == 1'b0) begin
    if (paddr == 3'b000) begin
      next_outreg = array[0];
    end else if (paddr == 3'b001) begin
      next_outreg = array[1];
    end else if (paddr == 3'b010) begin
      next_outreg = array[2];
    end else if (paddr == 3'b011) begin
      next_outreg = array[3];
    end else if (paddr == 3'b100) begin
      next_outreg = array[4];
    end else if (paddr == 3'b110) begin
      next_outreg = rx_data;
      next_d_read = 1'b1; // indicate data has been read
    end else begin
      slv_err = 1'b1; // invalid address
    end
  end

  if (psel == 1'b1 && pwrite == 1'b1 && paddr != 3'b010 && paddr != 3'b011 && paddr != 3'b100) begin
    slv_err = 1'b1; // invalid write address
  end
end

// Outputs
assign prdata = outreg;
assign data_size = array[4];
assign bit_period[7:0] = array[2];
assign bit_period[13:8] = array[3];
assign data_read = d_read;
assign pslverr = slv_err;

endmodule

