// $Id: $
// File name:   ahb_slave.sv
// Created:     4/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite Slave interface

module ahb_slave
(
  input clk,
  input n_rst,
  input hsel,
  input [3:0] haddr,
  input [1:0] htrans, // not used
  input hsize,
  input hwrite,
  input [15:0] hwdata,
  input modwait,
  input sample_stream,
  input [1:0] coeff_sel,
  input empty,
  input [15:0] result_in,
  output [15:0] col_out,
  output sample_load_en,
  output new_row,
  output coeff_load_en,
  output [15:0] coeff_out,
  output read_enable,
  output [15:0] hrdata,
  output hresp
);

// Registers
logic [7:0] array[12:0], next_array[12:0];
logic [15:0] outreg, next_outreg;
logic [15:0] coeff;
logic [3:0] addr, next_addr;
logic hsl, next_hsl;
logic hwrt, next_hwrt;
logic hsz, next_hsz;
logic hr;
logic read;

// Address register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    addr <= 4'b0000;
  end else begin
    addr <= next_addr;
  end
end

// Next address logic
always_comb begin
  next_addr = haddr;
end

// Hselect register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    hsl <= 1'b0;
  end else begin
    hsl <= next_hsl;
  end
end

// Next hselect logic
always_comb begin
  next_hsl = hsel;
end

// Hwrite register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    hwrt <= 1'b0;
  end else begin
    hwrt <= next_hwrt;
  end
end

// Next hwrt logic
always_comb begin
  next_hwrt = hwrite;
end

// Hsize register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    hsz <= 1'b0;
  end else begin
    hsz <= next_hsz;
  end
end

// Next hsz logic
always_comb begin
  next_hsz = hsize;
end

// Array
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    array[0] <= 8'b00000000;
    array[1] <= 8'b00000000;
    array[2] <= 8'b00000000;
    array[3] <= 8'b00000000;
    array[4] <= 8'b00000000;
    array[5] <= 8'b00000000;
    array[6] <= 8'b00000000;
    array[7] <= 8'b00000000;
    array[8] <= 8'b00000000;
    array[9] <= 8'b00000000;
    array[10] <= 8'b00000000;
    array[11] <= 8'b00000000;
    array[12] <= 8'b00000000;
  end else begin
    array <= next_array;
  end
end

// Outreg
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    outreg <= 16'b0000000000000000;
  end else begin
    outreg <= next_outreg;
  end
end

// Status Register (0x0)
always_comb begin
  next_array[0] = 8'b00000000; // Default
  next_array[1] = 8'b00000000; // Default

  // If convolver is busy
  if (modwait == 1'b1) begin
    next_array[0][0] = 1'b1;
  end

  // If FIFO register empty
  if (empty == 1'b1) begin
    next_array[0][7] = 1'b1;
  end

  // If streaming mode active
  if (sample_stream == 1'b1) begin
    next_array[1][0] = 8'b1;
  end
end

// FIFO Result Register (0x2)
always_comb begin
  next_array[2] = result_in[7:0];
  next_array[3] = result_in[15:8];
end

// New Sample Column Register (0x4)
always_comb begin
  next_array[4] = array[4]; // Default
  next_array[5] = array[5]; // Default

  // Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b0100 || addr == 4'b0101) && hwrt == 1'b1 && hsz == 1'b1) begin
    next_array[4] = hwdata[7:0];
    next_array[5] = hwdata[15:8];
  // Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b0100 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[4] = hwdata[7:0];
  // Upper byte write
  end else if (hsl == 1'b1 && addr == 4'b0101 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[5] = hwdata[15:8];
  end
end

// R0 Coefficient Column Register (0x6)
always_comb begin
  next_array[6] = array[6]; // Default
  next_array[7] = array[7]; // Default

  // Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b0110 || addr == 4'b0111) && hwrt == 1'b1 && hsz == 1'b1) begin
    next_array[6] = hwdata[7:0];
    next_array[7] = hwdata[15:8];
  // Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b0110 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[6] = hwdata[7:0];
  // Upper byte write
  end else if (hsl == 1'b1 && addr == 4'b0111 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[7] = hwdata[15:8];
  end
end

// R1 Coefficient Register (0x8)
always_comb begin
  next_array[8] = array[8]; // Default
  next_array[9] = array[9]; // Default

  // Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b1000 || addr == 4'b1001) && hwrt == 1'b1 && hsz == 1'b1) begin
    next_array[8] = hwdata[7:0];
    next_array[9] = hwdata[15:8];
  // Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b1000 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[8] = hwdata[7:0];
  // Upper byte write
  end else if (hsl == 1'b1 && addr == 4'b1001 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[9] = hwdata[15:8];
  end
end

// R2 Coefficient Register (0xA)
always_comb begin
  next_array[10] = array[10]; // Default
  next_array[11] = array[11]; // Default

  // Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b1010 || addr == 4'b1011) && hwrt == 1'b1 && hsz == 1'b1) begin
    next_array[10] = hwdata[7:0];
    next_array[11] = hwdata[15:8];
  // Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b1010 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[10] = hwdata[7:0];
  // Upper byte write
  end else if (hsl == 1'b1 && addr == 4'b1011 && hwrt == 1'b1 && hsz == 1'b0) begin
    next_array[11] = hwdata[15:8];
  end
end

// Command / Control Register(0xC)
always_comb begin
  next_array[12] = array[12]; // Default

  // Writing to register (hsize irrelevant as long as address is 0xC)
  if (hsl == 1'b1 && addr == 4'b1100 && hwrt == 1'b1) begin
    next_array[12] = hwdata[7:0];
  end

  // Coeff_load_en should be de-asserted after one clock period
  if (array[12][0] == 1'b1)
    next_array[12][0] = 1'b0;

  // Sample done should be de-asserted after one clock period
  if (array[12][1] == 1'b1 && array[12][2] == 1'b1) begin
    next_array[12][1] = 1'b0;
    next_array[12][2] = 1'b0;
  end else begin
    // Sample_load_en should be de-asserted after one clock period
    if (array[12][1] == 1'b1)
      next_array[12][1] = 1'b0;

    // New_row should be de-asserted after one clock period
    if (array[12][2] == 1'b1)
      next_array[12][2] = 1'b0;
  end
end

// Outreg, read, and hresp
always_comb begin
  next_outreg = outreg; // Default
  hr = 1'b0; // default
  read = 1'b0; // default

  // RAW Hazard handling:
  if (next_hwrt == 1'b0 && hwrt == 1'b1 && addr == next_addr && hsl == next_hsl && hsz == next_hsz && haddr >= 4'b0100 && haddr <= 4'b1100) begin
    next_outreg = hwdata;
  end else if (hsel == 1'b1 && hwrite == 1'b0) begin
    if (haddr == 4'b0000) // Read status register
      next_outreg = {next_array[1], next_array[0]}; // "next" to accelerate reading
    else if (haddr == 4'b0010) begin // Read FIFO result register
      read = 1'b1;
      next_outreg = {next_array[3], next_array[2]}; // "next" to accelerate reading
    end else if (haddr == 4'b0100) // Read new sample column register
      next_outreg = {array[5], array[4]};
    else if (haddr == 4'b0110) // Read r0 coefficient column register
      next_outreg = {array[7], array[6]};
    else if (haddr == 4'b1000) // Read r1 coefficient column register
      next_outreg = {array[9], array[8]};
    else if (haddr == 4'b1010) // Read r2 coefficient column register
      next_outreg = {array[11], array[10]};
    else if (haddr == 4'b1100) // Read command/control register
      next_outreg = {8'b00000000, array[12]};
    else
      hr = 1'b1; // invalid address
  end else if (hsel == 1'b1 && hwrite == 1'b1) begin
    if (haddr < 4'b0100 || haddr > 4'b1100)
      hr = 1'b1; // invalid write address
  end
end

// Coefficient output
always_comb begin
  coeff = {array[7+ (2 * coeff_sel)], array[6 + (2 * coeff_sel)]};
end

// Outputs
assign hrdata = outreg;
assign col_out = {array[5], array[4]};
assign coeff_out = coeff;
assign sample_load_en = array[12][1];
assign new_row = array[12][2];
assign coeff_load_en = array[12][0];
assign hresp = hr;
assign read_enable = read;

endmodule 
