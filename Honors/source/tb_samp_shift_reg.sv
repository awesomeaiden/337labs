// $Id: $
// File name:   tb_samp_shift_reg.sv
// Created:     4/29/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Testbench for sample shift register

`timescale 1ns / 10ps

module tb_samp_shift_reg();
  // Define parameters
  // Common parameters
  localparam CLK_PERIOD        = 2.5;
  localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay

  localparam  INACTIVE_VALUE     = 1'b1;
  localparam  SR_SIZE_BITS       = 36;
  localparam  SR_MAX_BIT         = SR_SIZE_BITS - 1;
  localparam  RESET_OUTPUT_VALUE = {SR_SIZE_BITS{1'b1}};

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  string  tb_stream_check_tag;
  int     tb_col_num;
  logic   tb_mismatch;
  logic   tb_check;

  // Declare the Test Bench Signals for Expected Results
  logic [SR_MAX_BIT:0] tb_expected_output;
  logic tb_test_data [];

  // Declare DUT Connection Signals
  logic                tb_clk;
  logic                tb_n_rst;
  logic                tb_shift_en;
  logic [15:0]         tb_col_in;
  logic [SR_MAX_BIT:0] tb_sample_out;

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

  // Task to cleanly and consistently check DUT output values
  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    if(tb_expected_output == tb_sample_out) begin // Check passed
      $info("Correct parallel output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect parallel output %s during %s test case", check_tag, tb_test_case);
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
  end
  endtask

  // Task to manage the timing of sending one bit through the shift register
  task send_col;
    input logic [11:0] col_to_send;
  begin
    // Synchronize to the negative edge of clock to prevent timing errors
    @(negedge tb_clk);
    
    // Set the value of the bit
    tb_col_in = col_to_send;
    // Activate the shift enable
    tb_shift_en = 1'b1;

    // Wait for the value to have been shifted in on the rising clock edge
    @(posedge tb_clk);
    #(PROPAGATION_DELAY);

    // Turn off the Shift enable
    tb_shift_en = 1'b0;
  end
  endtask

  // Task to contiguosly send a stream of bits through the shift register
  task send_stream;
    input logic [11:0] col_stream [];
  begin
    // Coniguously stream out all of the bits in the provided input vector
    for(tb_col_num = 0; tb_col_num < col_stream.size(); tb_col_num++) begin
      // Send the current bit
      send_col(col_stream[tb_col_num]);
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
  samp_shift_reg DUT (.clk(tb_clk), .n_rst(tb_n_rst), 
                    .col_in(tb_col_in), 
                    .shift_en(tb_shift_en), 
                    .sample_out(tb_sample_out));


  // Test bench main process
  initial begin
    // Initialize all of the test inputs
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_col_in        = 16'b1111111111111111; // Initialize to inactive value
    tb_shift_en         = 1'b0; // Initialize to be inactive
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";
    tb_stream_check_tag = "N/A";
    tb_col_num          = -1;   // Initialize to invalid number
    tb_mismatch         = 1'b0;
    tb_check            = 1'b0;
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
    tb_col_in    = 16'd0;
    tb_n_rst     = 1'b0;

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    tb_expected_output = RESET_OUTPUT_VALUE;
    check_output("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output("after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    // Check that internal state was correctly keep after reset release
    #(PROPAGATION_DELAY);
    check_output("after reset was released");

    // ************************************************************************
    // Test Case 2: Shift Enable Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Shift Enable Test";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_col_in = 16'b1111111111111111;
    reset_dut();

    // Start with no shift enable
    tb_shift_en = 1'b0;
    tb_col_in = 16'd100;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Output should still be reset
    tb_expected_output = 36'b111111111111111111111111111111111111;
    check_output("with no shift enable");

    // Now shift enable
    tb_shift_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000001100100111111111111111111111111;
    check_output("first shift enable");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000001100100000001100100111111111111;
    check_output("second shift enable");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000001100100000001100100000001100100;
    check_output("third shift enable");

    // ************************************************************************
    // Test Case 3: Single Sample Shift
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Single Sample Shift";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_col_in = 16'b1111111111111111;
    reset_dut();

    // Shift single sample through
    tb_shift_en = 1'b1;
    tb_col_in = 16'd100;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000001100100111111111111111111111111;
    check_output("one sample shifted in");
    tb_col_in = 16'd0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000000000000000001100100111111111111;
    check_output("one sample shifted in");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000000000000000000000000000001100100;
    check_output("one sample shifted in");

    // ************************************************************************
    // Test Case 4: Three Sample Shift
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Single Sample Shift";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_col_in = 16'b1111111111111111;
    reset_dut();

    // Shift single sample through
    tb_shift_en = 1'b1;
    tb_col_in = 16'd100;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000001100100111111111111111111111111;
    check_output("one sample shifted in");
    tb_col_in = 16'd200;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000011001000000001100100111111111111;
    check_output("two samples shifted in");
    tb_col_in = 16'd300;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_output = 36'b000100101100000011001000000001100100;
    check_output("three samples shifted in");
  end
endmodule
  
