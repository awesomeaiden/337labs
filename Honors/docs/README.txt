A guide to the project files for the Honors design project lab in ECE 33700.

Team members contributing to this project were:
  Aiden Gonzalez

All files for this project can be found in:
~mg57/ece337/Honors

Source/
  ahb_convolver.sv - top level RTL code for the entire design
  ahb_slave.sv - code for AHB "Slave" Interface module
  coeff_reg.sv - code for Coefficient Register module
  conv_controller.sv - code for Convolution Controller module
  mult_add.sv - code for Multipliers / Adder Tree module
  res_fifo.sv - code for Result FIFO Buffer module
  samp_shift_reg.sv - code for Sample Shift Register module
  tb_ahb_convolver.sv - testbench code for top level module
  tb_ahb_slave.sv - testbench code for AHB "Slave" Interface module
  tb_coeff_reg.sv - testbench code for Coefficient Register module
  tb_conv_controller.sv - testbench code for Convolution Controller module
  tb_mult_add.sv - testbench code for Multipliers / Adder Tree module
  tb_res_fifo.sv - testbench code for Result FIFO Buffer module
  tb_samp_shift_reg.sv - testbench code for Sample Shift Register module

Reports/
  ahb_convolver.rep - synthesis report file for top level
