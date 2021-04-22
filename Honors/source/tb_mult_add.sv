// $Id: $
// File name:   tb_mult_add.sv
// Created:     4/22/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Multipler/Adder Testbench

`timescale 1ns / 10ps

module tb_mult_add();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  RESET_VALUE     = 0;
  localparam  FF_HOLD_TIME  = 0.100;
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg [35:0] tb_sample_in;
  reg [35:0] tb_coeff_in;
  reg tb_conv_en;
  wire [15:0] tb_result;
  wire tb_result_ready;

  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  // Task to cleanly and consistently check DUT outputs
  task check_outputs;
    input logic  expected_result_ready;
    input string check_tag;
    integer expected_result;
  begin
    expected_result = (tb_sample_in[3:0] * tb_coeff_in[3:0]) 
                    + (tb_sample_in[7:4] * tb_coeff_in[7:4])
                    + (tb_sample_in[11:8] * tb_coeff_in[11:8])
                    + (tb_sample_in[15:12] * tb_coeff_in[15:12])
                    + (tb_sample_in[19:16] * tb_coeff_in[19:16])
                    + (tb_sample_in[23:20] * tb_coeff_in[23:20])
                    + (tb_sample_in[27:24] * tb_coeff_in[27:24])
                    + (tb_sample_in[31:28] * tb_coeff_in[31:28])
                    + (tb_sample_in[35:32] * tb_coeff_in[35:32]);

    if(expected_result == tb_result) begin // Check passed
      $info("Correct result %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect result %s during %s test case", check_tag, tb_test_case);
    end

    if(expected_result_ready == tb_result_ready) begin // Check passed
      $info("Correct result_ready %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect result_ready %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

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

  // Task for standard DUT input clear procedure
  task clear_inputs;
  begin
    tb_n_rst  = 1'b1;            // Initialize to be inactive
    tb_sample_in = 36'd0;        // Initialize to be inactive
    tb_coeff_in = 36'd0;         // Initialize to be inactive
    tb_conv_en = 1'b0;           // Initialize to be inactive
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
  mult_add DUT(.clk(tb_clk), .n_rst(tb_n_rst), .sample_in(tb_sample_in), 
               .coeff_in(tb_coeff_in), .conv_en(tb_conv_en), .result(tb_result),
               .result_ready(tb_result_ready));

  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    clear_inputs();
    tb_test_num = 0;             // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Power On / Reset
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_n_rst  = 1'b0;    // Activate reset

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_outputs(1'b0, "during reset");

    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_outputs(1'b0, "after reset");

    // ************************************************************************
    // Test Case 2: Zeros
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Zeros";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input all zeros - done
    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

    // ************************************************************************
    // Test Case 3: Small Coefficients / Small Samples
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Small Coefficients / Small Samples";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input small coefficients / small samples
    tb_coeff_in = 36'h321312123;
    tb_sample_in = 36'h123132231;

    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

    // ************************************************************************
    // Test Case 4: Small Coefficients / Large Samples
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Small Coefficients / Large Samples";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input small coefficients / large samples
    tb_coeff_in = 36'h321312123;
    tb_sample_in = 36'hdfefedefd;

    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

    // ************************************************************************
    // Test Case 5: Large Coefficients / Small Samples
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Large Coefficients / Small Samples";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input large coefficients / small samples
    tb_coeff_in = 36'hdfefedefd;
    tb_sample_in = 36'h123132231;

    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

    // ************************************************************************
    // Test Case 6: Large Coefficients / Large Samples
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Large Coefficients / Large Samples";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input large coefficients / large samples
    tb_coeff_in = 36'hdfefedefd;
    tb_sample_in = 36'hdfefedefd;

    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

    // ************************************************************************
    // Test Case 7: Max
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Max";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Input large coefficients / large samples
    tb_coeff_in = 36'hfffffffff;
    tb_sample_in = 36'hfffffffff;

    // Pulse conv_en
    @(posedge tb_clk);
    tb_conv_en = 1'b1;
    @(posedge tb_clk);
    tb_conv_en = 1'b0;

    // Check outputs
    @(negedge tb_clk);
    check_outputs(1'b1, "during result_ready");
    @(negedge tb_clk);
    check_outputs(1'b0, "after result_ready");

  end
endmodule
