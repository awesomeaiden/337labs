onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_samp_shift_reg/tb_test_num
add wave -noupdate -color Gold /tb_samp_shift_reg/tb_test_case
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_samp_shift_reg/tb_clk
add wave -noupdate -color White /tb_samp_shift_reg/tb_n_rst
add wave -noupdate -color White /tb_samp_shift_reg/tb_shift_en
add wave -noupdate -color White /tb_samp_shift_reg/tb_col_in
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -expand -group sample_out -color Cyan /tb_samp_shift_reg/tb_sample_out
add wave -noupdate -expand -group sample_out -color Cyan /tb_samp_shift_reg/tb_expected_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {130227 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
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
