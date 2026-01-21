	component qsys_top_intel_niosv_g_0 is
		port (
			clk                          : in  std_logic                     := 'X';             -- clk
			reset_reset                  : in  std_logic                     := 'X';             -- reset
			platform_irq_rx_irq          : in  std_logic_vector(15 downto 0) := (others => 'X'); -- irq
			instruction_manager_awsize   : out std_logic_vector(2 downto 0);                     -- awsize
			instruction_manager_awlen    : out std_logic_vector(7 downto 0);                     -- awlen
			instruction_manager_awburst  : out std_logic_vector(1 downto 0);                     -- awburst
			instruction_manager_wlast    : out std_logic;                                        -- wlast
			instruction_manager_arsize   : out std_logic_vector(2 downto 0);                     -- arsize
			instruction_manager_arlen    : out std_logic_vector(7 downto 0);                     -- arlen
			instruction_manager_arburst  : out std_logic_vector(1 downto 0);                     -- arburst
			instruction_manager_rlast    : in  std_logic                     := 'X';             -- rlast
			instruction_manager_awaddr   : out std_logic_vector(31 downto 0);                    -- awaddr
			instruction_manager_awprot   : out std_logic_vector(2 downto 0);                     -- awprot
			instruction_manager_awvalid  : out std_logic;                                        -- awvalid
			instruction_manager_awready  : in  std_logic                     := 'X';             -- awready
			instruction_manager_wdata    : out std_logic_vector(31 downto 0);                    -- wdata
			instruction_manager_wstrb    : out std_logic_vector(3 downto 0);                     -- wstrb
			instruction_manager_wvalid   : out std_logic;                                        -- wvalid
			instruction_manager_wready   : in  std_logic                     := 'X';             -- wready
			instruction_manager_bresp    : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- bresp
			instruction_manager_bvalid   : in  std_logic                     := 'X';             -- bvalid
			instruction_manager_bready   : out std_logic;                                        -- bready
			instruction_manager_araddr   : out std_logic_vector(31 downto 0);                    -- araddr
			instruction_manager_arprot   : out std_logic_vector(2 downto 0);                     -- arprot
			instruction_manager_arvalid  : out std_logic;                                        -- arvalid
			instruction_manager_arready  : in  std_logic                     := 'X';             -- arready
			instruction_manager_rdata    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- rdata
			instruction_manager_rresp    : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- rresp
			instruction_manager_rvalid   : in  std_logic                     := 'X';             -- rvalid
			instruction_manager_rready   : out std_logic;                                        -- rready
			data_manager_awsize          : out std_logic_vector(2 downto 0);                     -- awsize
			data_manager_awlen           : out std_logic_vector(7 downto 0);                     -- awlen
			data_manager_wlast           : out std_logic;                                        -- wlast
			data_manager_arsize          : out std_logic_vector(2 downto 0);                     -- arsize
			data_manager_arlen           : out std_logic_vector(7 downto 0);                     -- arlen
			data_manager_rlast           : in  std_logic                     := 'X';             -- rlast
			data_manager_awaddr          : out std_logic_vector(31 downto 0);                    -- awaddr
			data_manager_awprot          : out std_logic_vector(2 downto 0);                     -- awprot
			data_manager_awvalid         : out std_logic;                                        -- awvalid
			data_manager_awready         : in  std_logic                     := 'X';             -- awready
			data_manager_wdata           : out std_logic_vector(31 downto 0);                    -- wdata
			data_manager_wstrb           : out std_logic_vector(3 downto 0);                     -- wstrb
			data_manager_wvalid          : out std_logic;                                        -- wvalid
			data_manager_wready          : in  std_logic                     := 'X';             -- wready
			data_manager_bresp           : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- bresp
			data_manager_bvalid          : in  std_logic                     := 'X';             -- bvalid
			data_manager_bready          : out std_logic;                                        -- bready
			data_manager_araddr          : out std_logic_vector(31 downto 0);                    -- araddr
			data_manager_arprot          : out std_logic_vector(2 downto 0);                     -- arprot
			data_manager_arvalid         : out std_logic;                                        -- arvalid
			data_manager_arready         : in  std_logic                     := 'X';             -- arready
			data_manager_rdata           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- rdata
			data_manager_rresp           : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- rresp
			data_manager_rvalid          : in  std_logic                     := 'X';             -- rvalid
			data_manager_rready          : out std_logic;                                        -- rready
			timer_sw_agent_address       : in  std_logic_vector(5 downto 0)  := (others => 'X'); -- address
			timer_sw_agent_byteenable    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			timer_sw_agent_read          : in  std_logic                     := 'X';             -- read
			timer_sw_agent_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			timer_sw_agent_write         : in  std_logic                     := 'X';             -- write
			timer_sw_agent_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			timer_sw_agent_waitrequest   : out std_logic;                                        -- waitrequest
			timer_sw_agent_readdatavalid : out std_logic;                                        -- readdatavalid
			dm_agent_address             : in  std_logic_vector(15 downto 0) := (others => 'X'); -- address
			dm_agent_read                : in  std_logic                     := 'X';             -- read
			dm_agent_readdata            : out std_logic_vector(31 downto 0);                    -- readdata
			dm_agent_write               : in  std_logic                     := 'X';             -- write
			dm_agent_writedata           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			dm_agent_waitrequest         : out std_logic;                                        -- waitrequest
			dm_agent_readdatavalid       : out std_logic                                         -- readdatavalid
		);
	end component qsys_top_intel_niosv_g_0;

	u0 : component qsys_top_intel_niosv_g_0
		port map (
			clk                          => CONNECTED_TO_clk,                          --                 clk.clk
			reset_reset                  => CONNECTED_TO_reset_reset,                  --               reset.reset
			platform_irq_rx_irq          => CONNECTED_TO_platform_irq_rx_irq,          --     platform_irq_rx.irq
			instruction_manager_awsize   => CONNECTED_TO_instruction_manager_awsize,   -- instruction_manager.awsize
			instruction_manager_awlen    => CONNECTED_TO_instruction_manager_awlen,    --                    .awlen
			instruction_manager_awburst  => CONNECTED_TO_instruction_manager_awburst,  --                    .awburst
			instruction_manager_wlast    => CONNECTED_TO_instruction_manager_wlast,    --                    .wlast
			instruction_manager_arsize   => CONNECTED_TO_instruction_manager_arsize,   --                    .arsize
			instruction_manager_arlen    => CONNECTED_TO_instruction_manager_arlen,    --                    .arlen
			instruction_manager_arburst  => CONNECTED_TO_instruction_manager_arburst,  --                    .arburst
			instruction_manager_rlast    => CONNECTED_TO_instruction_manager_rlast,    --                    .rlast
			instruction_manager_awaddr   => CONNECTED_TO_instruction_manager_awaddr,   --                    .awaddr
			instruction_manager_awprot   => CONNECTED_TO_instruction_manager_awprot,   --                    .awprot
			instruction_manager_awvalid  => CONNECTED_TO_instruction_manager_awvalid,  --                    .awvalid
			instruction_manager_awready  => CONNECTED_TO_instruction_manager_awready,  --                    .awready
			instruction_manager_wdata    => CONNECTED_TO_instruction_manager_wdata,    --                    .wdata
			instruction_manager_wstrb    => CONNECTED_TO_instruction_manager_wstrb,    --                    .wstrb
			instruction_manager_wvalid   => CONNECTED_TO_instruction_manager_wvalid,   --                    .wvalid
			instruction_manager_wready   => CONNECTED_TO_instruction_manager_wready,   --                    .wready
			instruction_manager_bresp    => CONNECTED_TO_instruction_manager_bresp,    --                    .bresp
			instruction_manager_bvalid   => CONNECTED_TO_instruction_manager_bvalid,   --                    .bvalid
			instruction_manager_bready   => CONNECTED_TO_instruction_manager_bready,   --                    .bready
			instruction_manager_araddr   => CONNECTED_TO_instruction_manager_araddr,   --                    .araddr
			instruction_manager_arprot   => CONNECTED_TO_instruction_manager_arprot,   --                    .arprot
			instruction_manager_arvalid  => CONNECTED_TO_instruction_manager_arvalid,  --                    .arvalid
			instruction_manager_arready  => CONNECTED_TO_instruction_manager_arready,  --                    .arready
			instruction_manager_rdata    => CONNECTED_TO_instruction_manager_rdata,    --                    .rdata
			instruction_manager_rresp    => CONNECTED_TO_instruction_manager_rresp,    --                    .rresp
			instruction_manager_rvalid   => CONNECTED_TO_instruction_manager_rvalid,   --                    .rvalid
			instruction_manager_rready   => CONNECTED_TO_instruction_manager_rready,   --                    .rready
			data_manager_awsize          => CONNECTED_TO_data_manager_awsize,          --        data_manager.awsize
			data_manager_awlen           => CONNECTED_TO_data_manager_awlen,           --                    .awlen
			data_manager_wlast           => CONNECTED_TO_data_manager_wlast,           --                    .wlast
			data_manager_arsize          => CONNECTED_TO_data_manager_arsize,          --                    .arsize
			data_manager_arlen           => CONNECTED_TO_data_manager_arlen,           --                    .arlen
			data_manager_rlast           => CONNECTED_TO_data_manager_rlast,           --                    .rlast
			data_manager_awaddr          => CONNECTED_TO_data_manager_awaddr,          --                    .awaddr
			data_manager_awprot          => CONNECTED_TO_data_manager_awprot,          --                    .awprot
			data_manager_awvalid         => CONNECTED_TO_data_manager_awvalid,         --                    .awvalid
			data_manager_awready         => CONNECTED_TO_data_manager_awready,         --                    .awready
			data_manager_wdata           => CONNECTED_TO_data_manager_wdata,           --                    .wdata
			data_manager_wstrb           => CONNECTED_TO_data_manager_wstrb,           --                    .wstrb
			data_manager_wvalid          => CONNECTED_TO_data_manager_wvalid,          --                    .wvalid
			data_manager_wready          => CONNECTED_TO_data_manager_wready,          --                    .wready
			data_manager_bresp           => CONNECTED_TO_data_manager_bresp,           --                    .bresp
			data_manager_bvalid          => CONNECTED_TO_data_manager_bvalid,          --                    .bvalid
			data_manager_bready          => CONNECTED_TO_data_manager_bready,          --                    .bready
			data_manager_araddr          => CONNECTED_TO_data_manager_araddr,          --                    .araddr
			data_manager_arprot          => CONNECTED_TO_data_manager_arprot,          --                    .arprot
			data_manager_arvalid         => CONNECTED_TO_data_manager_arvalid,         --                    .arvalid
			data_manager_arready         => CONNECTED_TO_data_manager_arready,         --                    .arready
			data_manager_rdata           => CONNECTED_TO_data_manager_rdata,           --                    .rdata
			data_manager_rresp           => CONNECTED_TO_data_manager_rresp,           --                    .rresp
			data_manager_rvalid          => CONNECTED_TO_data_manager_rvalid,          --                    .rvalid
			data_manager_rready          => CONNECTED_TO_data_manager_rready,          --                    .rready
			timer_sw_agent_address       => CONNECTED_TO_timer_sw_agent_address,       --      timer_sw_agent.address
			timer_sw_agent_byteenable    => CONNECTED_TO_timer_sw_agent_byteenable,    --                    .byteenable
			timer_sw_agent_read          => CONNECTED_TO_timer_sw_agent_read,          --                    .read
			timer_sw_agent_readdata      => CONNECTED_TO_timer_sw_agent_readdata,      --                    .readdata
			timer_sw_agent_write         => CONNECTED_TO_timer_sw_agent_write,         --                    .write
			timer_sw_agent_writedata     => CONNECTED_TO_timer_sw_agent_writedata,     --                    .writedata
			timer_sw_agent_waitrequest   => CONNECTED_TO_timer_sw_agent_waitrequest,   --                    .waitrequest
			timer_sw_agent_readdatavalid => CONNECTED_TO_timer_sw_agent_readdatavalid, --                    .readdatavalid
			dm_agent_address             => CONNECTED_TO_dm_agent_address,             --            dm_agent.address
			dm_agent_read                => CONNECTED_TO_dm_agent_read,                --                    .read
			dm_agent_readdata            => CONNECTED_TO_dm_agent_readdata,            --                    .readdata
			dm_agent_write               => CONNECTED_TO_dm_agent_write,               --                    .write
			dm_agent_writedata           => CONNECTED_TO_dm_agent_writedata,           --                    .writedata
			dm_agent_waitrequest         => CONNECTED_TO_dm_agent_waitrequest,         --                    .waitrequest
			dm_agent_readdatavalid       => CONNECTED_TO_dm_agent_readdatavalid        --                    .readdatavalid
		);

