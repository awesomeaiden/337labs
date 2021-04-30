onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_conv_controller/tb_test_num
add wave -noupdate -color Gold /tb_conv_controller/tb_test_case
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_conv_controller/tb_clk
add wave -noupdate -color White /tb_conv_controller/tb_n_rst
add wave -noupdate -color White /tb_conv_controller/tb_sample_load_en
add wave -noupdate -color White /tb_conv_controller/tb_new_row
add wave -noupdate -color White /tb_conv_controller/tb_coeff_load_en
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -expand -group modwait -color Cyan /tb_conv_controller/tb_modwait
add wave -noupdate -expand -group modwait -color Cyan /tb_conv_controller/tb_expected_modwait
add wave -noupdate -expand -group sample_stream -color Cyan /tb_conv_controller/tb_sample_stream
add wave -noupdate -expand -group sample_stream -color Cyan /tb_conv_controller/tb_expected_sample_stream
add wave -noupdate -expand -group sample_shift -color Cyan /tb_conv_controller/tb_sample_shift
add wave -noupdate -expand -group sample_shift -color Cyan /tb_conv_controller/tb_expected_sample_shift
add wave -noupdate -expand -group convolve_en -color Cyan /tb_conv_controller/tb_convolve_en
add wave -noupdate -expand -group convolve_en -color Cyan /tb_conv_controller/tb_expected_convolve_en
add wave -noupdate -expand -group coeff_ld -color Cyan /tb_conv_controller/tb_coeff_ld
add wave -noupdate -expand -group coeff_ld -color Cyan /tb_conv_controller/tb_expected_coeff_ld
add wave -noupdate -expand -group coeff_sel -color Cyan /tb_conv_controller/tb_coeff_sel
add wave -noupdate -expand -group coeff_sel -color Cyan /tb_conv_controller/tb_expected_coeff_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16284 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {0 ps} {105 ns}
