add wave -noupdate -format Logic /CLK
add wave -noupdate -format Logic /NRST

add wave -group CONTROL_SIGNALS -noupdate -format binary /memory_contoller_inst/CKE
add wave -group CONTROL_SIGNALS -noupdate -format binary /memory_contoller_inst/CS



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
