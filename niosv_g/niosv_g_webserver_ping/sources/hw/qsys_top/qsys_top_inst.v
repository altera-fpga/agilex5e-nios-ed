	qsys_top u0 (
		.clk_clk                                                   (_connected_to_clk_clk_),                                                   //   input,   width = 1,                                         clk.clk
		.reset_reset                                               (_connected_to_reset_reset_),                                               //   input,   width = 1,                                       reset.reset
		.sys_led_pio_external_connection_export                    (_connected_to_sys_led_pio_external_connection_export_),                    //  output,   width = 4,             sys_led_pio_external_connection.export
		.triple_speed_ethernet_0_mac_misc_connection_magic_wakeup  (_connected_to_triple_speed_ethernet_0_mac_misc_connection_magic_wakeup_),  //  output,   width = 1, triple_speed_ethernet_0_mac_misc_connection.magic_wakeup
		.triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n (_connected_to_triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n_), //   input,   width = 1,                                            .magic_sleep_n
		.triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd_), //   input,   width = 1,                                            .ff_tx_crc_fwd
		.triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy   (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy_),   //  output,   width = 1,                                            .ff_tx_septy
		.triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow   (_connected_to_triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow_),   //  output,   width = 1,                                            .tx_ff_uflow
		.triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full  (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full_),  //  output,   width = 1,                                            .ff_tx_a_full
		.triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty_), //  output,   width = 1,                                            .ff_tx_a_empty
		.triple_speed_ethernet_0_mac_misc_connection_rx_err_stat   (_connected_to_triple_speed_ethernet_0_mac_misc_connection_rx_err_stat_),   //  output,  width = 18,                                            .rx_err_stat
		.triple_speed_ethernet_0_mac_misc_connection_rx_frm_type   (_connected_to_triple_speed_ethernet_0_mac_misc_connection_rx_frm_type_),   //  output,   width = 4,                                            .rx_frm_type
		.triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav    (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav_),    //  output,   width = 1,                                            .ff_rx_dsav
		.triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full  (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full_),  //  output,   width = 1,                                            .ff_rx_a_full
		.triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty (_connected_to_triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty_), //  output,   width = 1,                                            .ff_rx_a_empty
		.sys_tse_mac_mdio_connection_mdc                           (_connected_to_sys_tse_mac_mdio_connection_mdc_),                           //  output,   width = 1,                 sys_tse_mac_mdio_connection.mdc
		.sys_tse_mac_mdio_connection_mdio_in                       (_connected_to_sys_tse_mac_mdio_connection_mdio_in_),                       //   input,   width = 1,                                            .mdio_in
		.sys_tse_mac_mdio_connection_mdio_out                      (_connected_to_sys_tse_mac_mdio_connection_mdio_out_),                      //  output,   width = 1,                                            .mdio_out
		.sys_tse_mac_mdio_connection_mdio_oen                      (_connected_to_sys_tse_mac_mdio_connection_mdio_oen_),                      //  output,   width = 1,                                            .mdio_oen
		.sys_tse_mac_rgmii_connection_rgmii_in                     (_connected_to_sys_tse_mac_rgmii_connection_rgmii_in_),                     //   input,   width = 4,                sys_tse_mac_rgmii_connection.rgmii_in
		.sys_tse_mac_rgmii_connection_rgmii_out                    (_connected_to_sys_tse_mac_rgmii_connection_rgmii_out_),                    //  output,   width = 4,                                            .rgmii_out
		.sys_tse_mac_rgmii_connection_rx_control                   (_connected_to_sys_tse_mac_rgmii_connection_rx_control_),                   //   input,   width = 1,                                            .rx_control
		.sys_tse_mac_rgmii_connection_tx_control                   (_connected_to_sys_tse_mac_rgmii_connection_tx_control_),                   //  output,   width = 1,                                            .tx_control
		.sys_tse_mac_rgmii_connection_rgmii_tx_clk                 (_connected_to_sys_tse_mac_rgmii_connection_rgmii_tx_clk_),                 //  output,   width = 1,                                            .rgmii_tx_clk
		.sys_tse_mac_rgmii_connection_rgmii_rx_clk                 (_connected_to_sys_tse_mac_rgmii_connection_rgmii_rx_clk_),                 //   input,   width = 1,                                            .rgmii_rx_clk
		.sys_tse_mac_status_connection_set_10                      (_connected_to_sys_tse_mac_status_connection_set_10_),                      //   input,   width = 1,               sys_tse_mac_status_connection.set_10
		.sys_tse_mac_status_connection_set_1000                    (_connected_to_sys_tse_mac_status_connection_set_1000_),                    //   input,   width = 1,                                            .set_1000
		.sys_tse_mac_status_connection_eth_mode                    (_connected_to_sys_tse_mac_status_connection_eth_mode_),                    //  output,   width = 1,                                            .eth_mode
		.sys_tse_mac_status_connection_ena_10                      (_connected_to_sys_tse_mac_status_connection_ena_10_),                      //  output,   width = 1,                                            .ena_10
		.sys_tse_pcs_mac_tx_clock_connection_clk                   (_connected_to_sys_tse_pcs_mac_tx_clock_connection_clk_),                   //   input,   width = 1,         sys_tse_pcs_mac_tx_clock_connection.clk
		.sys_tse_pcs_mac_rx_clock_connection_clk                   (_connected_to_sys_tse_pcs_mac_rx_clock_connection_clk_)                    //   input,   width = 1,         sys_tse_pcs_mac_rx_clock_connection.clk
	);

