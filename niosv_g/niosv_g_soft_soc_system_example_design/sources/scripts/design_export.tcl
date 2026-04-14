load_package vds
# project_new top
# 
# Info: Current script was exported with Quartus Prime Pro Release 26.1.0 Build 102
# 
regexp {[\.0-9]+} $quartus(version) import_release
if {$import_release != "26.1.0"} {
	post_message -type error "Cannot import script exported from Quartus Prime Pro version \"26.1.0 Build 102\" into current release \"$import_release\".\n\tOpen, upgrade, and validate the original system in VDS to ensure design correctness."
	return
}
proc get_current_hier {} {
set current_hier [vds::get_current_hier]
if {$current_hier == "|"} {
	set current_hier ""
}
return $current_hier
}

project_open top

vds::create_system qsys_agent
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {125000000}  } -vlnv altera.com:ip:altera_clock_bridge: clock_in
vds::create_cell -properties { parameters:BYTE_ADDRESSING {4}  } -vlnv altera.com:ip:altera_i2cslave_to_avlmm_bridge: i2cslave_to_avlmm_bridge_0
vds::create_cell -properties { parameters:initMemContent {false}  } -vlnv altera.com:ip:intel_onchip_memory: intel_onchip_memory_1
vds::create_cell -vlnv altera.com:ip:altera_jtag_avalon_master:19.1 master_0
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: reset_bridge_0
vds::create_cell -vlnv altera.com:ip:spi_slave_to_avalon_mm_master_bridge: spi_slave_to_avalon_mm_master_bridge_0
vds::connect_interface_net -dest intel_onchip_memory_1|s1 -src i2cslave_to_avlmm_bridge_0|avalon_master
vds::assign_base_address -connection i2cslave_to_avlmm_bridge_0.avalon_master/intel_onchip_memory_1.s1 0x0000
vds::connect_interface_net -dest intel_onchip_memory_1|s1 -src spi_slave_to_avalon_mm_master_bridge_0|avalon_master
vds::assign_base_address -connection spi_slave_to_avalon_mm_master_bridge_0.avalon_master/intel_onchip_memory_1.s1 0x0000
vds::connect_interface_net -dest intel_onchip_memory_1|s1 -src master_0|master
vds::assign_base_address -connection master_0.master/intel_onchip_memory_1.s1 0x0000
vds::export_interface_pin spi_slave_to_avalon_mm_master_bridge_0|export_0 spi_slave_to_avalon_mm_master_bridge_0_export_0
vds::export_interface_pin i2cslave_to_avlmm_bridge_0|conduit_end i2cslave_to_avlmm_bridge_0_conduit_end
vds::export_pin reset_bridge_0|in_reset reset_agent
vds::export_pin clock_in|in_clk clk
vds::connect_net -src reset_bridge_0|out_reset -dest master_0|clk_reset
vds::connect_net -src reset_bridge_0|out_reset -dest i2cslave_to_avlmm_bridge_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest intel_onchip_memory_1|reset1
vds::connect_net -src reset_bridge_0|out_reset -dest spi_slave_to_avalon_mm_master_bridge_0|reset_n
vds::connect_net -src clock_in|out_clk -dest master_0|clk
vds::connect_net -src clock_in|out_clk -dest reset_bridge_0|clk
vds::connect_net -src clock_in|out_clk -dest spi_slave_to_avalon_mm_master_bridge_0|clk
vds::connect_net -src clock_in|out_clk -dest intel_onchip_memory_1|clk1
vds::connect_net -src clock_in|out_clk -dest i2cslave_to_avlmm_bridge_0|clock
vds::set_domain_properties {qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.maxAdditionalLatency 1 qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.interconnectResetSource DEFAULT qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.responseFifoType REGISTER_BASED qsys_mm.widthAdapterImplementation GENERIC_CONVERTER qsys_mm.insertDefaultSlave FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.syncResets TRUE qsys_mm.enableAllPipelines FALSE qsys_mm.optimizeRdFifoSize FALSE } i2cslave_to_avlmm_bridge_0.avalon_master
vds::validate_system
vds::save_system qsys_agent
vds::close_system qsys_agent

post_message "Script completed successfully."

load_package vds
# project_new top
# 
# Info: Current script was exported with Quartus Prime Pro Release 26.1.0 Build 102
# 
regexp {[\.0-9]+} $quartus(version) import_release
if {$import_release != "26.1.0"} {
	post_message -type error "Cannot import script exported from Quartus Prime Pro version \"26.1.0 Build 102\" into current release \"$import_release\".\n\tOpen, upgrade, and validate the original system in VDS to ensure design correctness."
	return
}
proc get_current_hier {} {
set current_hier [vds::get_current_hier]
if {$current_hier == "|"} {
	set current_hier ""
}
return $current_hier
}

vds::create_system qsys_top
vds::create_cell -properties { parameters:MASTER_ADDRESS_WIDTH {33}  } -vlnv altera.com:ip:altera_address_span_extender: address_span_extender_0
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {125000000}  } -vlnv altera.com:ip:altera_clock_bridge: clock_in
vds::create_cell -vlnv :ip:emif_axi_adaptor_eagle:1.0 emif_axi_adaptor_eagle_0
vds::create_cell -properties { parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:MEM_VREF_DQ_X_VALUE {18.0} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_DQ_VREF {17.5} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:MEM_TZQLAT_NS {30.0} parameters:MEM_TMRWCKEL_NS {14.0} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:MEM_MINNUMREFSREQ {8192.0} parameters:MEM_TREFI_NS {3904.0} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_LVSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:MEM_TRFCPB_NS {190.0} parameters:PHY_MAINBAND_ACCESS_MODE {ASYNC} parameters:MEM_ODT_CA_X_CS_ENABLE {true} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:MEM_TDQSCK_MAX_NS {3.5} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:MEM_WLS {1.0} parameters:MEM_TESCKE_NS {3.75} parameters:MEM_TRFCAB_NS {380.0} parameters:MEM_TCSCKE_NS {1.75} parameters:MEM_TCSCKEH_NS {1.75} parameters:MEM_TCKCKEL_NS {6.25} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_LVSTL} parameters:MEM_CA_VREF {13} parameters:MEM_ODT_CA_X_CA_ENABLE {true} parameters:MEM_TCMDCKE_NS {3.75} parameters:MEM_TCKELCMD_NS {6.25} parameters:PHY_REFCLK_FREQ_MHZ {200.0} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_PER_BANK_REF_EN {1} parameters:MEM_TRPAB_NS {21.0} parameters:MEM_TCCD_NS {10.0} parameters:MEM_VREF_CA_X_CA_VALUE {27.2} parameters:MEM_ODT_DQ_X_RON {6} parameters:MEM_TMRD_NS {14.0} parameters:MEM_ODT_CA_X_CK_ENABLE {true} parameters:MEM_TRCD_NS {18.0} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:MEM_TMRR_NS {10.0} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:MEM_ODT_DQ_X_TGT_WR {5} parameters:MEM_TRC_NS {63.0} parameters:MEM_CWL_CYC {12} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF} parameters:MEM_TREFW_NS {3.2E7} parameters:MEM_TZQCKE_NS {3.75} parameters:MEM_DQ_VREF {20} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:MEM_CHANNEL_DATA_DQ_WIDTH {32} parameters:MEM_NUM_CHANNELS {1} parameters:MEM_TRPPB_NS {18.0} parameters:MEM_OPERATING_FREQ_MHZ {800} parameters:MEM_TCKCKEH_NS {3.75} parameters:MEM_TZQCAL_NS {1000.0} parameters:MEM_TSR_NS {15.0} parameters:MEM_ODT_CA_X_CA_COMM {3} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:MEM_TCKE_NS {7.5} parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {LVSTL} parameters:MEM_TRTP_NS {10.0} parameters:MEM_TXSR_NS {387.5} parameters:MEM_TDQSCK_MIN_NS {1.5} parameters:MEM_TCKEHCMD_NS {7.5} parameters:MEM_TRAS_NS {42.0} parameters:MEM_TFAW_NS {40.0} parameters:MEM_CL_CYC {14} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:MEM_TMRW_NS {12.5} parameters:MEM_TPPD_CYC {4.0} parameters:MEM_TWR_NS {18.0} parameters:MEM_TCKELCK_NS {6.25} parameters:MEM_TRRD_NS {10.0} parameters:MEM_TWTR_NS {10.0} parameters:MEM_TXP_NS {7.5} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=3,2,X,X,X,X,1,0; PIN_SWIZZLE_CH0_DQS0=3,2,1,0,5,4,7,6; PIN_SWIZZLE_CH0_DQS1=15,13,14,12,9,8,10,11; PIN_SWIZZLE_CH0_DQS2=16,18,17,19,23,20,22,21; PIN_SWIZZLE_CH0_DQS3=31,30,28,29,25,24,26,27;}  } -vlnv altera.com:ip:emif_io96b_lpddr4: emif_io96b_lpddr4_0
vds::create_cell -vlnv :ip:emif_ph2_axil_driver: emif_ph2_axil_driver_0
vds::create_cell -properties { parameters:FIFO_DEPTH {64}  } -vlnv altera.com:ip:altera_avalon_i2c: i2c_0
vds::create_cell -vlnv altera.com:ip:intel_mailbox_client: intel_mailbox_client_0
vds::create_cell -properties { parameters:resetSlave {ocm_boot_niosv.axi_s1} parameters:peripheralRegionABase {589824} parameters:peripheralRegionASize {65536}  } -vlnv altera.com:ip:intel_niosv_g: intel_niosv_g_0
vds::create_cell -vlnv altera.com:ip:altera_avalon_jtag_uart: jtag_uart_0
vds::create_cell -vlnv altera.com:ip:altera_msgdma: msgdma_0
vds::create_cell -properties { parameters:memorySize {524288} parameters:interfaceType {1} parameters:idWidth {3} parameters:initMemContent {false}  } -vlnv altera.com:ip:intel_onchip_memory: ocm_boot_niosv
vds::create_cell -properties { parameters:memorySize {1048576} parameters:initMemContent {false}  } -vlnv altera.com:ip:intel_onchip_memory: ocm_read_dma_write
vds::create_cell -properties { parameters:memorySize {1048576} parameters:initMemContent {false}  } -vlnv altera.com:ip:intel_onchip_memory: ocm_write_dma_read
vds::create_cell -properties { parameters:width {4}  } -vlnv altera.com:ip:altera_avalon_pio: pio_0
vds::create_cell -properties { parameters:width {4} parameters:direction {Input}  } -vlnv altera.com:ip:altera_avalon_pio: pio_1
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: reset_bridge_0
vds::create_cell -properties { parameters:clockPhase {1}  } -vlnv altera.com:ip:altera_avalon_spi: spi_0
vds::create_cell -properties { parameters:id {165}  } -vlnv altera.com:ip:altera_avalon_sysid_qsys: sysid_qsys_0
vds::create_cell -properties { parameters:timeoutPulseOutput {true} parameters:resetOutput {true} parameters:period {1000}  } -vlnv altera.com:ip:altera_avalon_timer: timer_0
vds::connect_interface_net -dest address_span_extender_0|cntl -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/address_span_extender_0.cntl 0x00090160
vds::connect_interface_net -dest emif_axi_adaptor_eagle_0|core_axi -src address_span_extender_0|expanded_master
vds::assign_base_address -connection address_span_extender_0.expanded_master/emif_axi_adaptor_eagle_0.core_axi 0x0000
vds::connect_interface_net -dest address_span_extender_0|windowed_slave -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/address_span_extender_0.windowed_slave 0x000c0000
vds::connect_interface_net -dest emif_io96b_lpddr4_0|s0_axi4 -src emif_axi_adaptor_eagle_0|emif_axi
vds::assign_base_address -connection emif_axi_adaptor_eagle_0.emif_axi/emif_io96b_lpddr4_0.s0_axi4 0x0000
vds::connect_interface_net -dest emif_io96b_lpddr4_0|s0_axi4lite -src emif_ph2_axil_driver_0|axil_driver_axi4_lite
vds::assign_base_address -connection emif_ph2_axil_driver_0.axil_driver_axi4_lite/emif_io96b_lpddr4_0.s0_axi4lite 0x0000
vds::connect_interface_net -dest i2c_0|csr -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/i2c_0.csr 0x00090040
vds::connect_interface_net -dest i2c_0|interrupt_sender -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/i2c_0.interrupt_sender 0
vds::connect_interface_net -dest intel_mailbox_client_0|irq -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/intel_mailbox_client_0.irq 1
vds::connect_interface_net -dest intel_mailbox_client_0|avmm -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/intel_mailbox_client_0.avmm 0x00090000
vds::connect_interface_net -dest intel_niosv_g_0|dm_agent -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/intel_niosv_g_0.dm_agent 0x00080000
vds::connect_interface_net -dest intel_niosv_g_0|dm_agent -src intel_niosv_g_0|instruction_manager
vds::assign_base_address -connection intel_niosv_g_0.instruction_manager/intel_niosv_g_0.dm_agent 0x00080000
vds::connect_interface_net -dest intel_niosv_g_0|timer_sw_agent -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/intel_niosv_g_0.timer_sw_agent 0x00090080
vds::connect_interface_net -dest jtag_uart_0|avalon_jtag_slave -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/jtag_uart_0.avalon_jtag_slave 0x00090158
vds::connect_interface_net -dest ocm_boot_niosv|axi_s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/ocm_boot_niosv.axi_s1 0x0000
vds::connect_interface_net -dest sysid_qsys_0|control_slave -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/sysid_qsys_0.control_slave 0x00090150
vds::connect_interface_net -dest msgdma_0|csr -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/msgdma_0.csr 0x00090100
vds::connect_interface_net -dest msgdma_0|descriptor_slave -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/msgdma_0.descriptor_slave 0x00090140
vds::connect_interface_net -dest ocm_read_dma_write|s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/ocm_read_dma_write.s1 0x00d00000
vds::connect_interface_net -dest ocm_write_dma_read|s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/ocm_write_dma_read.s1 0x00e00000
vds::connect_interface_net -dest pio_0|s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/pio_0.s1 0x00090130
vds::connect_interface_net -dest pio_1|s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/pio_1.s1 0x00090120
vds::connect_interface_net -dest timer_0|s1 -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/timer_0.s1 0x000900c0
vds::connect_interface_net -dest spi_0|spi_control_port -src intel_niosv_g_0|data_manager
vds::assign_base_address -connection intel_niosv_g_0.data_manager/spi_0.spi_control_port 0x000900e0
vds::connect_interface_net -dest ocm_boot_niosv|axi_s1 -src intel_niosv_g_0|instruction_manager
vds::assign_base_address -connection intel_niosv_g_0.instruction_manager/ocm_boot_niosv.axi_s1 0x0000
vds::connect_interface_net -dest msgdma_0|csr_irq -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/msgdma_0.csr_irq 3
vds::connect_interface_net -dest jtag_uart_0|irq -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/jtag_uart_0.irq 2
vds::connect_interface_net -dest spi_0|irq -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/spi_0.irq 4
vds::connect_interface_net -dest timer_0|irq -src intel_niosv_g_0|platform_irq_rx
vds::set_interrupt_irq -connection intel_niosv_g_0.platform_irq_rx/timer_0.irq 5
vds::connect_interface_net -dest ocm_write_dma_read|s1 -src msgdma_0|mm_write
vds::assign_base_address -connection msgdma_0.mm_write/ocm_write_dma_read.s1 0x0000
vds::connect_interface_net -dest ocm_read_dma_write|s1 -src msgdma_0|mm_read
vds::assign_base_address -connection msgdma_0.mm_read/ocm_read_dma_write.s1 0x0000
vds::export_interface_pin spi_0|external spi_0_external
vds::export_interface_pin i2c_0|i2c_serial i2c_0_i2c_serial
vds::export_interface_pin emif_io96b_lpddr4_0|mem_ck_0 emif_io96b_lpddr4_0_mem_ck_0
vds::export_interface_pin emif_io96b_lpddr4_0|mem_0 emif_io96b_lpddr4_0_mem_0
vds::export_pin reset_bridge_0|in_reset reset_top
vds::export_pin pio_1|external_connection pio_1_external_connection
vds::export_pin pio_0|external_connection pio_0_external_connection
vds::export_pin emif_io96b_lpddr4_0|ref_clk emif_io96b_lpddr4_0_ref_clk
vds::export_pin emif_io96b_lpddr4_0|oct_0 emif_io96b_lpddr4_0_oct_0
vds::export_pin emif_io96b_lpddr4_0|mem_reset_n emif_io96b_lpddr4_0_mem_reset_n
vds::export_pin clock_in|in_clk clk
vds::connect_net -src reset_bridge_0|out_reset -dest emif_ph2_axil_driver_0|axil_driver_rst_n
vds::connect_net -src reset_bridge_0|out_reset -dest emif_io96b_lpddr4_0|core_init_n
vds::connect_net -src reset_bridge_0|out_reset -dest intel_mailbox_client_0|in_reset
vds::connect_net -src reset_bridge_0|out_reset -dest address_span_extender_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest jtag_uart_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest pio_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest pio_1|reset
vds::connect_net -src reset_bridge_0|out_reset -dest spi_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest sysid_qsys_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest timer_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest intel_niosv_g_0|reset
vds::connect_net -src reset_bridge_0|out_reset -dest ocm_boot_niosv|reset1
vds::connect_net -src reset_bridge_0|out_reset -dest ocm_read_dma_write|reset1
vds::connect_net -src reset_bridge_0|out_reset -dest ocm_write_dma_read|reset1
vds::connect_net -src reset_bridge_0|out_reset -dest msgdma_0|reset_n
vds::connect_net -src reset_bridge_0|out_reset -dest i2c_0|reset_sink
vds::connect_net -src reset_bridge_0|out_reset -dest emif_axi_adaptor_eagle_0|rst_n_i
vds::connect_net -src reset_bridge_0|out_reset -dest emif_io96b_lpddr4_0|s0_axi4lite_reset_n
vds::connect_net -src clock_in|out_clk -dest emif_ph2_axil_driver_0|axil_driver_clk
vds::connect_net -src clock_in|out_clk -dest jtag_uart_0|clk
vds::connect_net -src clock_in|out_clk -dest pio_0|clk
vds::connect_net -src clock_in|out_clk -dest pio_1|clk
vds::connect_net -src clock_in|out_clk -dest reset_bridge_0|clk
vds::connect_net -src clock_in|out_clk -dest spi_0|clk
vds::connect_net -src clock_in|out_clk -dest sysid_qsys_0|clk
vds::connect_net -src clock_in|out_clk -dest timer_0|clk
vds::connect_net -src clock_in|out_clk -dest intel_niosv_g_0|clk
vds::connect_net -src clock_in|out_clk -dest ocm_boot_niosv|clk1
vds::connect_net -src clock_in|out_clk -dest ocm_read_dma_write|clk1
vds::connect_net -src clock_in|out_clk -dest ocm_write_dma_read|clk1
vds::connect_net -src clock_in|out_clk -dest emif_axi_adaptor_eagle_0|clk_i
vds::connect_net -src clock_in|out_clk -dest address_span_extender_0|clock
vds::connect_net -src clock_in|out_clk -dest i2c_0|clock
vds::connect_net -src clock_in|out_clk -dest msgdma_0|clock
vds::connect_net -src clock_in|out_clk -dest intel_mailbox_client_0|in_clk
vds::connect_net -src clock_in|out_clk -dest emif_io96b_lpddr4_0|s0_axi4_clock_in
vds::connect_net -src clock_in|out_clk -dest emif_io96b_lpddr4_0|s0_axi4lite_clock
vds::set_domain_properties {qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.maxAdditionalLatency 1 qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.interconnectResetSource DEFAULT qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.responseFifoType REGISTER_BASED qsys_mm.widthAdapterImplementation GENERIC_CONVERTER qsys_mm.insertDefaultSlave FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.syncResets TRUE qsys_mm.enableAllPipelines FALSE qsys_mm.optimizeRdFifoSize FALSE } intel_niosv_g_0.data_manager
vds::set_domain_properties {qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.maxAdditionalLatency 1 qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.interconnectResetSource DEFAULT qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.responseFifoType REGISTER_BASED qsys_mm.widthAdapterImplementation GENERIC_CONVERTER qsys_mm.insertDefaultSlave FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.syncResets TRUE qsys_mm.enableAllPipelines FALSE qsys_mm.optimizeRdFifoSize FALSE } emif_ph2_axil_driver_0.axil_driver_axi4_lite
vds::set_domain_properties {qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.maxAdditionalLatency 1 qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.interconnectResetSource DEFAULT qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.responseFifoType REGISTER_BASED qsys_mm.widthAdapterImplementation GENERIC_CONVERTER qsys_mm.insertDefaultSlave FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.syncResets TRUE qsys_mm.enableAllPipelines FALSE qsys_mm.optimizeRdFifoSize FALSE } emif_axi_adaptor_eagle_0.emif_axi
vds::set_domain_properties {qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.maxAdditionalLatency 1 qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.interconnectResetSource DEFAULT qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.responseFifoType REGISTER_BASED qsys_mm.widthAdapterImplementation GENERIC_CONVERTER qsys_mm.insertDefaultSlave FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.syncResets TRUE qsys_mm.enableAllPipelines FALSE qsys_mm.optimizeRdFifoSize FALSE } address_span_extender_0.expanded_master
vds::validate_system
vds::save_system qsys_top

post_message "Script completed successfully."
