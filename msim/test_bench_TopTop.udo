add wave -noupdate -group sim        /march_controller_tb/CLK
add wave -noupdate -group sim        /march_controller_tb/NRST
add wave -noupdate -group sim        /march_controller_tb/RDY_BUTTON
add wave -noupdate -group sim        /march_controller_tb/FLAG_BUTTON
add wave -noupdate -group sim        /march_controller_tb/ADDR_ERR
add wave -noupdate -group sim        /march_controller_tb/VALUE_ERR
add wave -noupdate -group sim        /march_controller_tb/VALUE_EXP

add wave -noupdate                   /march_controller_tb/ADR_IN
add wave -noupdate                   /march_controller_tb/BDR_IN
add wave -noupdate                   /march_controller_tb/DIN
add wave -noupdate                   /march_controller_tb/RE_IN
add wave -noupdate                   /march_controller_tb/WE_IN

add wave -noupdate                   /march_controller_tb/ADR_OUT
add wave -noupdate                   /march_controller_tb/BDR_OUT
add wave -noupdate                   /march_controller_tb/DOUT
add wave -noupdate                   /march_controller_tb/WE_OUT
add wave -noupdate                   /march_controller_tb/RDY
add wave -noupdate                   /march_controller_tb/CKE
add wave -noupdate                   /march_controller_tb/CS
add wave -noupdate                   /march_controller_tb/RAS
add wave -noupdate                   /march_controller_tb/CAS
add wave -noupdate                   /march_controller_tb/DQ

add wave -noupdate                   /march_controller_tb/top_inst/memory_contoller_inst/counter
add wave -noupdate                   /march_controller_tb/top_inst/memory_contoller_inst/counter_db
add wave -noupdate                   /march_controller_tb/top_inst/memory_contoller_inst/next_state
add wave -noupdate                   /march_controller_tb/top_inst/memory_contoller_inst/state
add wave -noupdate                   /march_controller_tb/top_inst/memory_contoller_inst/WE_RE_flag

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
