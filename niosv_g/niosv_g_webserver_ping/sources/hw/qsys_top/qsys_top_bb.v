module qsys_top (
		input  wire        clk_clk,                                                   //                                         clk.clk
		input  wire        reset_reset,                                               //                                       reset.reset
		output wire [3:0]  sys_led_pio_external_connection_export,                    //             sys_led_pio_external_connection.export
		output wire        triple_speed_ethernet_0_mac_misc_connection_magic_wakeup,  // triple_speed_ethernet_0_mac_misc_connection.magic_wakeup
		input  wire        triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n, //                                            .magic_sleep_n
		input  wire        triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd, //                                            .ff_tx_crc_fwd
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy,   //                                            .ff_tx_septy
		output wire        triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow,   //                                            .tx_ff_uflow
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full,  //                                            .ff_tx_a_full
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty, //                                            .ff_tx_a_empty
		output wire [17:0] triple_speed_ethernet_0_mac_misc_connection_rx_err_stat,   //                                            .rx_err_stat
		output wire [3:0]  triple_speed_ethernet_0_mac_misc_connection_rx_frm_type,   //                                            .rx_frm_type
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav,    //                                            .ff_rx_dsav
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full,  //                                            .ff_rx_a_full
		output wire        triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty, //                                            .ff_rx_a_empty
		output wire        sys_tse_mac_mdio_connection_mdc,                           //                 sys_tse_mac_mdio_connection.mdc
		input  wire        sys_tse_mac_mdio_connection_mdio_in,                       //                                            .mdio_in
		output wire        sys_tse_mac_mdio_connection_mdio_out,                      //                                            .mdio_out
		output wire        sys_tse_mac_mdio_connection_mdio_oen,                      //                                            .mdio_oen
		input  wire [3:0]  sys_tse_mac_rgmii_connection_rgmii_in,                     //                sys_tse_mac_rgmii_connection.rgmii_in
		output wire [3:0]  sys_tse_mac_rgmii_connection_rgmii_out,                    //                                            .rgmii_out
		input  wire        sys_tse_mac_rgmii_connection_rx_control,                   //                                            .rx_control
		output wire        sys_tse_mac_rgmii_connection_tx_control,                   //                                            .tx_control
		output wire        sys_tse_mac_rgmii_connection_rgmii_tx_clk,                 //                                            .rgmii_tx_clk
		input  wire        sys_tse_mac_rgmii_connection_rgmii_rx_clk,                 //                                            .rgmii_rx_clk
		input  wire        sys_tse_mac_status_connection_set_10,                      //               sys_tse_mac_status_connection.set_10
		input  wire        sys_tse_mac_status_connection_set_1000,                    //                                            .set_1000
		output wire        sys_tse_mac_status_connection_eth_mode,                    //                                            .eth_mode
		output wire        sys_tse_mac_status_connection_ena_10,                      //                                            .ena_10
		input  wire        sys_tse_pcs_mac_tx_clock_connection_clk,                   //         sys_tse_pcs_mac_tx_clock_connection.clk
		input  wire        sys_tse_pcs_mac_rx_clock_connection_clk                    //         sys_tse_pcs_mac_rx_clock_connection.clk
	);
endmodule

