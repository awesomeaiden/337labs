// $Id: $
// File name:   tb_coefficient_loader.sv
// Created:     3/31/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Coefficient Loader Testbench

`timescale 1ns / 10ps

module tb_coefficient_loader();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  localparam  RESET_VALUE     = 0;
  localparam  RESET_OUTPUT_VALUE = 0;

  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_reset;
  reg tb_new_coefficient_set;
  reg tb_modwait;
  wire tb_load_coeff;
  wire [1:0] tb_coefficient_num;

  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_n_reset = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_n_reset = 1'b1;

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges,
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Task to cleanly and consistently check DUT load_coeff
  task check_load_coeff;
    input logic  expected_coeff;
    input string check_tag;
  begin
    if(expected_coeff == tb_load_coeff) begin // Check passed
      $info("Correct load_coeff %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect load_coeff %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT coefficient_num
  task check_coefficient_num;
    input logic  expected_coefficient_num;
    input string check_tag;
  begin
    if(expected_coefficient_num == tb_coefficient_num) begin // Check passed
      $info("Correct coefficient_num %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect coefficient_num %s during %s test case", check_tag, tb_test_case);
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
  coefficient_loader DUT(
    .clk(tb_clk), .n_reset(tb_n_reset), .new_coefficient_set(tb_new_coefficient_set),
     .modwait(tb_modwait), .load_coeff(tb_load_coeff), .coefficient_num(tb_coefficient_num));

  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_reset  = 1'b1;            // Initialize to be inactive
    tb_new_coefficient_set = 1'b0; // Initialize to be inactive
    tb_modwait = 1'b0;             // Initialize to be inactive
    tb_test_num = 0;               // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_n_reset  = 1'b0;    // Activate reset

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_load_coeff(1'b0, "after reset applied");
    check_coefficient_num(2'b00, "after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_count( RESET_OUTPUT_VALUE, "after clock cycle while in reset");

    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_reset  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_load_coeff(1'b0, "after reset applied");
    check_coefficient_num(2'b00, "after reset applied");

    // ************************************************************************
    // Test Case 2: Normal loading operation
    // ************************************************************************
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Normal loading operation";

    // Reset DUT
    tb_n_reset  = 1'b1;            // Initialize to be inactive
    tb_new_coefficient_set = 1'b0; // Initialize to be inactive
    tb_modwait = 1'b0;             // Initialize to be inactive
    reset_dut();

    // Assign test case stimulus
    @(negedge tb_clk)
    tb_new_coefficient_set = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_load_coeff(1'b1, "after new_coefficient_set applied");
    check_coefficient_num(2'b00, "after new_coefficient_set applied");
    @(posedge tb_clk);
    tb_modwait = 1'b1; // FIR module responds and starts the load
    @(negedge tb_clk);
    check_load_coeff(1'b0, "after load f0 started");
    check_coefficient_num(2'b00, "after load f0 started");
    @(posedge tb_clk);
    @(posedge tb_clk);
    // Now FIR module is done loading
    tb_modwait = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_load_coeff(1'b1, "when starting load f1");
    check_coefficient_num(2'b01, "when starting load f1");
    @(posedge tb_clk);
    tb_modwait = 1'b1;
    // Say this time it finishes loading within one clock period
    @(negedge tb_clk);
    tb_modwait = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_load_coeff(1'b1, "when starting load f2");
    check_coefficient_num(2'b10, "when starting load f2");
    @(posedge tb_clk);
    tb_modwait = 1'b1;
    // Say this time it takes another clock period to load
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_modwait = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_load_coeff(1'b1, "when starting load f3");
    check_coefficient_num(2'b11, "when starting load f3");
     // end of test cases
  end
endmodule
