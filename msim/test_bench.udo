add wave -noupdate -format Logic /r_clk
add wave -noupdate -format Logic /r_rst

 
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/r_ten
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/TCK
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/TMS
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/TDI
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/TRSTN
add wave -group External_Programmer -noupdate -format hexadecimal /cpu_system_inst/r_msg


add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/WORD
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/WORD_SELECT
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/CTRL
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/CTRL_SELECT
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/COUNTER_SELECT
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/FLAG
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/w_update_dr
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_data_i
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_data_o
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_ctrl
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_state
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_data_ct_a
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_ct_a
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_ct_clk
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_erase
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_chip
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_web
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_ceb
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_prog
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_prog2
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_BYTE
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_oeb
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_en_ct_clk
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/w_load_ct_clk
add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/w_sload_ct_clk
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/w_en_BYTE
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/w_en_BYTE_flag
#add wave -group ctrl_from_tap_to_flash -noupdate -format hexadecimal /mem_ctrl_top_inst/ctrl_from_tap_to_flash_inst/r_BYTE_flag


add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_current_state_fsm
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_next_state_fsm
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/i_en_mem_load

add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_dout
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_error
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_decoded

add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_re
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_word
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_d_ram0
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_d_ram1
#add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_en_d_ram0


add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_ct_a_flash_ctrl
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_ct_2_bytes
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_en_ct_2_bytes
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_a_ram0
add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_en_a_ram_01
#add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_a_ram1
#add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/r_cenb_ram2
#add wave -group mem_ctrl_top -noupdate -format hexadecimal /mem_ctrl_top_inst/w_en_cenb_ram_23




add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/NVR
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/CEb
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/WEb
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/PROG
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/PROG2
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/ERASE
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/READM0
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/READM1
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/CHIP
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/OEb
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/PORb
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/TMEN
add wave -group FLASH -noupdate -format hexadecimal /mem_ctrl_top_inst/JBFLS006K8IDA_inst/A
add wave -group FLASH -noupdate -format hexadecimal /mem_ctrl_top_inst/JBFLS006K8IDA_inst/DIN
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/DPSTB
add wave -group FLASH -noupdate -format hexadecimal /mem_ctrl_top_inst/JBFLS006K8IDA_inst/BYTE
add wave -group FLASH -noupdate -format logic       /mem_ctrl_top_inst/JBFLS006K8IDA_inst/VPP
add wave -group FLASH -noupdate -format hexadecimal /mem_ctrl_top_inst/JBFLS006K8IDA_inst/DOUT



add wave -group RAM0 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/A  
add wave -group RAM0 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/CLK	
add wave -group RAM0 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/CENB
add wave -group RAM0 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/D			
add wave -group RAM0 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/WENB
add wave -group RAM0 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst0/Q	

add wave -group RAM1 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/A  
add wave -group RAM1 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/CLK	
add wave -group RAM1 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/CENB
add wave -group RAM1 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/D			
add wave -group RAM1 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/WENB
add wave -group RAM1 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst1/Q

add wave -group RAM2 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/A  
add wave -group RAM2 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/CLK	
add wave -group RAM2 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/CENB
add wave -group RAM2 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/D			
add wave -group RAM2 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/WENB
add wave -group RAM2 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst2/Q	

add wave -group RAM3 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/A  
add wave -group RAM3 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/CLK	
add wave -group RAM3 -noupdate -format logic        /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/CENB
add wave -group RAM3 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/D			
add wave -group RAM3 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/WENB
add wave -group RAM3 -noupdate -format hexadecimal  /mem_ctrl_top_inst/JLRAMSAC8192X8C4V0_inst3/Q


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
