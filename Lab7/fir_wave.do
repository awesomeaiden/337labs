onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -color Gold /tb_fir_filter/tb_test_case_num
add wave -noupdate -color Gold /tb_fir_filter/tb_test_sample_num
add wave -noupdate -color Gold /tb_fir_filter/tb_std_test_case
add wave -noupdate -divider {DUT Inputs}
add wave -noupdate -color White /tb_fir_filter/tb_clk
add wave -noupdate -color White /tb_fir_filter/tb_n_reset
add wave -noupdate -color White /tb_fir_filter/tb_data_ready
add wave -noupdate -color White /tb_fir_filter/tb_load_coeff
add wave -noupdate -color White -radix unsigned /tb_fir_filter/tb_sample
add wave -noupdate -color White -radix binary /tb_fir_filter/tb_coeff
add wave -noupdate -divider {DUT Outputs}
add wave -noupdate -color {Medium Orchid} /tb_fir_filter/tb_modwait
add wave -noupdate -expand -group fir_out -color {Medium Orchid} -radix unsigned /tb_fir_filter/tb_fir_out
add wave -noupdate -expand -group fir_out -color Blue -radix unsigned /tb_fir_filter/tb_expected_fir_out
add wave -noupdate -expand -group err -color {Medium Orchid} /tb_fir_filter/tb_err
add wave -noupdate -expand -group err -color Blue /tb_fir_filter/tb_expected_err
add wave -noupdate -expand -group one_k_samples -color {Medium Orchid} /tb_fir_filter/tb_one_k_samples
add wave -noupdate -expand -group one_k_samples -color Blue /tb_fir_filter/tb_expected_one_k_samples
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {304878 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 282
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
WaveRestoreZoom {290502 ps} {372534 ps}
