add wave -noupdate -group sim /march_tb/r_clk
add wave -noupdate -group sim /march_tb/r_nreset
add wave -noupdate -group sim /march_tb/r_mem_rdy
add wave -noupdate -group sim /march_tb/march_inst/w_en_r_rdy
add wave -noupdate -group sim /march_tb/march_inst/w_rdy

add wave -noupdate -color Yellow /march_tb/march_inst/r_do
add wave -noupdate -color Yellow /march_tb/r_di

add wave -noupdate -color Magenta /march_tb/march_inst/A
add wave -noupdate -color Yellow  /march_tb/march_inst/DO
add wave -noupdate -color Yellow  /march_tb/march_inst/DI
add wave -noupdate -color {Sky Blue} /march_tb/march_inst/WE
add wave -noupdate -color {Sky Blue} /march_tb/march_inst/RE
add wave -noupdate -color {Sky Blue} /march_tb/march_inst/RDY
add wave -noupdate -color {Sky Blue} /march_tb/march_inst/FLAG
add wave -noupdate /march_tb/march_inst/ADDR_ERR
add wave -noupdate /march_tb/march_inst/VALUE_ERR
add wave -noupdate /march_tb/march_inst/VALUE_EXP

add wave -noupdate /march_tb/march_inst/r_state
add wave -noupdate -Radix Decimal /march_tb/march_inst/r_iter
add wave -noupdate -color Magenta /march_tb/march_inst/r_counter
add wave -noupdate /march_tb/march_inst/w_en_r_addr
add wave -noupdate /march_tb/march_inst/w_sclr_r_addr

#TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 161
configure wave -valuecolwidth 150
#configure wave -justifyvalue left
configure wave -signalnamewidth 1

#configure wave -snapdistance 10
#configure wave -datasetprefix 0
#configure wave -rowmargin 4
#configure wave -childrowmargin 2
#configure wave -gridoffset 0
#configure wave -gridperiod 1
#configure wave -griddelta 40
#configure wave -timeline 0

configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}
