// $Id: $
// File name:   ahb_lite_slave.sv
// Created:     3/31/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite Slave interface

module ahb_lite_slave
(
	input clk,
	input n_rst,
	input [1:0] coefficient_num,
	input modwait,
	input [15:0] fir_out,
	input err,
  input hsel,
  input [3:0] haddr,
  input hsize,
  input [1:0] htrans, // unused
  input hwrite,
  input [15:0] hwdata,
	input clear_new_coeff,
  output [15:0] sample_data,
  output data_ready,
  output new_coefficient_set,
  output [15:0] fir_coefficient,
	output [15:0] hrdata,
	output hresp
);

// Registers
logic [7:0] array[14:0], next_array[14:0];
logic [15:0] outreg, next_outreg;
logic [15:0] fr_cf;
logic [3:0] addr, next_addr;
logic hsl, next_hsl;
logic hwrt, next_hwrt;
logic hsz, next_hsz;
logic d_r, next_d_r, dr_hold;
logic hr;

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

// Data ready register
always_ff @(posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
	  d_r <= 1'b0;
		dr_hold <= 1'b0;
	end else begin
	  if (dr_hold == 1'b1) begin
		  dr_hold <= 1'b0;
		end else if (d_r == 1'b0 && next_d_r == 1'b1) begin
		  dr_hold <= 1'b1;
			d_r <= next_d_r;
		end else begin
		  d_r <= next_d_r;
		end
	end
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
    array[13] <= 8'b00000000;
    array[14] <= 8'b00000000;
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

  // If filter busy or coefficient loading in process
	if (modwait == 1'b1 || array[14] == 8'b00000001) begin
	  next_array[0] = 8'b00000001;
	end

	if (err == 1'b1) begin
    next_array[1] = 8'b00000001;
  end
end

// Result Register (0x2)
always_comb begin
  next_array[2] = fir_out[7:0];
  next_array[3] = fir_out[15:8];
end

// New Sample Register (0x4)
// Also contains next_d_r logic
always_comb begin
  next_array[4] = array[4]; // Default
	next_array[5] = array[5]; // Default
	next_d_r = 1'b0; // Default

	// Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b0100 || addr == 4'b0101) && hwrt == 1'b1 && hsz == 1'b1) begin
	  next_array[4] = hwdata[7:0];
	  next_array[5] = hwdata[15:8];
		next_d_r = 1'b1; // New sample available
	// Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b0100 && hwrt == 1'b1 && hsz == 1'b0) begin
	  next_array[4] = hwdata[7:0];
		next_d_r = 1'b1; // New sample available
	// Upper byte write
	end else if (hsl == 1'b1 && addr == 4'b0101 && hwrt == 1'b1 && hsz == 1'b0) begin
	  next_array[5] = hwdata[15:8];
		next_d_r = 1'b1; // New sample available
	end
end

// F0 Coefficient Register (0x6)
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

// F1 Coefficient Register (0x8)
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

// F2 Coefficient Register (0xA)
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

// F3 Coefficient Register (0xC)
always_comb begin
  next_array[12] = array[12]; // Default
  next_array[13] = array[13]; // Default

	// Two-byte sample write
  if (hsl == 1'b1 && (addr == 4'b1100 || addr == 4'b1101) && hwrt == 1'b1 && hsz == 1'b1) begin
	  next_array[12] = hwdata[7:0];
	  next_array[13] = hwdata[15:8];
	// Lower byte write
  end else if (hsl == 1'b1 && addr == 4'b1100 && hwrt == 1'b1 && hsz == 1'b0) begin
	  next_array[12] = hwdata[7:0];
	// Upper byte write
	end else if (hsl == 1'b1 && addr == 4'b1101 && hwrt == 1'b1 && hsz == 1'b0) begin
	  next_array[13] = hwdata[15:8];
	end
end

// Coefficient Set Confirmation Register (0xE)
always_comb begin
  next_array[14] = array[14]; // Default

  // Writing to register (hsize irrelevant as long as address is 0xE)
	if (hsl == 1'b1 && addr == 4'b1110 && hwrt == 1'b1) begin
    next_array[14] = hwdata[7:0];
  end

   // Coefficient loading complete (overrides write)
  if (clear_new_coeff == 1'b1) begin
    next_array[14] = 8'b00000000;
  end
end

// Outreg
always_comb begin
  next_outreg = outreg; // Default
	hr = 1'b0; // Default

	// RAW Hazard handling:
	if (next_hwrt == 1'b0 && hwrt == 1'b1 && addr == next_addr && hsl == next_hsl && hsz == next_hsz) begin
	  next_outreg = hwdata;
	end else if (hsel == 1'b1 && hwrite == 1'b0) begin
	  if (haddr == 4'b0000) // Read status register
		  next_outreg = {next_array[1], next_array[0]}; // "next" to accelerate reading
	  else if (haddr == 4'b0010) // Read result register
		  next_outreg = {array[3], array[2]};
	  else if (haddr == 4'b0100) // Read new sample register
		  next_outreg = {array[5], array[4]};
	  else if (haddr == 4'b0110) // Read f0 coefficient register
		  next_outreg = {array[7], array[6]};
	  else if (haddr == 4'b1000) // Read f1 coefficient register
		  next_outreg = {array[9], array[8]};
	  else if (haddr == 4'b1010) // Read f2 coefficient register
		  next_outreg = {array[11], array[10]};
	  else if (haddr == 4'b1100) // Read f3 coefficient register
		  next_outreg = {array[13], array[12]};
	  else if (haddr == 4'b1110) // Read coefficient set confirmation register
		  next_outreg = {8'b00000000, array[14]};
	  else
		  hr = 1'b1; // invalid address
  end else if (hsel == 1'b1 && hwrite == 1'b1) begin
	  if (haddr < 4 || haddr > 14) begin
		  hr = 1'b1; // invalid write address
		end
	end
end

// Fir coefficient output
always_comb begin
  fr_cf = {array[7 + (2 * coefficient_num)], array[6 + (2 * coefficient_num)]};
end

// Outputs
assign hrdata = outreg;
assign sample_data = {array[5], array[4]};
assign fir_coefficient = fr_cf;
assign data_ready = d_r;
assign new_coefficient_set = array[14];
assign hresp = hr;

endmodule
