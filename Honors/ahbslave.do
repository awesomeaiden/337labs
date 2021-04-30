onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_ahb_slave/tb_test_case
add wave -noupdate -color Gold /tb_ahb_slave/tb_test_case_num
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_ahb_slave/tb_clk
add wave -noupdate -color White /tb_ahb_slave/tb_n_rst
add wave -noupdate -color White /tb_ahb_slave/tb_hsel
add wave -noupdate -color White /tb_ahb_slave/tb_htrans
add wave -noupdate -color White -radix hexadecimal /tb_ahb_slave/tb_haddr
add wave -noupdate -color White /tb_ahb_slave/tb_hsize
add wave -noupdate -color White /tb_ahb_slave/tb_hwrite
add wave -noupdate -color White /tb_ahb_slave/tb_hwdata
add wave -noupdate -color White /tb_ahb_slave/tb_modwait
add wave -noupdate -color White /tb_ahb_slave/tb_sample_stream
add wave -noupdate -color White /tb_ahb_slave/tb_coeff_sel
add wave -noupdate -color White /tb_ahb_slave/tb_empty
add wave -noupdate -color White /tb_ahb_slave/tb_result_in
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -color Cyan /tb_ahb_slave/tb_hrdata
add wave -noupdate -color Cyan /tb_ahb_slave/tb_hresp
add wave -noupdate -expand -group col_out -color Cyan /tb_ahb_slave/tb_col_out
add wave -noupdate -expand -group col_out -color Cyan /tb_ahb_slave/tb_expected_col_out
add wave -noupdate -expand -group sample_load_en -color Cyan /tb_ahb_slave/tb_sample_load_en
add wave -noupdate -expand -group sample_load_en -color Cyan /tb_ahb_slave/tb_expected_sample_load_en
add wave -noupdate -expand -group new_row -color Cyan /tb_ahb_slave/tb_new_row
add wave -noupdate -expand -group new_row -color Cyan /tb_ahb_slave/tb_expected_new_row
add wave -noupdate -expand -group coeff_load_en -color Cyan /tb_ahb_slave/tb_coeff_load_en
add wave -noupdate -expand -group coeff_load_en -color Cyan /tb_ahb_slave/tb_expected_coeff_load_en
add wave -noupdate -expand -group coeff_out -color Cyan /tb_ahb_slave/tb_coeff_out
add wave -noupdate -expand -group coeff_out -color Cyan /tb_ahb_slave/tb_expected_coeff_out
add wave -noupdate -expand -group read_enable -color Cyan /tb_ahb_slave/tb_read_enable
add wave -noupdate -expand -group read_enable -color Cyan /tb_ahb_slave/tb_expected_read_enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {437371 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 292
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1050 ns}
