// $Id: $
// File name:   tb_timer.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Timer unit testbench

`timescale 1ns / 10ps

module tb_timer();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 10;
  localparam  NUM_CNT_BITS = 10;
  localparam  RESET_CNT_VALUE = 10'b0000000000;
  localparam  RESET_ONE_VALUE = 1'b0;

  
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_cnt_up;
  reg tb_clear;
  reg [(NUM_CNT_BITS - 1):0] tb_cnt;
  wire tb_one_k_samples;
  
  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;
  integer cont_cnt;
  
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

  // Task to cleanly and consistently check DUT cnt
  task check_cnt;
    input logic [(NUM_CNT_BITS - 1):0] expected_count;
    input string check_tag;
  begin
    if(expected_count == tb_cnt) begin // Check passed
      //$info("Correct cnt output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect cnt output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Task to cleanly and consistently check DUT one_k_samples
  task check_one;
    input logic expected_one_k;
    input string check_tag;
  begin
    if(expected_one_k == tb_one_k_samples) begin // Check passed
      //$info("Correct one_k_samples output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect one_k_samples output %s during %s test case", check_tag, tb_test_case);
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
    .clk(tb_clk), .n_rst(tb_n_rst), .cnt_up(tb_cnt_up), .clear(tb_clear), 
    .cnt(tb_cnt), .one_k_samples(tb_one_k_samples));
  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_cnt_up = 1'b0;              // Initialize to be inactive
    tb_clear = 1'b0;               // Initialize to be inactive
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
    check_cnt(RESET_CNT_VALUE, "after reset applied");
    check_one(RESET_ONE_VALUE, "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_cnt(RESET_CNT_VALUE, "after reset applied");
    check_one(RESET_ONE_VALUE, "after reset applied");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_cnt(RESET_CNT_VALUE, "after reset applied");
    check_one(RESET_ONE_VALUE, "after reset applied");

    // ************************************************************************
    // Test Case 2: Normal operation
    // ************************************************************************    
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Normal operation";
    // Reset DUT
    tb_cnt_up = 1'b0;              // Initialize to be inactive
    tb_clear = 1'b0;               // Initialize to be inactive
    reset_dut();
    
    // Assign test case stimulus (try at posedge)
    @(posedge tb_clk);
    tb_cnt_up = 1'b1;
    @(posedge tb_clk);
    tb_cnt_up = 1'b0;
    
    // Check result
    @(negedge tb_clk);
    check_cnt(RESET_CNT_VALUE + 1, "after posedge cnt_up applied");
    check_one(RESET_ONE_VALUE, "after posedge cnt_up applied");

    // Wait a bit
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    
    // Apply test case stimulus (try at negedge)
    @(negedge tb_clk);
    tb_cnt_up = 1'b1;
    @(negedge tb_clk);
    tb_cnt_up = 1'b0;

    // Check result
    @(negedge tb_clk);
    check_cnt(RESET_CNT_VALUE + 2, "after negedge cnt_up applied");
    check_one(RESET_ONE_VALUE, "after negedge cnt_up applied");

    // Keep counting
    for (cont_cnt = 2; cont_cnt < 999; cont_cnt++) begin
      @(negedge tb_clk);
      @(negedge tb_clk);
      tb_cnt_up = 1'b1;
      @(negedge tb_clk);
      tb_cnt_up = 1'b0;
      check_cnt(cont_cnt + 1, "during normal counting");
      check_one(RESET_ONE_VALUE, "during normal counting");
    end

    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_cnt_up = 1'b1;
    @(negedge tb_clk);
    tb_cnt_up = 1'b0;
    check_cnt(cont_cnt + 1, "after normal counting at 1000");
    check_one(1'b1, "after normal counting at 1000");
    @(negedge tb_clk);
    tb_cnt_up = 1'b1;
    @(negedge tb_clk);
    tb_cnt_up = 1'b0;
    check_cnt(10'b0000000001, "after looping around to 1");
    check_one(RESET_ONE_VALUE, "after looping around to 1");
    

    // ************************************************************************
    // Test Case 3: Reset during counting
    // ************************************************************************  
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Reset during counting";
    // Reset DUT
    tb_cnt_up = 1'b0;              // Initialize to be inactive
    tb_clear = 1'b0;               // Initialize to be inactive
    reset_dut();

    // Count for a bit
    for (cont_cnt = 0; cont_cnt < 5; cont_cnt++) begin
      @(negedge tb_clk);
      @(negedge tb_clk);
      tb_cnt_up = 1'b1;
      @(negedge tb_clk);
      tb_cnt_up = 1'b0;
      check_cnt(cont_cnt + 1, "during reset during counting");
      check_one(RESET_ONE_VALUE, "during reset during counting");
    end

    // Apply reset
    reset_dut();

    // Check results
    check_cnt(RESET_CNT_VALUE, "after resetting during counting");
    check_one(RESET_ONE_VALUE, "after resetting during counting");

    // ************************************************************************
    // Test Case 4: Clear during counting
    // ************************************************************************  
    @(negedge tb_clk);
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Clear during counting";
    // Reset DUT
    tb_cnt_up = 1'b0;              // Initialize to be inactive
    tb_clear = 1'b0;               // Initialize to be inactive
    reset_dut();

    // Count for a bit
    for (cont_cnt = 0; cont_cnt < 10; cont_cnt++) begin
      @(negedge tb_clk);
      @(negedge tb_clk);
      tb_cnt_up = 1'b1;
      @(negedge tb_clk);
      tb_cnt_up = 1'b0;
      check_cnt(cont_cnt + 1, "during clear during counting");
      check_one(RESET_ONE_VALUE, "during clear during counting");
    end

    // Apply clear
    tb_clear = 1'b1;
    @(negedge tb_clk);
    // Check precedence
    tb_cnt_up = 1'b1;
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_cnt_up = 1'b0;
    @(negedge tb_clk);
    tb_clear = 1'b0;

    // Check results
    check_cnt(RESET_CNT_VALUE, "after clear during counting");
    check_one(RESET_ONE_VALUE, "after clear during counting");

  end
endmodule
