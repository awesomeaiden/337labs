// $Id: $
// File name:   tb_coeff_reg.sv
// Created:     4/27/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Coefficient Register Testbench

`timescale 1ns / 10ps

module tb_coeff_reg();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  RESET_VALUE     = 0;
  localparam  FF_HOLD_TIME  = 0.100;
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_coeff_ld;
  reg [15:0] tb_coeff_in;
  reg [1:0] tb_coeff_sel;
  wire [35:0] tb_coeff_out;

  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  // Task to cleanly and consistently check DUT outputs
  task check_outputs;
    input logic [35:0] expected_coeff_out;
    input string check_tag;
  begin
    if(expected_coeff_out == tb_coeff_out) begin // Check passed
      $info("Correct coeff_out %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect coeff_out %s during %s test case", check_tag, tb_test_case);
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
    tb_coeff_ld = 1'b0;          // Initialize to be inactive
    tb_coeff_in = 16'd0;         // Initialize to be inactive
    tb_coeff_sel = 2'b00;           // Initialize to be inactive
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
  coeff_reg DUT(.clk(tb_clk), .n_rst(tb_n_rst), .coeff_ld(tb_coeff_ld), 
               .coeff_in(tb_coeff_in), .coeff_sel(tb_coeff_sel), .coeff_out(tb_coeff_out));

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
    check_outputs(36'd0, "during reset");

    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_outputs(36'd0, "after reset");

    // ************************************************************************
    // Test Case 2: Coefficient Load Enable Test
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Coefficient Load Enable Test";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Sequence of coefficients sent to 00 register, pulsing coeff_ld
    tb_coeff_in = 16'd68;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_outputs(36'd0, "without load enable");
    tb_coeff_ld = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_outputs(36'd68, "with load enable");

    // ************************************************************************
    // Test Case 3: Coefficient Addressing Test
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Coefficient Addressing Test";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Send three coefficients
    tb_coeff_in = 16'd1;
    tb_coeff_sel = 2'b00;
    tb_coeff_ld = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_outputs({12'd0, 12'd0, 12'd1}, "after loading 00 register");
    tb_coeff_in = 16'd2;
    tb_coeff_sel = 2'b01;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_outputs({12'd0, 12'd2, 12'd1}, "after loading 01 register");
    tb_coeff_in = 16'd3;
    tb_coeff_sel = 2'b10;
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_outputs({12'd3, 12'd2, 12'd1}, "after loading 10 register");
  end
endmodule
