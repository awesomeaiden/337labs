onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_apb_slave/tb_test_case
add wave -noupdate -color Gold -radix unsigned /tb_apb_slave/tb_test_case_num
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color Cyan /tb_apb_slave/tb_clk
add wave -noupdate -color Cyan /tb_apb_slave/tb_n_rst
add wave -noupdate -color Cyan /tb_apb_slave/tb_rx_data
add wave -noupdate -color Cyan /tb_apb_slave/tb_data_ready
add wave -noupdate -color Cyan /tb_apb_slave/tb_overrun_error
add wave -noupdate -color Cyan /tb_apb_slave/tb_framing_error
add wave -noupdate -color Cyan /tb_apb_slave/tb_psel
add wave -noupdate -color Cyan /tb_apb_slave/tb_paddr
add wave -noupdate -color Cyan /tb_apb_slave/tb_penable
add wave -noupdate -color Cyan /tb_apb_slave/tb_pwrite
add wave -noupdate -color Cyan /tb_apb_slave/tb_pwdata
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -expand -group data_read -color Aquamarine /tb_apb_slave/tb_data_read
add wave -noupdate -expand -group data_read -color {Dark Orchid} /tb_apb_slave/tb_expected_data_read
add wave -noupdate -color Aquamarine /tb_apb_slave/tb_prdata
add wave -noupdate -color Aquamarine /tb_apb_slave/tb_pslverr
add wave -noupdate -expand -group data_size -color Aquamarine /tb_apb_slave/tb_data_size
add wave -noupdate -expand -group data_size -color {Dark Orchid} /tb_apb_slave/tb_expected_data_size
add wave -noupdate -expand -group bit_period -color Aquamarine /tb_apb_slave/tb_bit_period
add wave -noupdate -expand -group bit_period -color {Dark Orchid} /tb_apb_slave/tb_expected_bit_period
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 246
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
WaveRestoreZoom {0 ps} {908 ps}
