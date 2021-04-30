onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_mult_add/tb_test_num
add wave -noupdate -color Gold /tb_mult_add/tb_test_case
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_mult_add/tb_clk
add wave -noupdate -color White /tb_mult_add/tb_n_rst
add wave -noupdate -color White /tb_mult_add/tb_sample_in
add wave -noupdate -color White /tb_mult_add/tb_coeff_in
add wave -noupdate -color White /tb_mult_add/tb_conv_en
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -color Cyan /tb_mult_add/tb_result
add wave -noupdate -color Cyan /tb_mult_add/tb_result_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 222
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
WaveRestoreZoom {0 ps} {952 ps}
