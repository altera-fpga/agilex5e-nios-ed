	component qsys_top is
		port (
			clk_clk                                                   : in  std_logic                     := 'X';             -- clk
			reset_reset                                               : in  std_logic                     := 'X';             -- reset
			sys_led_pio_external_connection_export                    : out std_logic_vector(3 downto 0);                     -- export
			triple_speed_ethernet_0_mac_misc_connection_magic_wakeup  : out std_logic;                                        -- magic_wakeup
			triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n : in  std_logic                     := 'X';             -- magic_sleep_n
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd : in  std_logic                     := 'X';             -- ff_tx_crc_fwd
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy   : out std_logic;                                        -- ff_tx_septy
			triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow   : out std_logic;                                        -- tx_ff_uflow
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full  : out std_logic;                                        -- ff_tx_a_full
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty : out std_logic;                                        -- ff_tx_a_empty
			triple_speed_ethernet_0_mac_misc_connection_rx_err_stat   : out std_logic_vector(17 downto 0);                    -- rx_err_stat
			triple_speed_ethernet_0_mac_misc_connection_rx_frm_type   : out std_logic_vector(3 downto 0);                     -- rx_frm_type
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav    : out std_logic;                                        -- ff_rx_dsav
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full  : out std_logic;                                        -- ff_rx_a_full
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty : out std_logic;                                        -- ff_rx_a_empty
			sys_tse_mac_mdio_connection_mdc                           : out std_logic;                                        -- mdc
			sys_tse_mac_mdio_connection_mdio_in                       : in  std_logic                     := 'X';             -- mdio_in
			sys_tse_mac_mdio_connection_mdio_out                      : out std_logic;                                        -- mdio_out
			sys_tse_mac_mdio_connection_mdio_oen                      : out std_logic;                                        -- mdio_oen
			sys_tse_mac_rgmii_connection_rgmii_in                     : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- rgmii_in
			sys_tse_mac_rgmii_connection_rgmii_out                    : out std_logic_vector(3 downto 0);                     -- rgmii_out
			sys_tse_mac_rgmii_connection_rx_control                   : in  std_logic                     := 'X';             -- rx_control
			sys_tse_mac_rgmii_connection_tx_control                   : out std_logic;                                        -- tx_control
			sys_tse_mac_rgmii_connection_rgmii_tx_clk                 : out std_logic;                                        -- rgmii_tx_clk
			sys_tse_mac_rgmii_connection_rgmii_rx_clk                 : in  std_logic                     := 'X';             -- rgmii_rx_clk
			sys_tse_mac_status_connection_set_10                      : in  std_logic                     := 'X';             -- set_10
			sys_tse_mac_status_connection_set_1000                    : in  std_logic                     := 'X';             -- set_1000
			sys_tse_mac_status_connection_eth_mode                    : out std_logic;                                        -- eth_mode
			sys_tse_mac_status_connection_ena_10                      : out std_logic;                                        -- ena_10
			sys_tse_pcs_mac_tx_clock_connection_clk                   : in  std_logic                     := 'X';             -- clk
			sys_tse_pcs_mac_rx_clock_connection_clk                   : in  std_logic                     := 'X'              -- clk
		);
	end component qsys_top;

	u0 : component qsys_top
		port map (
			clk_clk                                                   => CONNECTED_TO_clk_clk,                                                   --                                         clk.clk
			reset_reset                                               => CONNECTED_TO_reset_reset,                                               --                                       reset.reset
			sys_led_pio_external_connection_export                    => CONNECTED_TO_sys_led_pio_external_connection_export,                    --             sys_led_pio_external_connection.export
			triple_speed_ethernet_0_mac_misc_connection_magic_wakeup  => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_magic_wakeup,  -- triple_speed_ethernet_0_mac_misc_connection.magic_wakeup
			triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_magic_sleep_n, --                                            .magic_sleep_n
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd, --                                            .ff_tx_crc_fwd
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy   => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy,   --                                            .ff_tx_septy
			triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow   => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow,   --                                            .tx_ff_uflow
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full  => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full,  --                                            .ff_tx_a_full
			triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty, --                                            .ff_tx_a_empty
			triple_speed_ethernet_0_mac_misc_connection_rx_err_stat   => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_rx_err_stat,   --                                            .rx_err_stat
			triple_speed_ethernet_0_mac_misc_connection_rx_frm_type   => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_rx_frm_type,   --                                            .rx_frm_type
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav    => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav,    --                                            .ff_rx_dsav
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full  => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full,  --                                            .ff_rx_a_full
			triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty => CONNECTED_TO_triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty, --                                            .ff_rx_a_empty
			sys_tse_mac_mdio_connection_mdc                           => CONNECTED_TO_sys_tse_mac_mdio_connection_mdc,                           --                 sys_tse_mac_mdio_connection.mdc
			sys_tse_mac_mdio_connection_mdio_in                       => CONNECTED_TO_sys_tse_mac_mdio_connection_mdio_in,                       --                                            .mdio_in
			sys_tse_mac_mdio_connection_mdio_out                      => CONNECTED_TO_sys_tse_mac_mdio_connection_mdio_out,                      --                                            .mdio_out
			sys_tse_mac_mdio_connection_mdio_oen                      => CONNECTED_TO_sys_tse_mac_mdio_connection_mdio_oen,                      --                                            .mdio_oen
			sys_tse_mac_rgmii_connection_rgmii_in                     => CONNECTED_TO_sys_tse_mac_rgmii_connection_rgmii_in,                     --                sys_tse_mac_rgmii_connection.rgmii_in
			sys_tse_mac_rgmii_connection_rgmii_out                    => CONNECTED_TO_sys_tse_mac_rgmii_connection_rgmii_out,                    --                                            .rgmii_out
			sys_tse_mac_rgmii_connection_rx_control                   => CONNECTED_TO_sys_tse_mac_rgmii_connection_rx_control,                   --                                            .rx_control
			sys_tse_mac_rgmii_connection_tx_control                   => CONNECTED_TO_sys_tse_mac_rgmii_connection_tx_control,                   --                                            .tx_control
			sys_tse_mac_rgmii_connection_rgmii_tx_clk                 => CONNECTED_TO_sys_tse_mac_rgmii_connection_rgmii_tx_clk,                 --                                            .rgmii_tx_clk
			sys_tse_mac_rgmii_connection_rgmii_rx_clk                 => CONNECTED_TO_sys_tse_mac_rgmii_connection_rgmii_rx_clk,                 --                                            .rgmii_rx_clk
			sys_tse_mac_status_connection_set_10                      => CONNECTED_TO_sys_tse_mac_status_connection_set_10,                      --               sys_tse_mac_status_connection.set_10
			sys_tse_mac_status_connection_set_1000                    => CONNECTED_TO_sys_tse_mac_status_connection_set_1000,                    --                                            .set_1000
			sys_tse_mac_status_connection_eth_mode                    => CONNECTED_TO_sys_tse_mac_status_connection_eth_mode,                    --                                            .eth_mode
			sys_tse_mac_status_connection_ena_10                      => CONNECTED_TO_sys_tse_mac_status_connection_ena_10,                      --                                            .ena_10
			sys_tse_pcs_mac_tx_clock_connection_clk                   => CONNECTED_TO_sys_tse_pcs_mac_tx_clock_connection_clk,                   --         sys_tse_pcs_mac_tx_clock_connection.clk
			sys_tse_pcs_mac_rx_clock_connection_clk                   => CONNECTED_TO_sys_tse_pcs_mac_rx_clock_connection_clk                    --         sys_tse_pcs_mac_rx_clock_connection.clk
		);

