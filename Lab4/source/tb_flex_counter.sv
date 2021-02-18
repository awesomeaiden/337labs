// $Id: $
// File name:   tb_flex_counter.sv
// Created:     2/16/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter Default TESTBENCH

// 0.5um D-FlipFlop Timing Data Estimates:
// Data Propagation delay (clk->Q): 670ps
// Setup time for data relative to clock: 190ps
// Hold time for data relative to clock: 10ps

`timescale 1ns / 10ps

module tb_flex_counter();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 2.5;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  localparam  NUM_CNT_BITS = 3;
  localparam  RESET_VALUE     = 0;
  localparam  RESET_OUTPUT_VALUE = 0;
  
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_clear;
  reg tb_count_enable;
  reg [NUM_CNT_BITS:0] tb_rollover_val;
  wire [NUM_CNT_BITS:0] tb_count_out;
  wire tb_rollover_flag;
  
  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;
  
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

  // Task for shutting down the DUT
  task shutdown_dut;
  begin
    reset_dut();
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
  end
  endtask

  // Task to cleanly and consistently check DUT count
  task check_count;
    input logic [NUM_CNT_BITS:0] expected_count;
    input string check_tag;
  begin
    if(expected_count == tb_count_out) begin // Check passed
      $info("Correct counter output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect counter output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT rollover_flag
  task check_flag;
    input logic  expected_flag;
    input string check_tag;
  begin
    if(expected_flag == tb_rollover_flag) begin // Check passed
      $info("Correct counter flag %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect counter flag %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently assert clear
  task pulse_clear;
  begin
    @(negedge tb_clk);
    tb_clear = 1'b1;
    @(negedge tb_clk);
    tb_clear = 1'b0;
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
  flex_counter DUT(
    .clk(tb_clk), .n_rst(tb_n_rst), .clear(tb_clear), .count_enable(tb_count_enable), 
    .rollover_val(tb_rollover_val), .count_out(tb_count_out), .rollover_flag(tb_rollover_flag));
  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_clear = 1'b0;               // Initialize to be inactive
    tb_count_enable = 1'b0;        // Initialize to be inactive
    tb_rollover_val = 2'b10;       // Initialize rollover_val to be 2
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
    tb_n_rst  = 1'b0;    // Activate reset
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_count(RESET_OUTPUT_VALUE, "after reset applied");
    check_flag(RESET_OUTPUT_VALUE, "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_count( RESET_OUTPUT_VALUE, "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_count(RESET_OUTPUT_VALUE, "after reset was released");

    // ************************************************************************
    // Test Case 2: Rollover for a rollover value that is not a power of two
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Rollover for a rollover value that is not a power of two";
    // Reset DUT
    tb_clear = 1'b0;               // Initialize to be inactive
    tb_count_enable = 1'b0;        // Initialize to be inactive
    tb_rollover_val = 4'b1001;       // Initialize rollover_val to be 9
    reset_dut();

    // Assign test case stimulus
    tb_count_enable = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during rollover 9 counting");
    check_flag(0, "during rollover 9 counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during rollover 9 counting");
    check_flag(0, "during rollover 9 counting");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(8, "during rollover 9 counting");
    check_flag(0, "during rollover 9 counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(9, "during rollover 9 counting");
    check_flag(1, "during rollover 9 counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during rollover 9 counting");
    check_flag(0, "during rollover 9 counting");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(9, "during rollover 9 counting");
    check_flag(1, "during rollover 9 counting");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "after rollover 9 counting");
    check_flag(0, "after rollover 9 counting");

    // ************************************************************************
    // Test Case 3: Continuous counting
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Continuous counting";
    // Reset DUT
    tb_clear = 1'b0;               // Initialize to be inactive
    tb_count_enable = 1'b0;        // Initialize to be inactive
    tb_rollover_val = 2'b10;       // Initialize rollover_val to be 2
    reset_dut();

    // Assign test case stimulus
    tb_count_enable = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during continuous counting");
    check_flag(0, "during continuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during continuous counting");
    check_flag(1, "during continuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during continuous counting");
    check_flag(0, "during continuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during continuous counting");
    check_flag(1, "during continuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during continuous counting");
    check_flag(0, "during continuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during continuous counting");
    check_flag(1, "during continuous counting");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "after continuous counting");
    check_flag(0, "after continuous counting");

    // ************************************************************************
    // Test Case 4: Discontinuous counting
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Discontinuous counting";
    // Reset DUT
    tb_clear = 1'b0;               // Initialize to be inactive
    tb_count_enable = 1'b0;        // Initialize to be inactive
    tb_rollover_val = 3'b100;       // Initialize rollover_val to be 4
    reset_dut();

    // Assign test case stimulus
    tb_count_enable = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");

    // Assign test case stimulus
    tb_count_enable = 1'b0;

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");

    // Assign test case stimulus
    tb_count_enable = 1'b1;

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(3, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(4, "during discontinuous counting");
    check_flag(1, "during discontinuous counting");

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");
    
    // Assign test case stimulus
    tb_count_enable = 1'b0;

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during discontinuous counting");
    check_flag(0, "during discontinuous counting");

    // ************************************************************************
    // Test Case 5: Clearing while counting
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Clearing while counting";
    // Reset DUT
    tb_clear = 1'b0;               // Initialize to be inactive
    tb_count_enable = 1'b0;        // Initialize to be inactive
    tb_rollover_val = 3'b100;       // Initialize rollover_val to be 4
    reset_dut();

    // Assign test case stimulus
    tb_count_enable = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during clearing while counting");
    check_flag(0, "during clearing while counting");
    @(posedge tb_clk);

    // Assign test case stimulus
    pulse_clear();
  
    // Check results
    check_count(0, "during clearing while counting");
    check_flag(0, "during clearing while counting");

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(1, "during clearing while counting");
    check_flag(0, "during clearing while counting");

    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_count(2, "during clearing while counting");
    check_flag(0, "during clearing while counting");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing complete";
    shutdown_dut();
  end
endmodule
