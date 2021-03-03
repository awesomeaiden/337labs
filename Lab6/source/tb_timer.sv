// $Id: $
// File name:   tb_flex_counter.sv
// Created:     2/16/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Timer unit testbench

// 0.5um D-FlipFlop Timing Data Estimates:
// Data Propagation delay (clk->Q): 670ps
// Setup time for data relative to clock: 190ps
// Hold time for data relative to clock: 10ps

`timescale 1ns / 10ps

module tb_timer();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 2.5;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  localparam  NUM_CNT_BITS = 4;
  localparam  RESET_VALUE     = 0;
  localparam  RESET_OUTPUT_VALUE = 0;
  
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_enable_timer;
  reg [(NUM_CNT_BITS - 1):0] tb_CNT1;
  reg [(NUM_CNT_BITS - 1):0] tb_CNT2;
  wire tb_shift_enable;
  wire tb_packet_done;
  
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

  // Task to cleanly and consistently check DUT CNT1
  task check_cnt1;
    input logic [(NUM_CNT_BITS - 1):0] expected_count;
    input string check_tag;
  begin
    if(expected_count == tb_CNT1) begin // Check passed
      $info("Correct CNT1 output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect CNT1 output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT CNT2
  task check_cnt2;
    input logic [(NUM_CNT_BITS - 1):0] expected_count;
    input string check_tag;
  begin
    if(expected_count == tb_CNT2) begin // Check passed
      $info("Correct CNT2 output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect CNT2 output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT shift_enable
  task check_shift;
    input logic  expected_shift;
    input string check_tag;
  begin
    if(expected_shift == tb_shift_enable) begin // Check passed
      $info("Correct shift enable %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect shift enable %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT packet_done
  task check_packet;
    input logic  expected_packet;
    input string check_tag;
  begin
    if(expected_packet == tb_packet_done) begin // Check passed
      $info("Correct packet done %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect packet done %s during %s test case", check_tag, tb_test_case);
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
  timer DUT(
    .clk(tb_clk), .n_rst(tb_n_rst), .enable_timer(tb_enable_timer), .shift_enable(tb_shift_enable), 
    .packet_done(tb_packet_done), .CNT1_out(tb_CNT1), .CNT2_out(tb_CNT2));
  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_enable_timer = 1'b0;        // Initialize to be inactive
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
    check_shift(RESET_OUTPUT_VALUE, "after reset applied");
    check_packet(RESET_OUTPUT_VALUE, "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_shift( RESET_OUTPUT_VALUE, "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_shift(RESET_OUTPUT_VALUE, "after reset was released");

    // ************************************************************************
    // Test Case 2: Normal operation
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Normal operation";
    // Reset DUT
    tb_enable_timer = 1'b0;        // Initialize to be inactive
    reset_dut();

    // Assign test case stimulus
    tb_enable_timer = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(1, "during normal operation");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(2, "during normal operation");
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
    check_cnt1(9, "during normal operation");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(10, "during normal operation");
    check_shift(1, "during normal operation");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(1, "during normal operation");
    check_cnt2(1, "during normal operation");
    check_shift(0, "during normal operation");
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
    check_cnt1(9, "during normal operation");
    check_shift(0, "during normal operation");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(10, "after normal operation");
    check_shift(1, "after normal operation");

    // ************************************************************************
    // Test Case 3: Reset during counting
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Reset during counting";
    // Reset DUT
    tb_enable_timer = 1'b0;        // Initialize to be inactive
    reset_dut();

    // Assign test case stimulus
    tb_enable_timer = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(1, "during reset while counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(2, "during reset while counting");
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
    check_cnt1(9, "during reset while counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before applying reset
    @(negedge tb_clk);
    tb_n_rst = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Check results
    check_cnt1(0, "during reset while counting");
    check_shift(0, "during reset while counting");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    tb_n_rst = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Check results
    check_cnt1(1, "during reset while counting");
    check_cnt2(0, "during reset while counting");
    check_shift(0, "during reset while counting");

    // ************************************************************************
    // Test Case 4: Packet done
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Packet done";
    // Reset DUT
    tb_enable_timer = 1'b0;        // Initialize to be inactive
    reset_dut();

    // Assign test case stimulus
    tb_enable_timer = 1'b1;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(1, "during packet done");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 1
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 2
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 3
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 4
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 5
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 6
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 7
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    @(posedge tb_clk); // 8
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); // 10
    // Move away from rising edge and allow for propagation delays before checking
    @(negedge tb_clk);
    // Check results
    check_cnt1(10, "during packet done");
    check_cnt2(8, "during packet done");
    check_shift(1, "during packet done");
    check_packet(0, "during packet done");
    @(posedge tb_clk); // 9
    @(negedge tb_clk);
    check_cnt1(1, "during packet done");
    check_cnt2(9, "during packet done");
    check_shift(0, "during packet done");
    check_packet(1, "during packet done");
    @(posedge tb_clk);
    // Move away from rising edge and allow for propagation delays before applying reset
    @(negedge tb_clk);
    check_cnt1(2, "during packet done");
    check_cnt2(9, "during packet done");
    check_shift(0, "during packet done");
    check_packet(1, "during packet done");
  end
endmodule
