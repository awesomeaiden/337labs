// $Id: $
// File name:   tb_conv_controller.sv
// Created:     4/2/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Test bench for the Convolution Controller

`timescale 1ns / 10ps

module tb_conv_controller();
  // Define parameters
  // Common parameters
  localparam CLK_PERIOD        = 2.5;
  localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
  localparam  INACTIVE_VALUE     = 1'b0;
  localparam RESET_OUTPUT_VALUE  = 1'b0;

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  int     tb_bit_num;
  logic   tb_mismatch;
  logic   tb_check;

  // Declare the Test Bench Signals for Expected Results
  logic tb_expected_load_coeff;
  logic tb_expected_load_sample;
  logic tb_expected_start_conv;
  logic tb_expected_shift;
  logic tb_expected_result_ready;

  // Declare DUT Connection Signals
  logic tb_clk;
  logic tb_n_rst;
  logic tb_conv_en;
  logic tb_coeff_loaded;
  logic tb_sample_loaded;
  logic tb_conv_complete;
  logic tb_sample_complete;
  logic tb_load_coeff;
  logic tb_load_sample;
  logic tb_start_conv;
  logic tb_shift;
  logic tb_result_ready;

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

    if(tb_expected_load_coeff == tb_load_coeff) begin // Check passed
      $info("Correct load_coeff output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect load_coeff output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_load_sample == tb_load_sample) begin // Check passed
      $info("Correct load_sample output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect load_sample output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_start_conv == tb_start_conv) begin // Check passed
      $info("Correct start_conv output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect start_conv output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_shift == tb_shift) begin // Check passed
      $info("Correct shift output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect shift output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_result_ready == tb_result_ready) begin // Check passed
      $info("Correct result_ready output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect result_ready output %s during %s test case", check_tag, tb_test_case);
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
  end
  endtask

  // Task to cleanly and consistently initialize expected values
  task init_expected;
  begin
    tb_expected_load_coeff = 1'b0;
    tb_expected_load_sample = 1'b0;
    tb_expected_start_conv = 1'b0;
    tb_expected_shift = 1'b0;
    tb_expected_result_ready = 1'b0;
  end
  endtask

  // Task to cleanly and consistently initialize input values
  task init_inputs;
  begin
    tb_conv_en = 1'b0;
    tb_coeff_loaded = 1'b0;
    tb_sample_loaded = 1'b0;
    tb_conv_complete = 1'b0;
    tb_sample_complete = 1'b0;
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
  conv_controller DUT (.clk(tb_clk), 
                       .n_rst(tb_n_rst), 
                       .conv_en(tb_conv_en),
                       .coeff_loaded(tb_coeff_loaded),
                       .sample_loaded(tb_sampled_loaded),
                       .conv_complete(tb_conv_complete),
                       .sample_complete(tb_sample_complete),
                       .load_coeff(tb_load_coeff),
                       .load_sample(tb_load_sample),
                       .start_conv(tb_start_conv),
                       .shift(tb_shift),
                       .result_ready(tb_result_ready));


  // Test bench main process
  initial begin
    // Initialize all of the test inputs
    tb_n_rst            = 1'b1; // Initialize to be inactive
    init_inputs(); // Initialize inputs to inactive values
    init_expected(); // Initialize inputs to inactive values
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";
    tb_bit_num          = -1;   // Initialize to invalid number
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
    tb_n_rst     = 1'b0;

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    init_expected();
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
    // Test Case 2: Normal Operation
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal Operation";
    // Start out with inactive inputs and reset the DUT to isolate from prior tests
    init_inputs();
    reset_dut();

    @negedge(tb_clk);
    tb_conv_en = 1'b1;
    
  end
endmodule
  
