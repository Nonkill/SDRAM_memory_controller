add wave -noupdate -format Logic /CLK
add wave -noupdate -format Logic /NRST

add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/ADR_OUT
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/BDR_OUT
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/DOUT
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/CKE
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/CS
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/RAS
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/CAS
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/WE_OUT
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/RDY
add wave -group SIGNALS_OUT -noupdate -format binary  /memory_contoller_inst/DQ
add wave -group SIGNALS_IN  -noupdate -format binary  /memory_contoller_inst/ADR_IN
add wave -group SIGNALS_IN  -noupdate -format binary  /memory_contoller_inst/BDR_IN
add wave -group SIGNALS_IN  -noupdate -format binary  /memory_contoller_inst/WE_IN
add wave -group SIGNALS_IN  -noupdate -format binary  /memory_contoller_inst/RE_IN
add wave -group SIGNALS_IN  -noupdate -format binary  /memory_contoller_inst/DIN
add wave -group CHECK_STATE   -noupdate -format binary  /memory_contoller_inst/state
add wave -group CHECK_STATE   -noupdate -format binary  /memory_contoller_inst/next_state
add wave -group COUNTERS      -noupdate -format decimal /memory_contoller_inst/counter
add wave -group COUNTERS      -noupdate -format decimal /memory_contoller_inst/counter_db
add wave -noupdate -format decimal memory_controller_tb/addr_row
add wave -noupdate -format decimal memory_controller_tb/addr_collumn

add wave -group MEMORY -noupdate -format binary  /memory_inst/Dq


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
