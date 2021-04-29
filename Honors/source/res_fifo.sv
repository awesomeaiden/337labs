// $Id: $
// File name:   res_fifo.sv
// Created:     4/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Result FIFO Register for AHB Convolver

module res_fifo
#(parameter NUM_BYTES = 1352)
(
  input wire clk,
  input wire n_rst,
  input wire wenable,
  input wire renable,
  input wire [15:0] result_in,
  output wire empty,
  output wire [15:0] result_out
);

// Registers
logic [15:0] waddr, next_waddr, raddr, next_raddr, count, next_count;
logic [15:0] ram[(NUM_BYTES - 1):0], next_ram[(NUM_BYTES - 1):0];
logic [15:0] result, next_result;

// Connectors
logic emp, ful;

// Registers
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    waddr <= 16'd0;
    raddr <= 16'd0;
    count <= 16'd0;
    result <= 16'd0;
    ram[0] <= 16'd0;
  end else begin
    waddr <= next_waddr;
    raddr <= next_raddr;
    count <= next_count;
    result <= next_result;
    ram <= next_ram;
  end
end

// Write logic
always_comb begin 
  next_ram = ram; // default

  if (wenable == 1'b1 && ful == 1'b0)
    next_ram[waddr] = result_in;
end

// Read logic
always_comb begin
  next_result = result; // default

  if (renable == 1'b1 && emp == 1'b0)
    next_result = ram[raddr];
end

// Next waddr, raddr, and count logic
always_comb begin
  next_waddr = waddr; // default
  next_raddr = raddr; // default
  next_count = count; // default

  if (wenable == 1'b1 && ful == 1'b0) begin
    next_waddr = (waddr + 1) % NUM_BYTES;
    next_count = count + 1;
  end

  if (renable == 1'b1 && emp == 1'b0) begin
    next_raddr = (raddr + 1) % NUM_BYTES;
    next_count = count - 1;
  end

end

// Empty and Full output logic
always_comb begin
  emp = 1'b0; // default
  ful = 1'b0; // default

  if (count == 16'd0)
    emp = 1'b1;
  else if (count == NUM_BYTES)
    ful = 1'b1;
end

// Assign statements
assign empty = emp;
assign result_out = result;

endmodule
