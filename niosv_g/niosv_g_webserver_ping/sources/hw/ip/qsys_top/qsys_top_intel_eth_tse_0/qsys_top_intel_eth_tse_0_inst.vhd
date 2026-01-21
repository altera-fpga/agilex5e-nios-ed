	component qsys_top_intel_eth_tse_0 is
		port (
			clk           : in  std_logic                     := 'X';             -- clk
			reset         : in  std_logic                     := 'X';             -- reset
			reg_addr      : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- address
			reg_data_out  : out std_logic_vector(31 downto 0);                    -- readdata
			reg_rd        : in  std_logic                     := 'X';             -- read
			reg_data_in   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			reg_wr        : in  std_logic                     := 'X';             -- write
			reg_busy      : out std_logic;                                        -- waitrequest
			ff_tx_clk     : in  std_logic                     := 'X';             -- clk
			ff_rx_clk     : in  std_logic                     := 'X';             -- clk
			ff_rx_data    : out std_logic_vector(31 downto 0);                    -- data
			ff_rx_eop     : out std_logic;                                        -- endofpacket
			rx_err        : out std_logic_vector(5 downto 0);                     -- error
			ff_rx_mod     : out std_logic_vector(1 downto 0);                     -- empty
			ff_rx_rdy     : in  std_logic                     := 'X';             -- ready
			ff_rx_sop     : out std_logic;                                        -- startofpacket
			ff_rx_dval    : out std_logic;                                        -- valid
			ff_tx_data    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			ff_tx_eop     : in  std_logic                     := 'X';             -- endofpacket
			ff_tx_err     : in  std_logic                     := 'X';             -- error
			ff_tx_mod     : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			ff_tx_rdy     : out std_logic;                                        -- ready
			ff_tx_sop     : in  std_logic                     := 'X';             -- startofpacket
			ff_tx_wren    : in  std_logic                     := 'X';             -- valid
			magic_wakeup  : out std_logic;                                        -- magic_wakeup
			magic_sleep_n : in  std_logic                     := 'X';             -- magic_sleep_n
			ff_tx_crc_fwd : in  std_logic                     := 'X';             -- ff_tx_crc_fwd
			ff_tx_septy   : out std_logic;                                        -- ff_tx_septy
			tx_ff_uflow   : out std_logic;                                        -- tx_ff_uflow
			ff_tx_a_full  : out std_logic;                                        -- ff_tx_a_full
			ff_tx_a_empty : out std_logic;                                        -- ff_tx_a_empty
			rx_err_stat   : out std_logic_vector(17 downto 0);                    -- rx_err_stat
			rx_frm_type   : out std_logic_vector(3 downto 0);                     -- rx_frm_type
			ff_rx_dsav    : out std_logic;                                        -- ff_rx_dsav
			ff_rx_a_full  : out std_logic;                                        -- ff_rx_a_full
			ff_rx_a_empty : out std_logic;                                        -- ff_rx_a_empty
			mdc           : out std_logic;                                        -- mdc
			mdio_in       : in  std_logic                     := 'X';             -- mdio_in
			mdio_out      : out std_logic;                                        -- mdio_out
			mdio_oen      : out std_logic;                                        -- mdio_oen
			rgmii_in      : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- rgmii_in
			rgmii_out     : out std_logic_vector(3 downto 0);                     -- rgmii_out
			rx_control    : in  std_logic                     := 'X';             -- rx_control
			tx_control    : out std_logic;                                        -- tx_control
			rgmii_tx_clk  : out std_logic;                                        -- rgmii_tx_clk
			rgmii_rx_clk  : in  std_logic                     := 'X';             -- rgmii_rx_clk
			set_10        : in  std_logic                     := 'X';             -- set_10
			set_1000      : in  std_logic                     := 'X';             -- set_1000
			eth_mode      : out std_logic;                                        -- eth_mode
			ena_10        : out std_logic;                                        -- ena_10
			tx_clk        : in  std_logic                     := 'X';             -- clk
			rx_clk        : in  std_logic                     := 'X'              -- clk
		);
	end component qsys_top_intel_eth_tse_0;

	u0 : component qsys_top_intel_eth_tse_0
		port map (
			clk           => CONNECTED_TO_clk,           -- control_port_clock_connection.clk
			reset         => CONNECTED_TO_reset,         --              reset_connection.reset
			reg_addr      => CONNECTED_TO_reg_addr,      --                  control_port.address
			reg_data_out  => CONNECTED_TO_reg_data_out,  --                              .readdata
			reg_rd        => CONNECTED_TO_reg_rd,        --                              .read
			reg_data_in   => CONNECTED_TO_reg_data_in,   --                              .writedata
			reg_wr        => CONNECTED_TO_reg_wr,        --                              .write
			reg_busy      => CONNECTED_TO_reg_busy,      --                              .waitrequest
			ff_tx_clk     => CONNECTED_TO_ff_tx_clk,     --     transmit_clock_connection.clk
			ff_rx_clk     => CONNECTED_TO_ff_rx_clk,     --      receive_clock_connection.clk
			ff_rx_data    => CONNECTED_TO_ff_rx_data,    --                       receive.data
			ff_rx_eop     => CONNECTED_TO_ff_rx_eop,     --                              .endofpacket
			rx_err        => CONNECTED_TO_rx_err,        --                              .error
			ff_rx_mod     => CONNECTED_TO_ff_rx_mod,     --                              .empty
			ff_rx_rdy     => CONNECTED_TO_ff_rx_rdy,     --                              .ready
			ff_rx_sop     => CONNECTED_TO_ff_rx_sop,     --                              .startofpacket
			ff_rx_dval    => CONNECTED_TO_ff_rx_dval,    --                              .valid
			ff_tx_data    => CONNECTED_TO_ff_tx_data,    --                      transmit.data
			ff_tx_eop     => CONNECTED_TO_ff_tx_eop,     --                              .endofpacket
			ff_tx_err     => CONNECTED_TO_ff_tx_err,     --                              .error
			ff_tx_mod     => CONNECTED_TO_ff_tx_mod,     --                              .empty
			ff_tx_rdy     => CONNECTED_TO_ff_tx_rdy,     --                              .ready
			ff_tx_sop     => CONNECTED_TO_ff_tx_sop,     --                              .startofpacket
			ff_tx_wren    => CONNECTED_TO_ff_tx_wren,    --                              .valid
			magic_wakeup  => CONNECTED_TO_magic_wakeup,  --           mac_misc_connection.magic_wakeup
			magic_sleep_n => CONNECTED_TO_magic_sleep_n, --                              .magic_sleep_n
			ff_tx_crc_fwd => CONNECTED_TO_ff_tx_crc_fwd, --                              .ff_tx_crc_fwd
			ff_tx_septy   => CONNECTED_TO_ff_tx_septy,   --                              .ff_tx_septy
			tx_ff_uflow   => CONNECTED_TO_tx_ff_uflow,   --                              .tx_ff_uflow
			ff_tx_a_full  => CONNECTED_TO_ff_tx_a_full,  --                              .ff_tx_a_full
			ff_tx_a_empty => CONNECTED_TO_ff_tx_a_empty, --                              .ff_tx_a_empty
			rx_err_stat   => CONNECTED_TO_rx_err_stat,   --                              .rx_err_stat
			rx_frm_type   => CONNECTED_TO_rx_frm_type,   --                              .rx_frm_type
			ff_rx_dsav    => CONNECTED_TO_ff_rx_dsav,    --                              .ff_rx_dsav
			ff_rx_a_full  => CONNECTED_TO_ff_rx_a_full,  --                              .ff_rx_a_full
			ff_rx_a_empty => CONNECTED_TO_ff_rx_a_empty, --                              .ff_rx_a_empty
			mdc           => CONNECTED_TO_mdc,           --           mac_mdio_connection.mdc
			mdio_in       => CONNECTED_TO_mdio_in,       --                              .mdio_in
			mdio_out      => CONNECTED_TO_mdio_out,      --                              .mdio_out
			mdio_oen      => CONNECTED_TO_mdio_oen,      --                              .mdio_oen
			rgmii_in      => CONNECTED_TO_rgmii_in,      --          mac_rgmii_connection.rgmii_in
			rgmii_out     => CONNECTED_TO_rgmii_out,     --                              .rgmii_out
			rx_control    => CONNECTED_TO_rx_control,    --                              .rx_control
			tx_control    => CONNECTED_TO_tx_control,    --                              .tx_control
			rgmii_tx_clk  => CONNECTED_TO_rgmii_tx_clk,  --                              .rgmii_tx_clk
			rgmii_rx_clk  => CONNECTED_TO_rgmii_rx_clk,  --                              .rgmii_rx_clk
			set_10        => CONNECTED_TO_set_10,        --         mac_status_connection.set_10
			set_1000      => CONNECTED_TO_set_1000,      --                              .set_1000
			eth_mode      => CONNECTED_TO_eth_mode,      --                              .eth_mode
			ena_10        => CONNECTED_TO_ena_10,        --                              .ena_10
			tx_clk        => CONNECTED_TO_tx_clk,        --   pcs_mac_tx_clock_connection.clk
			rx_clk        => CONNECTED_TO_rx_clk         --   pcs_mac_rx_clock_connection.clk
		);

