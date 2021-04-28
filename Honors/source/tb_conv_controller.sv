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
  localparam  CLK_PERIOD    = 10;
  localparam  RESET_VALUE     = 0;
  localparam  FF_HOLD_TIME  = 0.100;

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;

  // Declare the Test Bench Signals for Expected Results
  logic tb_expected_modwait;
  logic tb_expected_sample_stream;
  logic tb_expected_sample_shift;
  logic tb_expected_convolve_en;
  logic tb_expected_coeff_ld;
  logic [1:0] tb_expected_coeff_sel;

  // Declare DUT Connection Signals
  logic tb_clk;
  logic tb_n_rst;
  logic tb_sample_load_en;
  logic tb_new_row;
  logic tb_coeff_load_en;
  logic tb_modwait;
  logic tb_sample_stream;
  logic tb_sample_shift;
  logic tb_convolve_en;
  logic tb_coeff_ld;
  logic [1:0] tb_coeff_sel;

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

    if(tb_expected_modwait == tb_modwait) begin // Check passed
      //$info("Correct modwait output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect modwait output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_sample_stream == tb_sample_stream) begin // Check passed
      //$info("Correct sample_stream output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect sample_stream output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_sample_shift == tb_sample_shift) begin // Check passed
      //$info("Correct sample_shift output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect sample_shift output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_convolve_en == tb_convolve_en) begin // Check passed
      //$info("Correct convolve_en output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect convolve_en output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_coeff_ld == tb_coeff_ld) begin // Check passed
      //$info("Correct coeff_ld output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect coeff_ld output %s during %s test case", check_tag, tb_test_case);
    end

    if(tb_expected_coeff_sel == tb_coeff_sel) begin // Check passed
      //$info("Correct coeff_sel output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect coeff_sel output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently initialize expected values
  task init_expected;
  begin
    tb_expected_modwait = 1'b0;
    tb_expected_sample_stream = 1'b0;
    tb_expected_sample_shift = 1'b0;
    tb_expected_convolve_en = 1'b0;
    tb_expected_coeff_ld = 1'b0;
    tb_expected_coeff_sel  = 2'b00;
  end
  endtask

  // Task to cleanly and consistently initialize input values
  task init_inputs;
  begin
    tb_n_rst = 1'b1;
    tb_sample_load_en = 1'b0;
    tb_new_row = 1'b0;
    tb_coeff_load_en = 1'b0;
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
                       .sample_load_en(tb_sample_load_en),
                       .new_row(tb_new_row),
                       .coeff_load_en(tb_coeff_load_en),
                       .modwait(tb_modwait),
                       .sample_stream(tb_sample_stream),
                       .sample_shift(tb_sample_shift),
                       .convolve_en(tb_convolve_en),
                       .coeff_ld(tb_coeff_ld),
                       .coeff_sel(tb_coeff_sel));


  // Test bench main process
  initial begin
    // Initialize all of the test inputs
    init_inputs(); // Initialize inputs to inactive values
    init_expected(); // Initialize inputs to inactive values
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
    init_expected();
    check_output("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output("after clock cycle while in reset");

    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    // Check that internal state was correctly keep after reset release
    check_output("after reset was released");

    // ************************************************************************
    // Test Case 2: Coefficient Load Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Coefficient Load Test";
    // Start out with inactive inputs and reset the DUT to isolate from prior tests
    init_inputs();
    init_expected();
    reset_dut();

    @(negedge tb_clk);
    tb_coeff_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_coeff_load_en = 1'b0;
    tb_expected_modwait = 1'b1;
    tb_expected_coeff_ld = 1'b1;
    tb_expected_coeff_sel = 2'b00;
    check_output("loading first coefficient");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_coeff_sel = 2'b01;
    check_output("loading second coefficient");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_coeff_sel = 2'b10;
    check_output("loading third coefficient");
    @(posedge tb_clk);
    @(negedge tb_clk);
    init_expected();
    check_output("after loading coefficients");

    // ************************************************************************
    // Test Case 3: Sample Load Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Sample Load Test";
    // Start out with inactive inputs and DON'T reset the DUT
    init_inputs();
    init_expected();
    //reset_dut();

    @(negedge tb_clk);
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S0 load");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b0;
    tb_expected_sample_shift = 1'b0;
    check_output("during S1 wait");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S1 load");
    tb_sample_load_en = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b0;
    tb_expected_sample_shift = 1'b0;
    check_output("during S2 wait");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output("still during S2 wait");
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S2 load");
    tb_sample_load_en = 1'b0;

    // ************************************************************************
    // Test Case 4: Sample Streaming Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Sample Streaming Test";
    // Start out with inactive inputs and DON'T reset the DUT
    init_inputs();
    init_expected();
    //reset_dut();

    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_convolve_en = 1'b1;
    tb_expected_sample_stream = 1'b1;
    check_output("in convolve state");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_convolve_en = 1'b0;
    check_output("in convolve wait state");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    init_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("in sample stream state");
    @(posedge tb_clk);
    @(negedge tb_clk);
    init_expected();
    tb_expected_convolve_en = 1'b1;
    tb_expected_sample_stream = 1'b1;
    check_output("back in convolve state");
    @(posedge tb_clk);
    @(negedge tb_clk);
    init_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("back in sample stream state");
    @(posedge tb_clk);
    @(negedge tb_clk);
    // in convolve state again

    // ************************************************************************
    // Test Case 5: New Sample Row Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "New Sample Row Test";
    // Start out with inactive inputs and DON'T reset the DUT
    init_inputs();
    init_expected();
    //reset_dut();

    tb_new_row = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S0 load");
    tb_new_row = 1'b0;
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b0;
    tb_expected_sample_shift = 1'b0;
    check_output("during S1 wait");
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S1 load");
    tb_sample_load_en = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b0;
    tb_expected_sample_shift = 1'b0;
    check_output("during S2 wait");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output("still during S2 wait");
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_sample_shift = 1'b1;
    check_output("during S2 load");
    tb_sample_load_en = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    // back in convolve state

    // ************************************************************************
    // Test Case 6: Sample Complete Test
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Sample Complete Test";
    // Start out with inactive inputs and DON'T reset the DUT
    init_inputs();
    init_expected();
    //reset_dut();

    tb_new_row = 1'b1;
    tb_sample_load_en = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output("returned to idle state");
    tb_new_row = 1'b0;
    tb_example_load_en = 1'b1;

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing Complete"
    reset_dut();

  end
endmodule
