source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_intel_niosv_g_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_clock_bridge_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_jtag_uart_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_sysid_qsys_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_reset_bridge_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_pio_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_intel_onchip_memory_1/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_intel_onchip_memory_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_msgdma_1/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_intel_eth_tse_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/qsys_top/qsys_top_msgdma_0/sim/common/modelsim_files.tcl]

namespace eval qsys_top {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [qsys_top_intel_niosv_g_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_clock_bridge_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_jtag_uart_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_sysid_qsys_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_reset_bridge_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_pio_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_intel_onchip_memory_1::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_intel_onchip_memory_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_msgdma_1::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_intel_eth_tse_0::get_design_libraries]]
    set libraries [dict merge $libraries [qsys_top_msgdma_0::get_design_libraries]]
    dict set libraries altera_merlin_axi_translator_1983    1
    dict set libraries altera_merlin_master_translator_193  1
    dict set libraries altera_merlin_slave_translator_191   1
    dict set libraries altera_merlin_axi_master_ni_19113    1
    dict set libraries altera_merlin_master_agent_1940      1
    dict set libraries altera_merlin_slave_agent_1930       1
    dict set libraries altera_avalon_sc_fifo_1932           1
    dict set libraries altera_merlin_router_1921            1
    dict set libraries altera_merlin_traffic_limiter_1921   1
    dict set libraries altera_avalon_st_pipeline_stage_1930 1
    dict set libraries altera_merlin_burst_adapter_1940     1
    dict set libraries altera_merlin_demultiplexer_1921     1
    dict set libraries altera_merlin_multiplexer_1922       1
    dict set libraries altera_mm_interconnect_1920          1
    dict set libraries altera_irq_mapper_2001               1
    dict set libraries timing_adapter_1950                  1
    dict set libraries altera_avalon_st_adapter_1920        1
    dict set libraries altera_reset_controller_1924         1
    dict set libraries qsys_top                             1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [qsys_top_intel_niosv_g_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_niosv_g_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_clock_bridge_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_clock_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_jtag_uart_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_jtag_uart_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_sysid_qsys_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_sysid_qsys_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_reset_bridge_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_reset_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_pio_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_pio_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_intel_onchip_memory_1::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_intel_onchip_memory_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_msgdma_1::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_intel_eth_tse_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_eth_tse_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [qsys_top_msgdma_0::get_memory_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [qsys_top_intel_niosv_g_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_niosv_g_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_clock_bridge_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_clock_bridge_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_jtag_uart_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_jtag_uart_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_sysid_qsys_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_sysid_qsys_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_reset_bridge_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_reset_bridge_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_pio_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_pio_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_intel_onchip_memory_1::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_1/sim/"]]
    set design_files [dict merge $design_files [qsys_top_intel_onchip_memory_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_msgdma_1::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_1/sim/"]]
    set design_files [dict merge $design_files [qsys_top_intel_eth_tse_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_eth_tse_0/sim/"]]
    set design_files [dict merge $design_files [qsys_top_msgdma_0::get_common_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_0/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [qsys_top_intel_niosv_g_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_niosv_g_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_clock_bridge_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_clock_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_jtag_uart_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_jtag_uart_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_sysid_qsys_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_sysid_qsys_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_reset_bridge_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_reset_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_pio_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_pio_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_intel_onchip_memory_1::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_intel_onchip_memory_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_msgdma_1::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_intel_eth_tse_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_eth_tse_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [qsys_top_msgdma_0::get_design_files "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "-makelib altera_merlin_axi_translator_1983 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_translator_1983/sim/qsys_top_altera_merlin_axi_translator_1983_7ic4h3a.sv"]\"   -end"                            
    lappend design_files "-makelib altera_merlin_master_translator_193 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/qsys_top_altera_merlin_master_translator_193_lgcew2q.sv"]\"   -end"                      
    lappend design_files "-makelib altera_merlin_slave_translator_191 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/qsys_top_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_axi_master_ni_19113 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19113/sim/altera_merlin_address_alignment.sv"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_axi_master_ni_19113 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19113/sim/qsys_top_altera_merlin_axi_master_ni_19113_puqzalq.sv"]\"   -end"                            
    lappend design_files "-makelib altera_merlin_master_agent_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1940/sim/qsys_top_altera_merlin_master_agent_1940_r3ep6da.sv"]\"   -end"                                  
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/qsys_top_altera_merlin_slave_agent_1930_jxauz3i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/altera_merlin_burst_uncompressor.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/qsys_top_altera_avalon_sc_fifo_1932_22gxxgi.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_k42z6hy.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_u2e7pmi.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_rr6gq2i.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_punipba.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_nqooitq.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_d3xlnpy.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/qsys_top_altera_merlin_router_1921_4x3zc6y.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/qsys_top_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_2bjufwi.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/qsys_top_altera_merlin_traffic_limiter_1921_ihobvti.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/qsys_top_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_te3kfhq.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/qsys_top_altera_merlin_traffic_limiter_1921_5pm4apa.sv"]\"   -end"                         
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/qsys_top_altera_avalon_st_pipeline_stage_1930_oiupeiq.sv"]\"   -end"                   
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                           
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/qsys_top_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1940_7kn4afi.v"]\"   -end"
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/qsys_top_altera_merlin_burst_adapter_1940_jaal53a.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_uncmpr.sv"]\"   -end"                                              
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_13_1.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_new.sv"]\"   -end"                                                 
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_incr_burst_converter.sv"]\"   -end"                                                     
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_wrap_burst_converter.sv"]\"   -end"                                                     
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_default_burst_converter.sv"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_burst_adapter_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_address_alignment.sv"]\"   -end"                                                 
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_v3cratq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_z6z6zmi.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_44dazla.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_a75p64i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_xdusypq.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_5icdd3a.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_p4u4aaa.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_pjloaly.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_diegjbq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/qsys_top_altera_merlin_demultiplexer_1921_ahyut4y.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_xdqzama.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/qsys_top_altera_merlin_multiplexer_1922_hptihja.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/qsys_top_altera_mm_interconnect_1920_lyoviqy.v"]\"   -end"                                               
    lappend design_files "-makelib altera_irq_mapper_2001 \"[normalize_path "$QSYS_SIMDIR/../altera_irq_mapper_2001/sim/qsys_top_altera_irq_mapper_2001_efvidjq.sv"]\"   -end"                                                             
    lappend design_files "-makelib timing_adapter_1950 \"[normalize_path "$QSYS_SIMDIR/../timing_adapter_1950/sim/qsys_top_timing_adapter_1950_4blnw3y.sv"]\"   -end"                                                                      
    lappend design_files "-makelib timing_adapter_1950 \"[normalize_path "$QSYS_SIMDIR/../timing_adapter_1950/sim/qsys_top_timing_adapter_1950_4blnw3y_fifo.sv"]\"   -end"                                                                 
    lappend design_files "-makelib altera_avalon_st_adapter_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_adapter_1920/sim/qsys_top_altera_avalon_st_adapter_1920_7pp2hqi.v"]\"   -end"                                         
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                                                  
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                                                
    lappend design_files "-makelib qsys_top \"[normalize_path "$QSYS_SIMDIR/qsys_top.v"]\"   -end"                                                                                                                                         
    return $design_files
  }
  
  proc get_non_duplicate_elab_option {ELAB_OPTIONS NEW_ELAB_OPTION} {
    set IS_DUPLICATE [string first $NEW_ELAB_OPTION $ELAB_OPTIONS]
    if {$IS_DUPLICATE == -1} {
      return $NEW_ELAB_OPTION
    } else {
      return ""
    }
  }
  
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_intel_niosv_g_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_clock_bridge_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_jtag_uart_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_sysid_qsys_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_reset_bridge_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_pio_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_intel_onchip_memory_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_intel_onchip_memory_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_msgdma_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_intel_eth_tse_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [qsys_top_msgdma_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [qsys_top_intel_niosv_g_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_clock_bridge_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_jtag_uart_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_sysid_qsys_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_reset_bridge_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_pio_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_intel_onchip_memory_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_intel_onchip_memory_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_msgdma_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_intel_eth_tse_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [qsys_top_msgdma_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_intel_niosv_g_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_clock_bridge_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_jtag_uart_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_sysid_qsys_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_reset_bridge_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_pio_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_intel_onchip_memory_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_intel_onchip_memory_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_msgdma_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_intel_eth_tse_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [qsys_top_msgdma_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    set libraries [dict merge $libraries [qsys_top_intel_niosv_g_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_niosv_g_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_clock_bridge_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_clock_bridge_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_jtag_uart_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_jtag_uart_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_sysid_qsys_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_sysid_qsys_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_reset_bridge_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_reset_bridge_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_pio_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_pio_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_intel_onchip_memory_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_1/sim/"]]
    set libraries [dict merge $libraries [qsys_top_intel_onchip_memory_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_onchip_memory_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_msgdma_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_1/sim/"]]
    set libraries [dict merge $libraries [qsys_top_intel_eth_tse_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_intel_eth_tse_0/sim/"]]
    set libraries [dict merge $libraries [qsys_top_msgdma_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/qsys_top/qsys_top_msgdma_0/sim/"]]
    
    return $libraries
  }
  
}
