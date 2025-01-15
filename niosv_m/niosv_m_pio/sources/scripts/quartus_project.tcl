# (C) 2001-2024 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# (C) 2001-2024 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# (C) 2001-2023 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# Copyright (C) 2022  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: top_quartus_proj.tcl
# Generated on: Thu Jul  7 03:02:23 2022

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
	set_global_assignment -name TOP_LEVEL_ENTITY qsys_top
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 22.3.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "02:39:05  JULY 07, 2022"
	set_global_assignment -name LAST_QUARTUS_VERSION "22.3.0 Pro Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE A5ED065BB32AE6SR0
    set_global_assignment -name FAMILY "Agilex 5"
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name BOARD "Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1"
	set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (Verilog)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
	set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
	set_global_assignment -name SDC_FILE top.sdc
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_reset_in.ip
	set_global_assignment -name QSYS_FILE qsys_top.qsys
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_intel_niosv_m_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_pio_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_jtag_uart_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_intel_onchip_memory_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_s10_user_rst_clkgate_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_s10_configuration_clock_0.ip
	set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL

	# Including default assignments
	set_global_assignment -name FLOW_ENABLE_DESIGN_ASSISTANT ON -family "Agilex 7"
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON -family "Agilex 7"
	set_global_assignment -name TDC_CCPP_TRADEOFF_TOLERANCE 0 -family "Agilex 7"
	set_global_assignment -name TIMING_ANALYZER_DO_CCPP_REMOVAL ON -family "Agilex 7"
	set_global_assignment -name PHYSICAL_SHIFT_REGISTER_INFERENCE ON -family "Agilex 7"
	set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3 -family "Agilex 7"
	set_global_assignment -name SYNTH_RESOURCE_AWARE_INFERENCE_FOR_BLOCK_RAM ON -family "Agilex 7"
	set_global_assignment -name USE_ADVANCED_DETAILED_LAB_LEGALITY ON -family "Agilex 7"
	set_global_assignment -name ADVANCED_PHYSICAL_SYNTHESIS_REGISTER_PACKING ON -family "Agilex 7"
	set_global_assignment -name PHYSICAL_SYNTHESIS ON -family "Agilex 7"
	set_global_assignment -name POST_ROUTE_PHYSICAL_SYNTHESIS OFF -family "Agilex 7"
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X4" -family "Agilex 7"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS" -family "Agilex 7"
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON -family "Agilex 7"
	set_global_assignment -name ENABLE_PHYSICAL_DSP_MERGING ON -family "Agilex 7"
	set_global_assignment -name AUTO_DELAY_CHAINS ON -family "Agilex 7"
	set_global_assignment -name ENABLE_ED_CRC_CHECK ON -family "Agilex 7"
	set_global_assignment -name ALLOW_SEU_FAULT_INJECTION OFF -family "Agilex 7"
	set_global_assignment -name FITTER_RESYNTHESIS ON -family "Agilex 7"
	set_global_assignment -name FITTER_EARLY_RETIMING ON -family "Agilex 7"
	set_global_assignment -name HYPER_EARLY_RETIMER OFF -family "Agilex 7"
	set_global_assignment -name FLOW_ENABLE_HYPER_RETIMER_FAST_FORWARD OFF -family "Agilex 7"
	set_global_assignment -name HYPER_RETIMER_FAST_FORWARD_ON_HIERARCHY ON -family "Agilex 7"
	set_global_assignment -name GENERATE_PR_RBF_FILE ON -family "Agilex 7"
	set_global_assignment -name HPS_INITIALIZATION "AFTER INIT_DONE" -family "Agilex 7"
	set_global_assignment -name PROGRAMMING_BITSTREAM_ENCRYPTION_KEY_SELECT "Battery Backup RAM" -family "Agilex 7"
	set_global_assignment -name POWER_USE_DEVICE_CHARACTERISTICS MAXIMUM -family "Agilex 7"
	set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_100MHZ -family "Agilex 7"

	# Assembler Assignments and VID
	# =====================
	# VID Settings: PWRMGMT
	set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_115MHZ_IOSC
	set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE LTM4677
	set_global_assignment -name USE_CONF_DONE SDM_IO16
	set_global_assignment -name USE_INIT_DONE SDM_IO0
	set_global_assignment -name USE_CVP_CONFDONE SDM_IO10
	set_global_assignment -name VID_OPERATION_MODE "PMBUS MASTER"
	set_global_assignment -name USE_PWRMGT_SCL SDM_IO14
	set_global_assignment -name USE_PWRMGT_SDA SDM_IO11
	set_global_assignment -name PWRMGT_BUS_SPEED_MODE "100 KHZ"
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47
	set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00
	set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS
	set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF
	set_global_assignment -name PWRMGT_DIRECT_FORMAT_COEFFICIENT_M 1
	set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
	set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-13"

	

	# Pin Assignments
	# Commit assignments
#	set_location_assignment PIN_A24 -to cpu_resetn
#	set_location_assignment PIN_G26 -to clk_clk


	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
