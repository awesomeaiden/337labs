onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -color Gold /tb_ahb_convolver/tb_test_case
add wave -noupdate -color Gold /tb_ahb_convolver/tb_test_case_num
add wave -noupdate -divider {Top Level Signals}
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_clk
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_n_rst
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_hsel
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_htrans
add wave -noupdate -color Cyan -radix hexadecimal /tb_ahb_convolver/tb_haddr
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_hsize
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_hwrite
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_hwdata
add wave -noupdate -color Cyan -radix binary /tb_ahb_convolver/tb_hrdata
add wave -noupdate -color Cyan /tb_ahb_convolver/tb_hresp
add wave -noupdate -divider {AHB "Slave"}
add wave -noupdate -color White -childformat {{{/tb_ahb_convolver/DUT/AHB/array[11]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[10]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[9]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[8]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[7]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[6]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[5]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[4]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/AHB/array[3]} -radix unsigned} {{/tb_ahb_convolver/DUT/AHB/array[2]} -radix unsigned}} -expand -subitemconfig {{/tb_ahb_convolver/DUT/AHB/array[12]} {-color White -height 16} {/tb_ahb_convolver/DUT/AHB/array[11]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[10]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[9]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[8]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[7]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[6]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[5]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[4]} {-color White -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/AHB/array[3]} {-color White -height 16 -radix unsigned} {/tb_ahb_convolver/DUT/AHB/array[2]} {-color White -height 16 -radix unsigned} {/tb_ahb_convolver/DUT/AHB/array[1]} {-color White -height 16} {/tb_ahb_convolver/DUT/AHB/array[0]} {-color White -height 16}} /tb_ahb_convolver/DUT/AHB/array
add wave -noupdate -divider Multiplier/Adder
add wave -noupdate -color Magenta -radix hexadecimal /tb_ahb_convolver/DUT/MULTADD/coeff_in
add wave -noupdate -color Magenta -radix hexadecimal /tb_ahb_convolver/DUT/MULTADD/sample_in
add wave -noupdate -color Magenta -radix unsigned /tb_ahb_convolver/DUT/MULTADD/result
add wave -noupdate -color Magenta /tb_ahb_convolver/DUT/CTRL/convolve_en
add wave -noupdate -color Magenta /tb_ahb_convolver/DUT/MULTADD/result_ready
add wave -noupdate -divider Controller
add wave -noupdate -color {Cadet Blue} /tb_ahb_convolver/DUT/CTRL/state
add wave -noupdate -divider {Sample Shift Register}
add wave -noupdate -color Pink /tb_ahb_convolver/DUT/CTRL/sample_shift
add wave -noupdate -color Pink -childformat {{{/tb_ahb_convolver/DUT/SAMP/state[2]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/SAMP/state[1]} -radix hexadecimal} {{/tb_ahb_convolver/DUT/SAMP/state[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb_ahb_convolver/DUT/SAMP/state[2]} {-color Pink -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/SAMP/state[1]} {-color Pink -height 16 -radix hexadecimal} {/tb_ahb_convolver/DUT/SAMP/state[0]} {-color Pink -height 16 -radix hexadecimal}} /tb_ahb_convolver/DUT/SAMP/state
add wave -noupdate -divider FIFO
add wave -noupdate -color Red /tb_ahb_convolver/DUT/FIFO/wenable
add wave -noupdate -color Red /tb_ahb_convolver/DUT/FIFO/renable
add wave -noupdate -color Red -radix unsigned /tb_ahb_convolver/DUT/FIFO/result_in
add wave -noupdate -color Red /tb_ahb_convolver/DUT/FIFO/empty
add wave -noupdate -color Red -radix unsigned /tb_ahb_convolver/DUT/FIFO/result_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {896633 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
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
WaveRestoreZoom {866971 ps} {952285 ps}
