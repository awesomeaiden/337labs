// $Id: $
// File name:   controller.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Controller

module controller
(
	input clk,
	input n_rst,
	input dr,
	input lc,
	input overflow,
	output cnt_up,
        output clear,
	output modwait,
        output [2:0] op,
        output [3:0] src1,
        output [3:0] src2,
        output [3:0] dest,
        output err,
        output [4:0] state_out
);

logic [4:0] state, next_state;
logic up, clr, wt, error;
logic next_wt, next_error; // for registered outputs
logic [2:0] oper;
logic [3:0] s1, s2, dst;

// State register
always_ff @ (posedge clk, negedge n_rst)
  begin
    if (n_rst == 0) begin
      state <= 5'b00000;
      wt <= 1'b0;
      error <= 1'b0;
    end
    else begin
      state <= next_state;
      wt <= next_wt;
      error <= next_error;
     end
  end

// Next state logic
// Also where next_wt and next_error are determined
always_comb begin
  next_state = state; // default
  next_wt = 1'b0; // default
  next_error = 1'b0; // default

  case (state)
    5'b00000: begin // Idle
      if (lc == 1'b1) begin
        next_state = 5'b10000;
        next_wt = 1'b1;
      end else if (dr == 1'b1) begin
        next_state = 5'b00001;
        next_wt = 1'b1;
      end
    end
    5'b00001: begin // Store
      if (dr == 1'b0) begin
        next_state = 5'b10111; // Go to error idle
        next_error = 1'b1;
      end else begin
        next_state = 5'b00010;
        next_wt = 1'b1;
      end
    end
    5'b00010: begin // Zero accumulator
      next_state = 5'b00011;
      next_wt = 1'b1;
    end
    5'b00011: begin // Sort 1
      next_state = 5'b00100;
      next_wt = 1'b1;
    end
    5'b00100: begin // Sort 2
      next_state = 5'b00101;
      next_wt = 1'b1;
    end
    5'b00101: begin // Sort 3
      next_state = 5'b00110;
      next_wt = 1'b1;
    end
    5'b00110: begin // Sort 4
      next_state = 5'b00111;
      next_wt = 1'b1;
    end
    5'b00111: begin // Mul 1
      next_state = 5'b01000;
      next_wt = 1'b1;
    end
    5'b01000: begin // Add 1
      if (overflow == 1'b1) begin
        next_state = 5'b10111; // Go to error idle
        next_error = 1'b1;
      end else begin
        next_state = 5'b01001;
        next_wt = 1'b1;
      end
    end
    5'b01001: begin // Mul 2
      next_state = 5'b01010;
      next_wt = 1'b1;
    end
    5'b01010: begin // Sub 1
      if (overflow == 1'b1) begin
        next_state = 5'b10111; // Go to error idle
        next_error = 1'b1;
      end else begin
        next_state = 5'b01011;
        next_wt = 1'b1;
      end
    end
    5'b01011: begin // Mul 3
      next_state = 5'b01100;
      next_wt = 1'b1;
    end
    5'b01100: begin // Add 2
      if (overflow == 1'b1) begin
        next_state = 5'b10111; // Go to error idle
        next_error = 1'b1;
      end else begin
        next_state = 5'b01101;
        next_wt = 1'b1;
      end
    end
    5'b01101: begin // Mul 4
      next_state = 5'b01110;
      next_wt = 1'b1;
    end
    5'b01110: begin // Sub 2
      if (overflow == 1'b1) begin
        next_state = 5'b10111; // Go to error idle
        next_error = 1'b1;
      end else begin
        next_state = 5'b01111;
      end
    end
    5'b01111: begin // Complete
      next_state = 5'b00000;
    end
    5'b10000: begin // Load F0
      next_state = 5'b10001;
    end
    5'b10001: begin // Wait 1
      if (lc == 1'b1) begin
        next_state = 5'b10010;
        next_wt = 1'b1;
      end
    end
    5'b10010: begin // Load F1
      next_state = 5'b10011;
    end
    5'b10011: begin // Wait 2
      if (lc == 1'b1) begin
        next_state = 5'b10100;
        next_wt = 1'b1;
      end
    end
    5'b10100: begin // Load F2
      next_state = 5'b10101;
    end
    5'b10101: begin // Wait 3
      if (lc == 1'b1) begin
        next_state = 5'b10110;
        next_wt = 1'b1;
      end
    end
    5'b10110: begin // Load F3
      next_state = 5'b00000;
    end
    5'b10111: begin // Error Idle
      if (dr == 1'b1) begin
        next_state = 5'b00001;
        next_wt = 1'b1;
      end else begin
        next_error = 1'b1;
      end
    end
  endcase  
end

// Output logic
always_comb begin
  up = 1'b0; // default
  clr = 1'b0; // default
  oper = 3'b000; // default
  s1 = 4'b0000; // default
  s2 = 4'b0000; // default
  dst = 4'b0000; // default

  case (state)
    5'b00000: begin // Idle

    end
    5'b00001: begin // Store
      oper = 3'b010;
      dst = 4'b0101;
    end
    5'b00010: begin // Zero accumulator
      up = 1'b1;
      oper = 3'b101;
      s1 = 4'b0000;
      s2 = 4'b0000;
      dst = 4'b0000;
    end
    5'b00011: begin // Sort 1
      oper = 3'b001;
      s1 = 4'b0010;
      dst = 4'b0001;
    end
    5'b00100: begin // Sort 2
      oper = 3'b001;
      s1 = 4'b0011;
      dst = 4'b0010;
    end
    5'b00101: begin // Sort 3
      oper = 3'b001;
      s1 = 4'b0100;
      dst = 4'b0011;
    end
    5'b00110: begin // Sort 4
      oper = 3'b001;
      s1 = 4'b0101;
      dst = 4'b0100;
    end
    5'b00111: begin // Mul 1
      oper = 3'b110;
      s1 = 4'b0001;
      s2 = 4'b0110;
      dst = 4'b1010;
    end
    5'b01000: begin // Add 1
      oper = 3'b100;
      s1 = 4'b0000;
      s2 = 4'b1010;
      dst = 4'b0000;
    end
    5'b01001: begin // Mul 2
      oper = 3'b110;
      s1 = 4'b0010;
      s2 = 4'b0111;
      dst = 4'b1010;
    end
    5'b01010: begin // Sub 1
      oper = 3'b101;
      s1 = 4'b0000;
      s2 = 4'b1010;
      dst = 4'b0000;
    end
    5'b01011: begin // Mul 3
      oper = 3'b110;
      s1 = 4'b0011;
      s2 = 4'b1000;
      dst = 4'b1010;
    end
    5'b01100: begin // Add 2
      oper = 3'b100;
      s1 = 4'b0000;
      s2 = 4'b1010;
      dst = 4'b0000;
    end
    5'b01101: begin // Mul 4
      oper = 3'b110;
      s1 = 4'b0100;
      s2 = 4'b1001;
      dst = 4'b1010;
    end
    5'b01110: begin // Sub 2
      oper = 3'b101;
      s1 = 4'b0000;
      s2 = 4'b1010;
      dst = 4'b0000;
    end
    5'b01111: begin // Complete
      
    end
    5'b10000: begin // Load F0
      clr = 1'b1;
      oper = 3'b011;
      dst = 4'b1001;
    end
    5'b10001: begin // Wait 1
      
    end
    5'b10010: begin // Load F1
      oper = 3'b011;
      dst = 4'b1000;
    end
    5'b10011: begin // Wait 2
      
    end
    5'b10100: begin // Load F2
      oper = 3'b011;
      dst = 4'b0111;
    end
    5'b10101: begin // Wait 3
      
    end
    5'b10110: begin // Load F3
      oper = 3'b011;
      dst = 4'b0110;
    end
    5'b10111: begin // Error Idle
    end
  endcase
end

// Connect outputs
assign cnt_up = up;
assign clear = clr;
assign modwait = wt;
assign err = error;
assign op = oper;
assign src1 = s1;
assign src2 = s2;
assign dest = dst;
assign state_out = state; // for debugging

endmodule

