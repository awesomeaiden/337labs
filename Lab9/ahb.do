onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_ahb_lite_slave/tb_test_case
add wave -noupdate -color Gold /tb_ahb_lite_slave/tb_test_case_num
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_ahb_lite_slave/tb_clk
add wave -noupdate -color White /tb_ahb_lite_slave/tb_n_rst
add wave -noupdate -color White /tb_ahb_lite_slave/tb_coeff_num
add wave -noupdate -color White /tb_ahb_lite_slave/tb_clear_new_coeff
add wave -noupdate -color White /tb_ahb_lite_slave/tb_modwait
add wave -noupdate -color White /tb_ahb_lite_slave/tb_fir_out
add wave -noupdate -color White /tb_ahb_lite_slave/tb_err
add wave -noupdate -color White /tb_ahb_lite_slave/tb_hsel
add wave -noupdate -color White /tb_ahb_lite_slave/tb_haddr
add wave -noupdate -color White /tb_ahb_lite_slave/tb_hsize
add wave -noupdate -color White /tb_ahb_lite_slave/tb_htrans
add wave -noupdate -color White /tb_ahb_lite_slave/tb_hwrite
add wave -noupdate -color White /tb_ahb_lite_slave/tb_hwdata
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -expand -group sample_data -color Turquoise /tb_ahb_lite_slave/tb_sample_data
add wave -noupdate -expand -group sample_data -color {Dark Orchid} /tb_ahb_lite_slave/tb_expected_sample
add wave -noupdate -expand -group data_ready -color Turquoise /tb_ahb_lite_slave/tb_data_ready
add wave -noupdate -expand -group data_ready -color {Dark Orchid} /tb_ahb_lite_slave/tb_expected_data_ready
add wave -noupdate -expand -group new_coeff_set -color Turquoise /tb_ahb_lite_slave/tb_new_coeff_set
add wave -noupdate -expand -group new_coeff_set -color {Dark Orchid} /tb_ahb_lite_slave/tb_expected_new_coeff_set
add wave -noupdate -expand -group fir_coefficient -color Turquoise /tb_ahb_lite_slave/tb_fir_coefficient
add wave -noupdate -expand -group fir_coefficient -color {Dark Orchid} /tb_ahb_lite_slave/tb_expected_coeff
add wave -noupdate -color Turquoise /tb_ahb_lite_slave/tb_hrdata
add wave -noupdate -color Turquoise /tb_ahb_lite_slave/tb_hresp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {100461 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 317
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {131250 ps}
