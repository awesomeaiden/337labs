onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_ahb_lite_fir_filter/tb_test_case
add wave -noupdate -color Gold -radix unsigned /tb_ahb_lite_fir_filter/tb_test_case_num
add wave -noupdate -color Gold /tb_ahb_lite_fir_filter/tb_test_data
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_clk
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_n_rst
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_hsel
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_htrans
add wave -noupdate -color White -radix hexadecimal /tb_ahb_lite_fir_filter/tb_haddr
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_hsize
add wave -noupdate -color White /tb_ahb_lite_fir_filter/tb_hwrite
add wave -noupdate -color White -radix unsigned /tb_ahb_lite_fir_filter/tb_hwdata
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -color Turquoise -radix unsigned /tb_ahb_lite_fir_filter/tb_hrdata
add wave -noupdate -color Turquoise /tb_ahb_lite_fir_filter/tb_hresp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 293
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
WaveRestoreZoom {0 ps} {904 ps}
