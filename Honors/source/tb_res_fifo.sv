// $Id: $
// File name:   tb_res_fifo.sv
// Created:     4/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Result FIFO Register

`timescale 1ns / 10ps

module tb_res_fifo();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  RESET_VALUE     = 0;
  localparam  FF_HOLD_TIME  = 0.100;
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_wenable;
  reg tb_renable;
  reg [15:0] tb_result_in;
  reg tb_empty;
  reg [15:0] tb_result_out;

  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  // Task to cleanly and consistently check DUT outputs
  task check_outputs;
    input logic expected_empty;
    input logic [15:0] expected_result_out;
    input string check_tag;
  begin
    if(expected_empty == tb_empty) begin // Check passed
      $info("Correct empty %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect empty %s during %s test case", check_tag, tb_test_case);
    end

    if(expected_result_out == tb_result_out) begin // Check passed
      $info("Correct result_out %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect result_out %s during %s test case", check_tag, tb_test_case);
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
    tb_wenable = 1'b0;          // Initialize to be inactive
    tb_renable = 1'b0;         // Initialize to be inactive
    tb_result_in = 16'd0;           // Initialize to be inactive
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
  res_fifo DUT(.clk(tb_clk), .n_rst(tb_n_rst), .wenable(tb_wenable), .renable(tb_renable), 
               .result_in(tb_result_in), .empty(tb_empty), .result_out(tb_result_out));

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
    check_outputs(1'b0, 16'd0, "during reset");

    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_outputs(1'b0, 16'd0, "after reset");

    // ************************************************************************
    // Test Case 2: Wenable Test
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Wenable Test";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Check empty
    check_outputs(1'b1, 16'd0, "before writing values");

    // Sequence of result_in values, pusling wenable to ensure correct operation
    tb_result_in = 16'd68;
    tb_wenable = 1'b1;
    @(posedge tb_clk);
    tb_result_in = 16'2021;
    @(posedge tb_clk);
    tb_wenable = 1'b0;
    tb_result_in = 16'd572;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    tb_wenable = 1'b1;
    tb_result_in = 16'd984;
    @(posedge tb_clk);
    tb_wenable = 1'b0;
    
    // Now read values back
    tb_renable = 1'b1;
    @(posedge tb_clk);
    check_outputs(1'b0, 16'd68, "reading first value");
    @(posedge tb_clk);
    check_outputs(1'b0, 16'd2021, "reading second value");
    @(posedge tb_clk);
    check_outputs(1'b1, 16'd984, "reading third value");

    // ************************************************************************
    // Test Case 3: Renable Test
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Renable Test";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Send three values in
    tb_result_in = 16'd68;
    tb_wenable = 1'b1;
    @(posedge tb_clk);
    tb_result_in = 16'2021;
    @(posedge tb_clk);
    tb_result_in = 16'd984;
    @(posedge tb_clk);
    tb_wenable = 1'b0;

    // Read while pulsing renable
    check_output(1'b0, 16'd0, "before reading value");
    @(negedge tb_clk);
    tb_renable = 1'b1;
    @(posedge tb_clk);
    check_output(1'b0, 16'd68, "reading first value");
    tb_renable = 1'b0;
    @(posedge tb_clk);
    check_output(1'b0, 16'd68, "after first value");
    tb_renable = 1'b1;
    @(posedge tb_clk);
    check_output(1'b0, 16'd2021, "reading second value");
    @(posedge tb_clk);
    check_output(1'b1, 16'd984, "reading third value");

    // ************************************************************************
    // Test Case 4: Write when Full Test
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Write when Full Test";

    // Prepare for test
    clear_inputs();
    reset_dut();

    // Fill up FIFO
    tb_result_in = 16'd68;
    tb_wenable = 1'b1;
    @(posedge tb_clk);
    tb_result_in = 16'2021;
    @(posedge tb_clk);
    tb_result_in = 16'd984;
    @(posedge tb_clk);
    tb_wenable = 1'b0;

    // Attempt to write once more
    chec

  end
endmodule
