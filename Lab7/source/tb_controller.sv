// $Id: $
// File name:   tb_controller.sv
// Created:     3/10/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Test bench for the controller

`timescale 1ns / 10ps

module tb_controller();
  // Define parameters
  // Common parameters
  localparam CLK_PERIOD        = 10;
  localparam RESET_OUTPUT_VALUE  = 1'b0;

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  string  tb_stream_check_tag;

  // Declare DUT Connection Signals
  logic tb_clk;
  logic tb_n_rst;
  logic tb_dr;
  logic tb_lc;
  logic tb_overflow;
  logic tb_cnt_up, tb_expected_cnt_up;
  logic tb_clear, tb_expected_clear;
  logic tb_modwait, tb_expected_modwait;
  logic [2:0] tb_op, tb_expected_op;
  logic [3:0] tb_src1, tb_expected_src1, tb_src2, tb_expected_src2, tb_dest, tb_expected_dest;
  logic tb_err, tb_expected_err;
  logic [4:0] tb_state_out;

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

  // Task for resetting expected values
  task reset_expected;
  begin
    tb_expected_cnt_up = 1'b0;
    tb_expected_clear = 1'b0;
    tb_expected_modwait = 1'b0;
    tb_expected_op = 3'b000;
    tb_expected_src1 = 4'b0000;
    tb_expected_src2 = 4'b0000;
    tb_expected_dest = 4'b0000;
    tb_expected_err = 1'b0;
  end
  endtask

  // Task to cleanly and consistently check DUT outputs
  task check_outputs;
    input string check_tag;
  begin
    if(tb_expected_cnt_up == tb_cnt_up) begin // Check passed
      //$info("Correct cnt_up %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect cnt_up %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_clear == tb_clear) begin // Check passed
      //$info("Correct clear %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect clear %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_modwait == tb_modwait) begin // Check passed
      //$info("Correct modwait %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect modwait %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_op == tb_op) begin // Check passed
      //$info("Correct op %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect op %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_src1 == tb_src1) begin // Check passed
      //$info("Correct src1 %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect src1 %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_src2 == tb_src2) begin // Check passed
      //$info("Correct src2 %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect src2 %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_dest == tb_dest) begin // Check passed
      //$info("Correct dest %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect dest %s during %s test case", check_tag, tb_test_case);
    end
    if(tb_expected_err == tb_err) begin // Check passed
      //$info("Correct err %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect err %s during %s test case", check_tag, tb_test_case);
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
  controller DUT (.clk(tb_clk), 
           .n_rst(tb_n_rst), 
           .dr(tb_dr),
           .lc(tb_lc),
           .overflow(tb_overflow),
           .cnt_up(tb_cnt_up),
           .clear(tb_clear),
           .modwait(tb_modwait),
           .op(tb_op),
           .src1(tb_src1),
           .src2(tb_src2),
           .dest(tb_dest),
           .err(tb_err),
           .state_out(tb_state_out));


  // Test bench main process
  initial begin
    // Initialize all of the test inputs
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_dr               = 1'b0; // Initialize to be inactive
    tb_lc               = 1'b0; // Initialize to be inactive
    tb_overflow         = 1'b0; // Initialize to be inactive    
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";

    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Power on Reset";

    // Initialize expected values
    reset_expected();

    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_n_rst     = 1'b0;

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_outputs("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_outputs("after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset

    // ************************************************************************
    // Test Case 2: Normal FIR operation (Full sequence)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal FIR Operation";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_dr               = 1'b0; // Initialize to be inactive
    tb_lc               = 1'b0; // Initialize to be inactive
    tb_overflow         = 1'b0; // Initialize to be inactive
    reset_dut();

    // DUT in idle state (0)

    // Initialize expected values
    reset_expected();

    // Assert dr to transition to state 1
    @(negedge tb_clk);
    tb_dr = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b010;
    tb_expected_dest = 4'b0101;
    check_outputs("after transition to state 1 (Store sample)");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 2
    tb_dr = 1'b0;
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_cnt_up = 1'b1;
    tb_expected_op = 3'b101;
    check_outputs("after transition to state 2");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 3
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0001;
    tb_expected_src1 = 4'b0010;
    check_outputs("after transition to state 3");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 4
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0010;
    tb_expected_src1 = 4'b0011;
    check_outputs("after transition to state 4");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 5
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0011;
    tb_expected_src1 = 4'b0100;
    check_outputs("after transition to state 5");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 6
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0100;
    tb_expected_src1 = 4'b0101;
    check_outputs("after transition to state 6");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 7
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0001;
    tb_expected_src2 = 4'b0110;
    check_outputs("after transition to state 7");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 8
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b100;
    tb_expected_src2 = 4'b0110;
    check_outputs("after transition to state 8");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 9
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0010;
    tb_expected_src2 = 4'b0111;
    check_outputs("after transition to state 9");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 10
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b101;
    tb_expected_src2 = 4'b1010;
    check_outputs("after transition to state 10");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 11
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0011;
    tb_expected_src2 = 4'b1000;
    check_outputs("after transition to state 11");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 12
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b100;
    tb_expected_src2 = 4'b1010;
    check_outputs("after transition to state 12");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 13
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0100;
    tb_expected_src2 = 4'b1001;
    check_outputs("after transition to state 13");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 14
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b101;
    tb_expected_src2 = 4'b1010;
    check_outputs("after transition to state 14");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 15
    reset_expected();
    check_outputs("after transition to state 15");

    // ************************************************************************
    // Test Case 3: Normal LC Operation
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal LC Operation";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_dr               = 1'b0; // Initialize to be inactive
    tb_lc               = 1'b0; // Initialize to be inactive
    tb_overflow         = 1'b0; // Initialize to be inactive
    reset_dut();

    // DUT in idle state (0)

    // Initialize expected values
    reset_expected();

    // Assert dr to transition to state 16
    @(negedge tb_clk);
    tb_lc = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_clear = 1'b1;
    tb_expected_op = 3'b011;
    tb_expected_dest = 4'b1001;
    check_outputs("after transition to state 16 (Load F0)");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 17
    reset_expected();
    check_outputs("after transition to state 17");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 18
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b011;
    tb_expected_dest = 4'b1000;
    check_outputs("after transition to state 18");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 19
    reset_expected();
    check_outputs("after transition to state 19");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 20
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b011;
    tb_expected_dest = 4'b0111;
    check_outputs("after transition to state 20");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 21
    reset_expected();
    check_outputs("after transition to state 21");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 22
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b011;
    tb_expected_dest = 4'b0110;
    check_outputs("after transition to state 22");
    tb_lc = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 0
    reset_expected();
    check_outputs("after transition to state 0");

    // ************************************************************************
    // Test Case 4: Overflow FIR operation
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Overflow FIR operation";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_dr               = 1'b0; // Initialize to be inactive
    tb_lc               = 1'b0; // Initialize to be inactive
    tb_overflow         = 1'b0; // Initialize to be inactive
    reset_dut();

    // DUT in idle state (0)

    // Initialize expected values
    reset_expected();

    // Assert dr to transition to state 1
    @(negedge tb_clk);
    tb_dr = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b010;
    tb_expected_dest = 4'b0101;
    check_outputs("after transition to state 1 (Store sample)");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 2
    tb_dr = 1'b0;
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_cnt_up = 1'b1;
    tb_expected_op = 3'b101;
    check_outputs("after transition to state 2");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 3
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0001;
    tb_expected_src1 = 4'b0010;
    check_outputs("after transition to state 3");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 4
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0010;
    tb_expected_src1 = 4'b0011;
    check_outputs("after transition to state 4");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 5
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0011;
    tb_expected_src1 = 4'b0100;
    check_outputs("after transition to state 5");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 6
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b001;
    tb_expected_dest = 4'b0100;
    tb_expected_src1 = 4'b0101;
    check_outputs("after transition to state 6");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 7
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0001;
    tb_expected_src2 = 4'b0110;
    check_outputs("after transition to state 7");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 8
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b100;
    tb_expected_src2 = 4'b0110;
    check_outputs("after transition to state 8");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 9
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b110;
    tb_expected_dest = 4'b1010;
    tb_expected_src1 = 4'b0010;
    tb_expected_src2 = 4'b0111;
    check_outputs("after transition to state 9");
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 10
    reset_expected();
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b101;
    tb_expected_src2 = 4'b1010;
    check_outputs("after transition to state 10");

    // Now assert overflow
    tb_overflow = 1'b1;

    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 23
    reset_expected();
    tb_expected_err = 1'b1;
    check_outputs("after transition to state 23");

    // Deassert overflow
    tb_overflow = 1'b0;

    // DUT is now sitting in error idle state.  Should stay until dr = 1.
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    reset_expected();
    
    // Get back to normal cycle
    tb_dr = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 1
    reset_expected();
    tb_dr = 1'b0;
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b010;
    tb_expected_dest = 4'b10101;
    check_outputs("after transition back to state 1");

    // ************************************************************************
    // Test Case 5: Short DR Error
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Short DR Error";
    // Start out with inactive values and reset the DUT to isolate from prior tests
    tb_n_rst            = 1'b1; // Initialize to be inactive
    tb_dr               = 1'b0; // Initialize to be inactive
    tb_lc               = 1'b0; // Initialize to be inactive
    tb_overflow         = 1'b0; // Initialize to be inactive
    reset_dut();

    // DUT in idle state (0)

    // Initialize expected values
    reset_expected();

    // Assert dr to transition to state 1
    @(negedge tb_clk);
    tb_dr = 1'b1;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_expected_modwait = 1'b1;
    tb_expected_op = 3'b010;
    tb_expected_dest = 4'b0101;
    check_outputs("after transition to state 1 (Store sample)");

    // Now deassert dr for erroneously short DR (should cause error condition)
    tb_dr = 1'b0;
    @(posedge tb_clk);
    @(negedge tb_clk); // transitioned to state 23 (error)
    reset_expected();
    tb_expected_err = 1'b1;
    check_outputs("after transition to state 23");
  end
endmodule
  
