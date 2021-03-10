// $Id: $
// File name:   tb_magnitude.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Magnitude testbench

`timescale 1ns / 10ps

module tb_magnitude();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  NUM_IN_BITS = 4;
  
  // Declare DUT portmap signals
  reg tb_clk;
  reg [16:0] tb_in;
  reg [15:0] tb_out;
  
  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  // Task to cleanly and consistently check DUT rollover_flag
  task check_out;
    input logic  [15:0] expected_out;
    input string check_tag;
  begin
    if(expected_out == tb_out) begin // Check passed
      $info("Correct output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask


  // Clock generation block
  always
  begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end
  
  // DUT Port map
  magnitude DUT(
    .in(tb_in), .out(tb_out));
  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_in = 17'b00000000000000000;
    tb_test_num = 0;               // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    // Wait some time before starting first test case
    #(0.1);
    
    // ************************************************************************
    // Test Case 1: Zeros
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Zeros";
    tb_in = 17'b00000000000000000;

    @(posedge tb_clk);
    @(negedge tb_clk);

    // Check that output is correct
    check_out(16'b0000000000000000, "after zeros inputted");

    // ************************************************************************
    // Test Case 2: Small positive number
    // ************************************************************************    
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Small positive number";

    // Assign test case stimulus
    tb_in = 17'b00000000010111101;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_out(16'b0000000010111101, "for small positive number");

    // ************************************************************************
    // Test Case 3: Large positive number
    // ************************************************************************    
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Large positive number";

    // Assign test case stimulus
    tb_in = 17'b01001011110111101;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_out(16'b1001011110111101, "for large positive number");

    // ************************************************************************
    // Test Case 4: Small negative number
    // ************************************************************************    
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Small negative number";

    // Assign test case stimulus
    tb_in = 17'b11111111111111111;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_out(16'b0000000000000001, "for small negative number");

    // ************************************************************************
    // Test Case 5: Large negative number
    // ************************************************************************    
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Large negative number";

    // Assign test case stimulus
    tb_in = 17'b10000000011000110;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_out(16'b1111111100111010, "for large negative number");
  end
endmodule
