onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_controller/tb_test_num
add wave -noupdate -color Gold /tb_controller/tb_test_case
add wave -noupdate -divider {DUT Signals}
add wave -noupdate -divider Inputs
add wave -noupdate -color White /tb_controller/tb_clk
add wave -noupdate -color White /tb_controller/tb_n_rst
add wave -noupdate -color White /tb_controller/tb_dr
add wave -noupdate -color White /tb_controller/tb_lc
add wave -noupdate -color White /tb_controller/tb_overflow
add wave -noupdate -divider Outputs
add wave -noupdate -color Pink -radix unsigned -childformat {{{/tb_controller/tb_state_out[4]} -radix unsigned} {{/tb_controller/tb_state_out[3]} -radix unsigned} {{/tb_controller/tb_state_out[2]} -radix unsigned} {{/tb_controller/tb_state_out[1]} -radix unsigned} {{/tb_controller/tb_state_out[0]} -radix unsigned}} -subitemconfig {{/tb_controller/tb_state_out[4]} {-color Pink -radix unsigned} {/tb_controller/tb_state_out[3]} {-color Pink -radix unsigned} {/tb_controller/tb_state_out[2]} {-color Pink -radix unsigned} {/tb_controller/tb_state_out[1]} {-color Pink -radix unsigned} {/tb_controller/tb_state_out[0]} {-color Pink -radix unsigned}} /tb_controller/tb_state_out
add wave -noupdate -expand -group cnt_up -color {Medium Orchid} /tb_controller/tb_cnt_up
add wave -noupdate -expand -group cnt_up -color Cyan /tb_controller/tb_expected_cnt_up
add wave -noupdate -expand -group clear -color {Medium Orchid} /tb_controller/tb_clear
add wave -noupdate -expand -group clear -color Cyan /tb_controller/tb_expected_clear
add wave -noupdate -expand -group modwait -color {Medium Orchid} /tb_controller/tb_modwait
add wave -noupdate -expand -group modwait -color Cyan /tb_controller/tb_expected_modwait
add wave -noupdate -expand -group op -color {Medium Orchid} /tb_controller/tb_op
add wave -noupdate -expand -group op -color Cyan /tb_controller/tb_expected_op
add wave -noupdate -expand -group src1 -color {Medium Orchid} -radix unsigned /tb_controller/tb_src1
add wave -noupdate -expand -group src1 -color Cyan -radix unsigned /tb_controller/tb_expected_src1
add wave -noupdate -expand -group src2 -color {Medium Orchid} -radix unsigned /tb_controller/tb_src2
add wave -noupdate -expand -group src2 -color Cyan -radix unsigned /tb_controller/tb_expected_src2
add wave -noupdate -expand -group dest -color {Medium Orchid} -radix unsigned /tb_controller/tb_dest
add wave -noupdate -expand -group dest -color Cyan -radix unsigned /tb_controller/tb_expected_dest
add wave -noupdate -expand -group err -color {Medium Orchid} /tb_controller/tb_err
add wave -noupdate -expand -group err -color Cyan -radix unsigned /tb_controller/tb_expected_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {273590 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
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
