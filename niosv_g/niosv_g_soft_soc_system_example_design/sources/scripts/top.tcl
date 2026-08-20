# Copyright (C) 2026  Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus Prime License Agreement,
# the Altera IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Altera and sold by Altera or its authorized distributors.  Please
# refer to the Altera Software License Subscription Agreements 
# on the Quartus Prime software download page.

# Quartus Prime: Generate Tcl File for Project
# File: top.tcl
# Generated on: Mon Mar 16 00:27:08 2026

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "top"]} {
		puts "Project top is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists top]} {
		project_open -revision top top
	} else {
		project_new -revision top top
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name TOP_LEVEL_ENTITY top
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 23.4.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "03:11:18  OCTOBER 15, 2023"
	set_global_assignment -name LAST_QUARTUS_VERSION "26.1.1 Pro Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE A5ED065BB32AE6SR0
	set_global_assignment -name FAMILY "Agilex 5"
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
	set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
	set_global_assignment -name BOARD "Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1"
	set_global_assignment -name ENABLE_SIGNALTAP ON
	set_global_assignment -name USE_SIGNALTAP_FILE stp1.stp
	set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
	set_global_assignment -name IP_SEARCH_PATHS "**/*; ip/**/*"
	set_global_assignment -name FLOW_ENABLE_HYPER_RETIMER_FAST_FORWARD ON
	set_global_assignment -name HYPER_RETIMER_FAST_FORWARD_ADD_PIPELINING_MAX 1
	set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
	set_global_assignment -name VERILOG_FILE pb_debounce.v
	set_global_assignment -name SDC_FILE top.sdc
	set_global_assignment -name VERILOG_FILE top.v
	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name IP_FILE reset_release.ip
	set_global_assignment -name IP_FILE iopll.ip
	set_global_assignment -name VDS_FILE src/vds/qsys_top/qsys_top.vds -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_address_span_extender_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_clock_in.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_emif_axi_adaptor_eagle_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_emif_io96b_lpddr4_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_emif_ph2_axil_driver_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_i2c_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_intel_mailbox_client_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_intel_niosv_g_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_jtag_uart_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_msgdma_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_intel_onchip_memory_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_intel_onchip_memory_2.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_intel_onchip_memory_1.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_pio_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_pio_1.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_reset_bridge_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_spi_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_sysid_qsys_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_top/ip/qsys_top_timer_0.ip -tag "vds::qsys_top"
	set_global_assignment -name VDS_FILE src/vds/qsys_agent/qsys_agent.vds -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_clock_in.ip -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_i2cslave_to_avlmm_bridge_0.ip -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_intel_onchip_memory_1.ip -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_master_0.ip -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_reset_bridge_0.ip -tag "vds::qsys_agent"
	set_global_assignment -name VDS_IP_FILE src/vds/qsys_agent/ip/qsys_agent_spi_slave_to_avalon_mm_master_bridge_0.ip -tag "vds::qsys_agent"
	set_location_assignment PIN_BM71 -to clk
	set_instance_assignment -name IO_STANDARD "1.1V TRUE DIFFERENTIAL SIGNALING" -to clk -entity top
	# IOBANK_5A
	set_location_assignment PIN_CA118 -to scl_wire -comment IOBANK_5A
	# IOBANK_5A
	set_location_assignment PIN_BW118 -to sda_wire -comment IOBANK_5A
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to scl_wire -entity top
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to sda_wire -entity top
	set_location_assignment PIN_BW78 -to ref_clk_0_clk
	set_instance_assignment -name IO_STANDARD "1.1V TRUE DIFFERENTIAL SIGNALING" -to ref_clk_0_clk -entity top
	set_location_assignment PIN_BH89 -to emif_oct_0_oct_rzqin
	set_instance_assignment -name IO_STANDARD "1.1-V" -to emif_oct_0_oct_rzqin -entity top
	set_location_assignment PIN_BM81 -to emif_mem_0_mem_ck_t
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_ck_t -entity top
	set_location_assignment PIN_BP81 -to emif_mem_0_mem_ck_c
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_ck_c -entity top
	set_location_assignment PIN_BR81 -to emif_mem_0_mem_cke
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_cke -entity top
	set_location_assignment PIN_BH92 -to emif_mem_0_mem_reset_n
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_reset_n -entity top
	set_location_assignment PIN_BR78 -to emif_mem_0_mem_cs
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_cs -entity top
	set_location_assignment PIN_BR89 -to emif_mem_0_mem_ca[0]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[0] -entity top
	set_location_assignment PIN_BU89 -to emif_mem_0_mem_ca[1]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[1] -entity top
	set_location_assignment PIN_BR92 -to emif_mem_0_mem_ca[2]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[2] -entity top
	set_location_assignment PIN_BU92 -to emif_mem_0_mem_ca[3]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[3] -entity top
	set_location_assignment PIN_BW89 -to emif_mem_0_mem_ca[4]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[4] -entity top
	set_location_assignment PIN_CA89 -to emif_mem_0_mem_ca[5]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_ca[5] -entity top
	set_location_assignment PIN_CA71 -to emif_mem_0_mem_dq[0]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[0] -entity top
	set_location_assignment PIN_CC71 -to emif_mem_0_mem_dq[1]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[1] -entity top
	set_location_assignment PIN_CH71 -to emif_mem_0_mem_dq[2]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[2] -entity top
	set_location_assignment PIN_CF71 -to emif_mem_0_mem_dq[3]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[3] -entity top
	set_location_assignment PIN_CH62 -to emif_mem_0_mem_dq[4]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[4] -entity top
	set_location_assignment PIN_CF62 -to emif_mem_0_mem_dq[5]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[5] -entity top
	set_location_assignment PIN_CH59 -to emif_mem_0_mem_dq[6]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[6] -entity top
	set_location_assignment PIN_CF59 -to emif_mem_0_mem_dq[7]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[7] -entity top
	set_location_assignment PIN_BR59 -to emif_mem_0_mem_dq[8]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[8] -entity top
	set_location_assignment PIN_BU59 -to emif_mem_0_mem_dq[9]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[9] -entity top
	set_location_assignment PIN_BW59 -to emif_mem_0_mem_dq[10]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[10] -entity top
	set_location_assignment PIN_CA59 -to emif_mem_0_mem_dq[11]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[11] -entity top
	set_location_assignment PIN_BU71 -to emif_mem_0_mem_dq[12]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[12] -entity top
	set_location_assignment PIN_BU69 -to emif_mem_0_mem_dq[13]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[13] -entity top
	set_location_assignment PIN_BR71 -to emif_mem_0_mem_dq[14]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[14] -entity top
	set_location_assignment PIN_BR69 -to emif_mem_0_mem_dq[15]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[15] -entity top
	set_location_assignment PIN_CC92 -to emif_mem_0_mem_dq[16]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[16] -entity top
	set_location_assignment PIN_CF92 -to emif_mem_0_mem_dq[17]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[17] -entity top
	set_location_assignment PIN_CA92 -to emif_mem_0_mem_dq[18]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[18] -entity top
	set_location_assignment PIN_CH92 -to emif_mem_0_mem_dq[19]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[19] -entity top
	set_location_assignment PIN_CC81 -to emif_mem_0_mem_dq[20]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[20] -entity top
	set_location_assignment PIN_CF78 -to emif_mem_0_mem_dq[21]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[21] -entity top
	set_location_assignment PIN_CH78 -to emif_mem_0_mem_dq[22]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[22] -entity top
	set_location_assignment PIN_CA81 -to emif_mem_0_mem_dq[23]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[23] -entity top
	set_location_assignment PIN_CL82 -to emif_mem_0_mem_dq[24]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[24] -entity top
	set_location_assignment PIN_CK80 -to emif_mem_0_mem_dq[25]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[25] -entity top
	set_location_assignment PIN_CK76 -to emif_mem_0_mem_dq[26]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[26] -entity top
	set_location_assignment PIN_CL76 -to emif_mem_0_mem_dq[27]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[27] -entity top
	set_location_assignment PIN_CK97 -to emif_mem_0_mem_dq[28]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[28] -entity top
	set_location_assignment PIN_CL97 -to emif_mem_0_mem_dq[29]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[29] -entity top
	set_location_assignment PIN_CK94 -to emif_mem_0_mem_dq[30]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[30] -entity top
	set_location_assignment PIN_CL91 -to emif_mem_0_mem_dq[31]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dq[31] -entity top
	set_location_assignment PIN_CH69 -to emif_mem_0_mem_dqs_t[0]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_t[0] -entity top
	set_location_assignment PIN_BW69 -to emif_mem_0_mem_dqs_t[1]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_t[1] -entity top
	set_location_assignment PIN_CH89 -to emif_mem_0_mem_dqs_t[2]
	set_location_assignment PIN_CL88 -to emif_mem_0_mem_dqs_t[3]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_t[2] -entity top
	set_location_assignment PIN_CF69 -to emif_mem_0_mem_dqs_c[0]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_c[0] -entity top
	set_location_assignment PIN_CA69 -to emif_mem_0_mem_dqs_c[1]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_c[1] -entity top
	set_location_assignment PIN_CF89 -to emif_mem_0_mem_dqs_c[2]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_c[2] -entity top
	set_location_assignment PIN_CK88 -to emif_mem_0_mem_dqs_c[3]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to emif_mem_0_mem_dqs_c[3] -entity top
	set_location_assignment PIN_CA62 -to emif_mem_0_mem_dmi[0]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dmi[0] -entity top
	set_location_assignment PIN_BU62 -to emif_mem_0_mem_dmi[1]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dmi[1] -entity top
	set_location_assignment PIN_CF81 -to emif_mem_0_mem_dmi[2]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dmi[2] -entity top
	set_location_assignment PIN_CK85 -to emif_mem_0_mem_dmi[3]
	set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to emif_mem_0_mem_dmi[3] -entity top
	set_location_assignment PIN_BM59 -to user_led[0]
	set_instance_assignment -name IO_STANDARD "1.1 V" -to user_led[0] -entity top
	set_location_assignment PIN_BH59 -to user_led[1]
	set_instance_assignment -name IO_STANDARD "1.1 V" -to user_led[1] -entity top
	set_location_assignment PIN_BH62 -to user_led[2]
	set_instance_assignment -name IO_STANDARD "1.1 V" -to user_led[2] -entity top
	set_location_assignment PIN_BK59 -to user_led[3]
	set_instance_assignment -name IO_STANDARD "1.1 V" -to user_led[3] -entity top
	set_location_assignment PIN_BK31 -to pb_input[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to pb_input[0] -entity top
	set_location_assignment PIN_BP22 -to pb_input[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to pb_input[1] -entity top
	set_location_assignment PIN_BK28 -to pb_input[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to pb_input[2] -entity top
	set_location_assignment PIN_BR22 -to pb_input[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to pb_input[3] -entity top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
