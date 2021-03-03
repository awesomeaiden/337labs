// $Id: $
// File name:   tb_rcu.sv
// Created:     2/24/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Test bench for the rcu

`timescale 1ns / 10ps

module tb_rcu();
  // Define parameters
  // Common parameters
  localparam CLK_PERIOD        = 2.5;
  localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
  localparam  INACTIVE_VALUE     = 1'b0;
  localparam RESET_OUTPUT_VALUE  = 1'b0;

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  string  tb_stream_check_tag;
  int     tb_bit_num;
  logic   tb_mismatch;
  logic   tb_check;

  // Declare DUT Connection Signals
  logic tb_clk;
  logic tb_n_rst;
  logic tb_start_bit_detected;
  logic tb_packet_done;
  logic tb_framing_error;
  logic tb_sbc_clear;
  logic tb_sbc_enable;
  logic tb_load_buffer;
  logic tb_enable_timer;

// Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_n_rst = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_n_rst = 1'b1;

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Task to cleanly and consistently check DUT sbc_clear
  task check_clear;
    input logic  expected_val;
    input string check_tag;
  begin
    if(expected_val == tb_sbc_clear) begin // Check passed
      $info("Correct sbc clear %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect sbc clear %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT sbc_enable
  task check_enable;
    input logic  expected_val;
    input string check_tag;
  begin
    if(expected_val == tb_sbc_enable) begin // Check passed
      $info("Correct sbc enable %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect sbc enable %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT load_buffer
  task check_buffer;
    input logic  expected_val;
    input string check_tag;
  begin
    if(expected_val == tb_load_buffer) begin // Check passed
      $info("Correct load buffer %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect load buffer %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT enable_timer
  task check_timer;
    input logic  expected_val;
    input string check_tag;
  begin
    if(expected_val == tb_enable_timer) begin // Check passed
      $info("Correct enable timer %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect enable timer %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Clock generation block
  always begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end

  // DUT Portmap
  rcu DUT (.clk(tb_clk), 
           .n_rst(tb_n_rst), 
           .start_bit_detected(tb_start_bit_detected),
           .packet_done(tb_packet_done),
           .framing_error(tb_framing_error),
           .sbc_clear(tb_sbc_clear),
           .sbc_enable(tb_sbc_enable),
           .load_buffer(tb_load_buffer),
           .enable_timer(tb_enable_timer));


  // Test bench main process
  initial begin
    // Initialize all of the test inputs
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_start_bit_detected = 1'b0; // Initialize to inactive value
    tb_packet_done = 1'b0; // Initialize to inactive value
    tb_framing_error = 1'b0; // Initialize to inactive value
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";

    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_n_rst     = 1'b0;

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_clear(0, "after reset applied");
    check_enable(0, "after reset applied");
    check_buffer(0, "after reset applied");
    check_timer(0, "after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_clear(0, "after clock cycle while in reset");
    check_enable(0, "after clock cycle while in reset");
    check_buffer(0, "after clock cycle while in reset");
    check_timer(0, "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset

    // ************************************************************************
    // Test Case 2: Normal Operation (Full sequence)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal Operation";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_start_bit_detected = 1'b0; // Initialize to inactive value
    tb_packet_done = 1'b0; // Initialize to inactive value
    tb_framing_error = 1'b0; // Initialize to inactive value
    reset_dut();

    // DUT in idle state (0)

    // Assert input to transition to state 1
    @(negedge tb_clk);
    tb_start_bit_detected = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_start_bit_detected = 1'b0;
    check_clear(1, "after transition to state 1");
    check_timer(1, "after transition to state 1");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 2
    check_clear(0, "after transition to state 2");
    check_timer(1, "after transition to state 2");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk):
    check_timer(1, "after transition to state 2");
    @(negedge tb_clk);
    tb_packet_done = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 3 (stop bit check)
    check_timer(0, "after transition to state 3");
    check_enable(1, "after transition to state 3");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 4 (load data)
    check_enable(0, "after transition to state 4");
    check_buffer(1, "after transition to state 4");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned back to idle state
    check_clear(0, "after transition to idle state");
    check_enable(0, "after transition to idle state");
    check_buffer(0, "after transition to idle state");
    check_timer(0, "after transition to idle state");


    // ************************************************************************
    // Test Case 3: Normal Operation with framing error
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal Operation with framing error";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_start_bit_detected = 1'b0; // Initialize to inactive value
    tb_packet_done = 1'b0; // Initialize to inactive value
    tb_framing_error = 1'b0; // Initialize to inactive value
    reset_dut();

    // DUT in idle state (0)

    // Assert input to transition to state 1
    @(negedge tb_clk);
    tb_start_bit_detected = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_start_bit_detected = 1'b0;
    check_clear(1, "after transition to state 1");
    check_timer(1, "after transition to state 1");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 2
    check_clear(0, "after transition to state 2");
    check_timer(1, "after transition to state 2");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk):
    check_timer(1, "after transition to state 2");
    @(negedge tb_clk);
    tb_packet_done = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 3 (stop bit check)
    check_timer(0, "after transition to state 3");
    check_enable(1, "after transition to state 3");
    tb_framing_error = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 4 (load data)
    check_enable(0, "after transition to state 4");
    check_buffer(1, "after transition to state 4");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned back to idle state
    check_clear(0, "after transition to idle state");
    check_enable(0, "after transition to idle state");
    check_buffer(0, "after transition to idle state");
    check_timer(0, "after transition to idle state");
    
  end
endmodule
  
