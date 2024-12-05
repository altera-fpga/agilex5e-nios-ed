## Generated SDC file "top.out.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the Intel FPGA Software License Subscription Agreements 
## on the Quartus Prime software download page.


## VENDOR  "Intel Corporation"
## PROGRAM "Quartus Prime"
## VERSION "Version 23.4.0 Internal Build 35 09/21/2023 SC Pro Edition"

## DATE    "Tue Oct  3 00:07:51 2023"

##
## DEVICE  "AGFB014R24B2E2V"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 62.500 -waveform { 0.000 31.250 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_clk} -period 8.000 -waveform { 0.000 10.000 } [get_ports {clk_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk_clk}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_clk}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_clk}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_clk}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {altera_reserved_tck}]  44.688 [get_ports {altera_reserved_tdo}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {altera_reserved_tck}]  36.454 [get_ports {altera_reserved_tdo}]



#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]
set_clock_groups -asynchronous -group [get_clocks {internal_clk}]



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_pins -nocase -compatibility_mode {rst_controller|*alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_req_sync_in_rst|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_req_sync_out_rst|altera_reset_synchronizer_int_chain*|clrn}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

#set_max_delay -to [get_registers {rst_controller_001|*alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[1]}] 100.000 
#set_max_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] 100.000 
#set_max_delay -from [get_registers {*altera_avalon_st_clock_crosser:*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] 100.000 


#**************************************************************
# Set Minimum Delay
#**************************************************************

#set_min_delay -to [get_registers {rst_controller_001|*alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[1]}] -100.000
#set_min_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] -100.000
#set_min_delay -from [get_registers {*altera_avalon_st_clock_crosser:*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] -100.000


#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Net Delay
#**************************************************************

#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_data_buffer*}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_data_buffer*}]
#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_data_buffer*}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_data_buffer*}]
#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_data_toggle}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_to_out_synchronizer|din_s1}]
#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_data_toggle}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_to_out_synchronizer|din_s1}]
#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_data_toggle_flopped_n}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_to_in_synchronizer|din_s1}]
#set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_data_toggle_flopped_n}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_to_in_synchronizer|din_s1}]


#**************************************************************
# Set Max Skew
#**************************************************************

#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_data_buffer*}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_data_buffer*}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_data_buffer*}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_data_buffer*}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_data_toggle}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|in_to_out_synchronizer|din_s1}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_data_toggle}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|in_to_out_synchronizer|din_s1}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_data_toggle_flopped_n}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|rsp_clk_xer|clock_xer|out_to_in_synchronizer|din_s1}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
#set_max_skew -from [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_data_toggle_flopped_n}] -to [get_registers {intel_niosv_m_0|intel_niosv_m_0|dbg_mod|dtm_inst|cmd_clk_xer|clock_xer|out_to_in_synchronizer|din_s1}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 -nowarn
