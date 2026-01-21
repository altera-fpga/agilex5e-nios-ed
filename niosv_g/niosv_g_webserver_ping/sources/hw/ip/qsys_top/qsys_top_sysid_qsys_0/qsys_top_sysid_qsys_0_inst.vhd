	component qsys_top_sysid_qsys_0 is
		generic (
			MANUAL_ID : integer := -87110914
		);
		port (
			clock    : in  std_logic                     := 'X'; -- clk
			reset_n  : in  std_logic                     := 'X'; -- reset_n
			readdata : out std_logic_vector(31 downto 0);        -- readdata
			address  : in  std_logic                     := 'X'  -- address
		);
	end component qsys_top_sysid_qsys_0;

	u0 : component qsys_top_sysid_qsys_0
		generic map (
			MANUAL_ID => INTEGER_VALUE_FOR_MANUAL_ID
		)
		port map (
			clock    => CONNECTED_TO_clock,    --           clk.clk
			reset_n  => CONNECTED_TO_reset_n,  --         reset.reset_n
			readdata => CONNECTED_TO_readdata, -- control_slave.readdata
			address  => CONNECTED_TO_address   --              .address
		);

