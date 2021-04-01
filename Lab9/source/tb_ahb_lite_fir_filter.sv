// $Id: $
// File name:   tb_ahb_lite_fir_filter.sv
// Created:     10/1/2018
// Author:      Tim Pritchett
// Lab Section: 9999
// Version:     1.0  Initial Design Entry
// Description: Starter bus model based test bench for the AHB-Lite-slave module (adapted for full design)

`timescale 1ns / 10ps

module tb_ahb_lite_fir_filter();

// Timing related constants
localparam CLK_PERIOD = 10;
localparam BUS_DELAY  = 800ps; // Based on FF propagation delay

// Sizing related constants
localparam DATA_WIDTH      = 2;
localparam ADDR_WIDTH      = 4;
localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;

// Define our address mapping scheme via constants
localparam ADDR_STATUS      = 4'd0;
localparam ADDR_STATUS_BUSY = 4'd0;
localparam ADDR_STATUS_ERR  = 4'd1;
localparam ADDR_RESULT      = 4'd2;
localparam ADDR_SAMPLE      = 4'd4;
localparam ADDR_COEF_START  = 4'd6;  // F0
localparam ADDR_COEF_SET    = 4'd14; // Coeff Set Confirmation

// AHB-Lite-Slave reset value constants
// Student TODO: Update these based on the reset values for your config registers
localparam RESET_COEFF  = '0;
localparam RESET_SAMPLE = '0;

// Coefficients from Lab 7
localparam COEFF1 		= 16'h8000; // 1.0
localparam COEFF_5 		= 16'h4000; // 0.5
localparam COEFF_25 	= 16'h2000; // 0.25
localparam COEFF_125 	= 16'h1000; // 0.125
localparam COEFF0  		= 16'h0000; // 0.0

//*****************************************************************************
// Declare TB Signals (Bus Model Controls)
//*****************************************************************************
// Testing setup signals
logic                      tb_enqueue_transaction;
logic                      tb_transaction_write;
logic                      tb_transaction_fake;
logic [ADDR_MAX_BIT:0]     tb_transaction_addr;
logic [DATA_MAX_BIT:0]     tb_transaction_data;
logic                      tb_transaction_error;
logic [2:0]                tb_transaction_size;
// Testing control signal(s)
logic    tb_enable_transactions;
integer  tb_current_transaction_num;
logic    tb_current_transaction_error;
logic    tb_model_reset;
string   tb_test_case;
integer  tb_test_case_num;
logic [DATA_MAX_BIT:0] tb_test_data;

//*****************************************************************************
// General System signals
//*****************************************************************************
logic tb_clk;
logic tb_n_rst;

//*****************************************************************************
// AHB-Lite-Slave side signals
//*****************************************************************************
logic                  tb_hsel;
logic [1:0]            tb_htrans;
logic [ADDR_MAX_BIT:0] tb_haddr;
logic [2:0]            tb_hsize;
logic                  tb_hwrite;
logic [DATA_MAX_BIT:0] tb_hwdata;
logic [DATA_MAX_BIT:0] tb_hrdata;
logic                  tb_hresp;

//*****************************************************************************
// Clock Generation Block
//*****************************************************************************
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

//*****************************************************************************
// Bus Model Instance
//*****************************************************************************
ahb_lite_bus BFM (.clk(tb_clk),
                  // Testing setup signals
                  .enqueue_transaction(tb_enqueue_transaction),
                  .transaction_write(tb_transaction_write),
                  .transaction_fake(tb_transaction_fake),
                  .transaction_addr(tb_transaction_addr),
                  .transaction_data(tb_transaction_data),
                  .transaction_error(tb_transaction_error),
                  .transaction_size(tb_transaction_size),
                  // Testing controls
                  .model_reset(tb_model_reset),
                  .enable_transactions(tb_enable_transactions),
                  .current_transaction_num(tb_current_transaction_num),
                  .current_transaction_error(tb_current_transaction_error),
                  // AHB-Lite-Slave Side
                  .hsel(tb_hsel),
                  .htrans(tb_htrans),
                  .haddr(tb_haddr),
                  .hsize(tb_hsize),
                  .hwrite(tb_hwrite),
                  .hwdata(tb_hwdata),
                  .hrdata(tb_hrdata),
                  .hresp(tb_hresp));


//*****************************************************************************
// DUT Instance
//*****************************************************************************

ahb_lite_fir_filter DUT (.clk(tb_clk),
                    .n_rst(tb_n_rst),
                    .hsel(tb_hsel),
                    .haddr(tb_haddr),
                    .hsize(tb_hsize[0]),
                    .htrans(tb_htrans),
                    .hwrite(tb_hwrite),
                    .hwdata(tb_hwdata),
                    .hrdata(tb_hrdata),
                    .hresp(tb_hresp));

//*****************************************************************************
// DUT Related TB Tasks
//*****************************************************************************
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

// Task for loading coefficients
task load_coefficients;
  input logic [15:0] f0;
  input logic [15:0] f1;
  input logic [15:0] f2;
  input logic [15:0] f3;
  integer poll;
begin
  // Enque the needed writes
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, (ADDR_COEF_START), f0, 1'b0, 1'b1); // F0
  enqueue_transaction(1'b1, 1'b1, (ADDR_COEF_START + 2), f1, 1'b0, 1'b1); // F1
  enqueue_transaction(1'b1, 1'b1, (ADDR_COEF_START + 4), f2, 1'b0, 1'b1); // F2
  enqueue_transaction(1'b1, 1'b1, (ADDR_COEF_START + 6), f3, 1'b0, 1'b1); // F3
  // Run the transactions via the model
  execute_transactions(4);

  // Now load into FIR filter
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_COEF_SET, 8'b00000001, 1'b0, 1'b0);
  // Run the transactions via the model
  execute_transactions(1);

  // Keep polling status register until filter is idle again
  poll = 1;
  while (poll == 1) begin
    // for_dut, write_mode, address, data, expected_error, size
    enqueue_transaction(1'b1, 1'b0, ADDR_COEF_SET, 8'b00000001, 1'b0, 1'b0);
    // Run the transactions via the model
    execute_transactions(1);
    poll = tb_hrdata[0];

    // Wait to poll again
    @(posedge tb_clk);
    @(posedge tb_clk);
  end
end
endtask

// Task for polling stauts register
task poll_status;
  integer poll;
begin
  // Keep polling status register until filter is idle
  poll = 1;
  while (poll == 1) begin
    // for_dut, write_mode, address, data, expected_error, size
    enqueue_transaction(1'b1, 1'b0, ADDR_STATUS, 8'b00000001, 1'b0, 1'b0);
    // Run the transactions via the model
    execute_transactions(1);
    poll = tb_hrdata[0];

    // Wait to poll again
    @(posedge tb_clk);
    @(posedge tb_clk);
  end
end
endtask

// Task to cleanly and consistently check DUT output values
task check_outputs;
  input logic [15:0] tb_expected_hrdata;
  input logic tb_expected_hresp;
  input string check_tag;
begin

  if(tb_expected_hrdata == tb_hrdata) begin // Check passed
    $info("Correct 'hrdata' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    $error("Incorrect 'hrdata' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_hresp == tb_hresp) begin // Check passed
    $info("Correct 'hresp' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    $error("Incorrect 'hresp' output %s during %s test case", check_tag, tb_test_case);
  end
end
endtask

//*****************************************************************************
// Bus Model Usage Related TB Tasks
//*****************************************************************************
// Task to pulse the reset for the bus model
task reset_model;
begin
  tb_model_reset = 1'b1;
  #(0.1);
  tb_model_reset = 1'b0;
end
endtask

// Task to enqueue a new transaction
task enqueue_transaction;
  input logic for_dut;
  input logic write_mode;
  input logic [ADDR_MAX_BIT:0] address;
  input logic [DATA_MAX_BIT:0] data;
  input logic expected_error;
  input logic size;
begin
  // Make sure enqueue flag is low (will need a 0->1 pulse later)
  tb_enqueue_transaction = 1'b0;
  #0.1ns;

  // Setup info about transaction
  tb_transaction_fake  = ~for_dut;
  tb_transaction_write = write_mode;
  tb_transaction_addr  = address;
  tb_transaction_data  = data;
  tb_transaction_error = expected_error;
  tb_transaction_size  = {2'b00,size};

  // Pulse the enqueue flag
  tb_enqueue_transaction = 1'b1;
  #0.1ns;
  tb_enqueue_transaction = 1'b0;
end
endtask

// Task to wait for multiple transactions to happen
task execute_transactions;
  input integer num_transactions;
  integer wait_var;
begin
  // Activate the bus model
  tb_enable_transactions = 1'b1;
  @(posedge tb_clk);

  // Process the transactions (all but last one overlap 1 out of 2 cycles
  for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
    @(posedge tb_clk);
  end

  // Run out the last one (currently in data phase)
  @(posedge tb_clk);

  // Turn off the bus model
  @(negedge tb_clk);
  tb_enable_transactions = 1'b0;
end
endtask

//*****************************************************************************
//*****************************************************************************
// Main TB Process
//*****************************************************************************
//*****************************************************************************
initial begin
  // Initialize Test Case Navigation Signals
  tb_test_case       = "Initilization";
  tb_test_case_num   = -1;
  tb_test_data       = '0;
  // Initialize all of the directly controled DUT inputs
  tb_n_rst          = 1'b1;
  // Initialize all of the bus model control inputs
  tb_model_reset          = 1'b0;
  tb_enable_transactions  = 1'b0;
  tb_enqueue_transaction  = 1'b0;
  tb_transaction_write    = 1'b0;
  tb_transaction_fake     = 1'b0;
  tb_transaction_addr     = '0;
  tb_transaction_data     = '0;
  tb_transaction_error    = 1'b0;
  tb_transaction_size     = 3'd0;

  // Wait some time before starting first test case
  #(0.1);

  // Clear the bus model
  reset_model();

  //*****************************************************************************
  // Power-on-Reset Test Case
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Power-on-Reset";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT
  reset_dut();

  // Check outputs for reset state
  check_outputs(16'd0, 1'b0, "after reset");

  // Give some visual spacing between check and next test case start
  #(CLK_PERIOD * 3);

  //*****************************************************************************
  // Test Case 2: Full Operation
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Full Operation";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // 1 Configure FIR Coefficients
  load_coefficients(COEFF_5, COEFF1, COEFF1, COEFF_5);

  // 2 Send the sample data to process
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_SAMPLE, 16'd100, 1'b0, 1'b1);
  // Run the transactions via the model
  execute_transactions(1);

  // 3 Poll the status register until new data is present
  poll_status();

  // 4 Read the data from the result buffer
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b0, ADDR_RESULT, 16'd50, 1'b0, 1'b1);
  // Run the transactions via the model
  execute_transactions(1);

  // Repeat steps 2-4 until done with sample data to process with the current FIR coefficients

  // Give some visual spacing between check and next test case start
  #(CLK_PERIOD * 3);

  // End of test cases
end

endmodule
