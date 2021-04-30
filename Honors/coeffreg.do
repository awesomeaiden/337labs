onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_coeff_reg/tb_test_num
add wave -noupdate -color Gold /tb_coeff_reg/tb_test_case
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_coeff_reg/tb_clk
add wave -noupdate -color White /tb_coeff_reg/tb_n_rst
add wave -noupdate -color White /tb_coeff_reg/tb_coeff_ld
add wave -noupdate -color White /tb_coeff_reg/tb_coeff_in
add wave -noupdate -color White /tb_coeff_reg/tb_coeff_sel
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -color Cyan /tb_coeff_reg/tb_coeff_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1 ns}
