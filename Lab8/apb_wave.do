onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_apb_uart_rx/tb_test_case
add wave -noupdate -color Gold /tb_apb_uart_rx/tb_test_case_num
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_clk
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_n_rst
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_serial_in
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_psel
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_paddr
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_penable
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_pwrite
add wave -noupdate -color Turquoise /tb_apb_uart_rx/tb_pwdata
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -expand -group prdata -color Blue /tb_apb_uart_rx/tb_prdata
add wave -noupdate -expand -group prdata -color {Dark Orchid} /tb_apb_uart_rx/tb_expected_prdata
add wave -noupdate -expand -group pslverr -color Blue /tb_apb_uart_rx/tb_pslverr
add wave -noupdate -expand -group pslverr -color {Dark Orchid} /tb_apb_uart_rx/tb_expected_pslverr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3354405 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 266
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
WaveRestoreZoom {3251819 ps} {3514319 ps}
