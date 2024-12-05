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


# Copyright (C) 2023  Intel Corporation. All rights reserved.
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
# File: top.tcl
# Generated on: Thu May 11 02:35:40 2023

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
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 23.2.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "09:28:10  MAY 10, 2023"
	set_global_assignment -name LAST_QUARTUS_VERSION "23.2.0 Pro Edition"
	set_global_assignment -name SYSTEMVERILOG_FILE top.sv
	set_global_assignment -name VERILOG_FILE tcd2um.v
	set_global_assignment -name VERILOG_FILE synchronizer.v
	set_global_assignment -name SDC_FILE jtag.sdc
	set_global_assignment -name IP_FILE clock_config_ip.ip
	set_global_assignment -name IP_FILE issp_out_ip.ip
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name FAMILY "Agilex 5"
	set_global_assignment -name DEVICE A5ED065BB32AE6SR0
	set_global_assignment -name BOARD "Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1"
	set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (Verilog)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
	set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_clock_in.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_reset_in.ip
	set_global_assignment -name QSYS_FILE qsys_top.qsys
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_intel_niosv_g_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_intel_onchip_memory_0.ip
	set_global_assignment -name IP_FILE ip/qsys_top/qsys_top_jtag_uart_0.ip

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
