module qsys_top_intel_eth_tse_0 (
		input  wire        clk,           // control_port_clock_connection.clk,           Register access reference clock.
		input  wire        reset,         //              reset_connection.reset,         Assert this signal to reset all logic in the MAC and PCS control interface.
		input  wire [7:0]  reg_addr,      //                  control_port.address,       MAC 32-bit word-aligned register address.
		output wire [31:0] reg_data_out,  //                              .readdata,      MAC Register read data.
		input  wire        reg_rd,        //                              .read,          MAC Register read enable.
		input  wire [31:0] reg_data_in,   //                              .writedata,     MAC Register write data.
		input  wire        reg_wr,        //                              .write,         MAC Register write enable.
		output wire        reg_busy,      //                              .waitrequest,   MAC Register interface busy.
		input  wire        ff_tx_clk,     //     transmit_clock_connection.clk,           Transmit clock.
		input  wire        ff_rx_clk,     //      receive_clock_connection.clk,           Receive clock.
		output wire [31:0] ff_rx_data,    //                       receive.data,          Receive data.
		output wire        ff_rx_eop,     //                              .endofpacket,   Receive end of packet.
		output wire [5:0]  rx_err,        //                              .error,         Receive error.
		output wire [1:0]  ff_rx_mod,     //                              .empty,         Receive data modulo.
		input  wire        ff_rx_rdy,     //                              .ready,         Receive application ready.
		output wire        ff_rx_sop,     //                              .startofpacket, Receive start of packet.
		output wire        ff_rx_dval,    //                              .valid,         Receive data valid.
		input  wire [31:0] ff_tx_data,    //                      transmit.data,          Transmit data.
		input  wire        ff_tx_eop,     //                              .endofpacket,   Transmit end of packet.
		input  wire        ff_tx_err,     //                              .error,         Transmit frame error.
		input  wire [1:0]  ff_tx_mod,     //                              .empty,         Transmit data modulo.
		output wire        ff_tx_rdy,     //                              .ready,         MAC ready.
		input  wire        ff_tx_sop,     //                              .startofpacket, Transmit start of packet.
		input  wire        ff_tx_wren,    //                              .valid,         Transmit data write enable.
		output wire        magic_wakeup,  //           mac_misc_connection.magic_wakeup,  If the MAC function is in the power-down state, the MAC function asserts this signal to indicate that a magic packet has been detected and the node is requested to restore its normal frame reception mode.
		input  wire        magic_sleep_n, //                              .magic_sleep_n, Assert this active-low signal to put the node into a power-down state.
		input  wire        ff_tx_crc_fwd, //                              .ff_tx_crc_fwd, Transmit CRC insertion.
		output wire        ff_tx_septy,   //                              .ff_tx_septy,   Deasserted when the FIFO buffer is filled to or above the section empty threshold defined in the tx_section_empty register.
		output wire        tx_ff_uflow,   //                              .tx_ff_uflow,   Asserted when an underflow occurs on the transmit FIFO buffer.
		output wire        ff_tx_a_full,  //                              .ff_tx_a_full,  Asserted when the transmit FIFO buffer reaches the almost- full threshold.
		output wire        ff_tx_a_empty, //                              .ff_tx_a_empty, Asserted when the transmit FIFO buffer goes below the almost empty threshold.
		output wire [17:0] rx_err_stat,   //                              .rx_err_stat,   Indicates received frame having value of lenght/type field, VLAN or stacked VLAN frame.
		output wire [3:0]  rx_frm_type,   //                              .rx_frm_type,   Frame type.
		output wire        ff_rx_dsav,    //                              .ff_rx_dsav,    Receive frame available.
		output wire        ff_rx_a_full,  //                              .ff_rx_a_full,  Asserted when the FIFO buffer reaches the almost-full threshold.
		output wire        ff_rx_a_empty, //                              .ff_rx_a_empty, Asserted when the FIFO buffer goes below the almost-empty threshold.
		output wire        mdc,           //           mac_mdio_connection.mdc,           Management data clock.
		input  wire        mdio_in,       //                              .mdio_in,       Management data input.
		output wire        mdio_out,      //                              .mdio_out,      Management data output.
		output wire        mdio_oen,      //                              .mdio_oen,      An active-low signal that enables mdio_in or mdio_out.
		input  wire [3:0]  rgmii_in,      //          mac_rgmii_connection.rgmii_in,      RGMII Receive Data.
		output wire [3:0]  rgmii_out,     //                              .rgmii_out,     RGMII Transmit Data.
		input  wire        rx_control,    //                              .rx_control,    Receive Control Signals.
		output wire        tx_control,    //                              .tx_control,    Transmit Control Signals.
		output wire        rgmii_tx_clk,  //                              .rgmii_tx_clk,  RGMII Transmit interface clock with frequencies 125/25/2.5 MHz for speed mode 1000/100/10M respectively. Output clock from the RGMII-to-GMII converter.
		input  wire        rgmii_rx_clk,  //                              .rgmii_rx_clk,  RGMII Receive interface clock with frequencies 125/25/2.5 MHz for speed mode 1000/100/10M respectively. This is the recovered clock from external PHY module.
		input  wire        set_10,        //         mac_status_connection.set_10,        Gigabit mode selection.
		input  wire        set_1000,      //                              .set_1000,      10 Mbps selection.
		output wire        eth_mode,      //                              .eth_mode,      Ethernet mode.
		output wire        ena_10,        //                              .ena_10,        10 Mbps enable.
		input  wire        tx_clk,        //   pcs_mac_tx_clock_connection.clk,           GMII/ MII transmit clock.
		input  wire        rx_clk         //   pcs_mac_rx_clock_connection.clk,           GMII/ MII receive clock.
	);
endmodule

