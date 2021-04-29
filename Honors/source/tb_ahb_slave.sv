// $Id: $
// File name:   tb_ahb_slave.sv
// Created:     4/28/2021
// Author:      Aiden Gonzalez
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Testbench for AHB Slave for AHB Convovler

`timescale 1ns / 10ps

module tb_ahb_slave();

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
localparam ADDR_RESULT      = 4'd2;
localparam ADDR_SAMPLE      = 4'd4;
localparam ADDR_COEFF_ONE  = 4'd6;  // R0
localparam ADDR_COEFF_TWO  = 4'd8;  // R1
localparam ADDR_COEFF_THREE  = 4'd10;  // R3
localparam ADDR_COMMAND    = 4'd12; // Command/Control

// AHB-Lite-Slave reset value constants
localparam RESET_COEFF  = '0;
localparam RESET_SAMPLE = '0;

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
string                 tb_check_tag;
logic                  tb_mismatch;
logic                  tb_check;

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
// Convolver-side Signals
//*****************************************************************************
// Inputs
logic tb_modwait;
logic tb_sample_stream;
logic [1:0] tb_coeff_sel;
logic tb_empty;
logic [15:0] tb_result_in;

// Outputs
logic [15:0] tb_col_out;
logic tb_sample_load_en;
logic tb_new_row;
logic tb_coeff_load_en;
logic [15:0] tb_coeff_out;
logic tb_read_enable;

// Expected value check signals
logic [15:0] tb_expected_col_out;
logic tb_expected_sample_load_en;
logic tb_expected_new_row;
logic tb_expected_coeff_load_en;
logic [15:0] tb_expected_coeff_out;
logic tb_expected_read_enable;

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
ahb_slave DUT (.clk(tb_clk), .n_rst(tb_n_rst),
                    .hsel(tb_hsel),
                    .haddr(tb_haddr),
                    .htrans(tb_htrans),
                    .hsize(tb_hsize[0]),
                    .hwrite(tb_hwrite),
                    .hwdata(tb_hwdata),
                    .modwait(tb_modwait),
                    .sample_stream(tb_sample_stream),
                    .coeff_sel(tb_coeff_sel),
                    .empty(tb_empty),
                    .result_in(tb_result_in),
                    .col_out(tb_col_out),
                    .sample_load_en(tb_sample_load_en),
                    .new_row(tb_new_row),
                    .coeff_load_en(tb_coeff_load_en),
                    .coeff_out(tb_coeff_out),
                    .read_enable(tb_read_enable),
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

// Task to cleanly and consistently check DUT output values
task check_outputs;
  input string check_tag;
begin
  tb_mismatch = 1'b0;
  tb_check    = 1'b1;

  if(tb_expected_col_out == tb_col_out) begin // Check passed
    $info("Correct 'col_out' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'col_out' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_sample_load_en == tb_sample_load_en) begin // Check passed
    $info("Correct 'sample_load_en' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'sample_load_en' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_new_row == tb_new_row) begin // Check passed
    $info("Correct 'new_row' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'new_row' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_coeff_load_en == tb_coeff_load_en) begin // Check passed
    $info("Correct 'coeff_load_en' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'coeff_load_en' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_coeff_out == tb_coeff_out) begin // Check passed
    $info("Correct 'coeff_out' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'coeff_out' output %s during %s test case", check_tag, tb_test_case);
  end

  if(tb_expected_read_enable == tb_read_enable) begin // Check passed
    $info("Correct 'read_enable' output %s during %s test case", check_tag, tb_test_case);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'read_enable' output %s during %s test case", check_tag, tb_test_case);
  end

  // Wait some small amount of time so check pulse timing is visible on waves
  #(0.1);
  tb_check =1'b0;
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

// Task to clear/initialize all FIR-side inputs
task init_input;
begin
  tb_n_rst = 1'b1;
  tb_modwait = 1'b0;
  tb_sample_stream = 1'b0;
  tb_coeff_sel = 2'b00;
  tb_empty = 1'b1;
  tb_result_in = 16'd0;
end
endtask

// Task to clear/initialize all FIR-side inputs
task init_expected;
begin
  tb_expected_col_out = 16'd0;
  tb_expected_sample_load_en = 1'b0;
  tb_expected_new_row = 1'b0;
  tb_expected_coeff_load_en = 1'b0;
  tb_expected_coeff_out = 16'd0;
  tb_expected_read_enable = 1'b0;
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
  tb_check_tag       = "N/A";
  tb_check           = 1'b0;
  tb_mismatch        = 1'b0;
  // Initialize all of the directly controled DUT inputs
  tb_n_rst          = 1'b1;
  init_input();
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
  // Test Case 1: Power-on-Reset Test Case
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Power-on-Reset";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT
  reset_dut();

  // Check outputs for reset state
  init_expected();
  check_outputs("after DUT reset");

  //*****************************************************************************
  // Test Case 2: Status Write/Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Status Write/Read";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  init_input();
  init_expected();
  reset_dut();

  // Assert modwait, empty, and stream
  tb_modwait = 1'b1;
  tb_empty = 1'b1;
  tb_sample_stream = 1'b1;

  // Enqueue the needed transactions (Write (error) then read)
  tb_test_data = 16'd1000;
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_STATUS, tb_test_data, 1'b1, 1'b1);
  enqueue_transaction(1'b1, 1'd0, ADDR_STATUS, 16'b0000000110000001, 1'b0, 1'b1);

  // Run the transactions via the model
  execute_transactions(1);

  // Wait a bit... not testing RAW
  @(posedge tb_clk);
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Run the transactions via the model
  execute_transactions(1);

  //*****************************************************************************
  // Test Case 3: FIFO Result Write/Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "FIFO Result Write/Read";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT to isolate from prior test case
  init_input();
  init_expected();
  reset_dut();

  // Assert result_in
  tb_result_in = 16'd1234;

  // Enqueue the needed transactions (Write (error) then read)
  tb_test_data = 16'd1000;
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_RESULT, tb_test_data, 1'b1, 1'b1);
  enqueue_transaction(1'b1, 1'b0, ADDR_RESULT, 16'd1234, 1'b0, 1'b1);

  // Run the transactions via the model
  execute_transactions(1);

  // Wait a bit... not testing RAW
  @(posedge tb_clk);
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Run the transactions via the model
  execute_transactions(1);

  // ENSURE READ_ENABLE IS PROPERLY PULSED DURING ADDRESS PHASE

  // Check the DUT outputs
  check_outputs("after attempting to read result");

  // Give some visual spacing between check and next test case start
  #(CLK_PERIOD * 3);

  //*****************************************************************************
  // Test Case 4: Sample Write/Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Sample Write/Read";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT to isolate from prior test case
  init_input();
  init_expected();
  reset_dut();

  // Enqueue the needed transactions
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_SAMPLE, 16'd1234, 1'b0, 1'b1);
  enqueue_transaction(1'b1, 1'b0, ADDR_SAMPLE, 16'd1234, 1'b0, 1'b1);
  
  // Run the transactions via the model
  execute_transactions(1);

  // Wait a bit... not testing RAW
  @(posedge tb_clk);
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Run the transactions via the model
  execute_transactions(1);

  //*****************************************************************************
  // Test Case 5: Coefficients Write/Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Coefficients Write/Read";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT to isolate from prior test case
  init_input();
  init_expected();
  reset_dut();

  // Enqueue the writes
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_COEFF_ONE, 16'd1, 1'b0, 1'b1);
  enqueue_transaction(1'b1, 1'b1, ADDR_COEFF_TWO, 16'd2, 1'b0, 1'b1);
  enqueue_transaction(1'b1, 1'b1, ADDR_COEFF_THREE, 16'd3, 1'b0, 1'b1);
  // Run the transactions via the model
  execute_transactions(3);

  // Wait a bit... not testing RAW
  @(posedge tb_clk);
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Enqueue the reads
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b0, ADDR_COEFF_ONE, 16'd1, 1'b0, 1'b1);
  enqueue_transaction(1'b1, 1'b0, ADDR_COEFF_TWO, 16'd2, 1'b0, 1'b1);
  enqueue_transaction(1'b1, 1'b0, ADDR_COEFF_THREE, 16'd3, 1'b0, 1'b1);
  // Run the transactions via the model
  execute_transactions(3);

  // Now check coeff_sel
  @(negedge tb_clk);
  tb_coeff_sel = 2'b00;
  @(negedge tb_clk);
  tb_expected_coeff_out = 16'd1;
  check_outputs("after selecting coeff one");
  tb_coeff_sel = 2'b01;
  @(negedge tb_clk);
  tb_expected_coeff_out = 16'd2;
  check_outputs("after selecting coeff two");
  tb_coeff_sel = 2'b10;
  @(negedge tb_clk);
  tb_expected_coeff_out = 16'd3;
  check_outputs("after selecting coeff three");

  //*****************************************************************************
  // Test Case 6: Command Write/Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Command Write/Read";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT to isolate from prior test case
  init_input();
  init_expected();
  reset_dut();

  // Enqueue the write
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b1, ADDR_COMMAND, 8'b00000111, 1'b0, 1'b0);
  // Run the transactions via the model
  execute_transactions(1);

  // ENSURE COEFF_LOAD_EN, SAMPLE_LOAD_EN, AND NEW_ROW ARE PROPERLY PULSED

  // Wait a bit... not testing RAW
  @(posedge tb_clk);
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Enqueue the read
  // for_dut, write_mode, address, data, expected_error, size
  enqueue_transaction(1'b1, 1'b0, ADDR_COMMAND, 8'b00000000, 1'b0, 1'b0);
  // Run the transactions via the model
  execute_transactions(1);

  // End of test cases
end

endmodule
