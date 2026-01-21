	component qsys_top_msgdma_1 is
		port (
			clock_clk                                  : in  std_logic                     := 'X';             -- clk
			reset_n_reset_n                            : in  std_logic                     := 'X';             -- reset_n
			csr_writedata                              : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			csr_write                                  : in  std_logic                     := 'X';             -- write
			csr_byteenable                             : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			csr_readdata                               : out std_logic_vector(31 downto 0);                    -- readdata
			csr_read                                   : in  std_logic                     := 'X';             -- read
			csr_address                                : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			descriptor_read_master_address             : out std_logic_vector(31 downto 0);                    -- address
			descriptor_read_master_read                : out std_logic;                                        -- read
			descriptor_read_master_readdata            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			descriptor_read_master_waitrequest         : in  std_logic                     := 'X';             -- waitrequest
			descriptor_read_master_readdatavalid       : in  std_logic                     := 'X';             -- readdatavalid
			descriptor_write_master_address            : out std_logic_vector(31 downto 0);                    -- address
			descriptor_write_master_write              : out std_logic;                                        -- write
			descriptor_write_master_byteenable         : out std_logic_vector(3 downto 0);                     -- byteenable
			descriptor_write_master_writedata          : out std_logic_vector(31 downto 0);                    -- writedata
			descriptor_write_master_waitrequest        : in  std_logic                     := 'X';             -- waitrequest
			descriptor_write_master_response           : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- response
			descriptor_write_master_writeresponsevalid : in  std_logic                     := 'X';             -- writeresponsevalid
			prefetcher_csr_address                     : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			prefetcher_csr_read                        : in  std_logic                     := 'X';             -- read
			prefetcher_csr_write                       : in  std_logic                     := 'X';             -- write
			prefetcher_csr_writedata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			prefetcher_csr_readdata                    : out std_logic_vector(31 downto 0);                    -- readdata
			csr_irq_irq                                : out std_logic;                                        -- irq
			mm_write_address                           : out std_logic_vector(31 downto 0);                    -- address
			mm_write_write                             : out std_logic;                                        -- write
			mm_write_byteenable                        : out std_logic_vector(3 downto 0);                     -- byteenable
			mm_write_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mm_write_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			st_sink_data                               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			st_sink_valid                              : in  std_logic                     := 'X';             -- valid
			st_sink_ready                              : out std_logic;                                        -- ready
			st_sink_startofpacket                      : in  std_logic                     := 'X';             -- startofpacket
			st_sink_endofpacket                        : in  std_logic                     := 'X';             -- endofpacket
			st_sink_empty                              : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			st_sink_error                              : in  std_logic_vector(5 downto 0)  := (others => 'X')  -- error
		);
	end component qsys_top_msgdma_1;

	u0 : component qsys_top_msgdma_1
		port map (
			clock_clk                                  => CONNECTED_TO_clock_clk,                                  --                   clock.clk
			reset_n_reset_n                            => CONNECTED_TO_reset_n_reset_n,                            --                 reset_n.reset_n
			csr_writedata                              => CONNECTED_TO_csr_writedata,                              --                     csr.writedata
			csr_write                                  => CONNECTED_TO_csr_write,                                  --                        .write
			csr_byteenable                             => CONNECTED_TO_csr_byteenable,                             --                        .byteenable
			csr_readdata                               => CONNECTED_TO_csr_readdata,                               --                        .readdata
			csr_read                                   => CONNECTED_TO_csr_read,                                   --                        .read
			csr_address                                => CONNECTED_TO_csr_address,                                --                        .address
			descriptor_read_master_address             => CONNECTED_TO_descriptor_read_master_address,             --  descriptor_read_master.address
			descriptor_read_master_read                => CONNECTED_TO_descriptor_read_master_read,                --                        .read
			descriptor_read_master_readdata            => CONNECTED_TO_descriptor_read_master_readdata,            --                        .readdata
			descriptor_read_master_waitrequest         => CONNECTED_TO_descriptor_read_master_waitrequest,         --                        .waitrequest
			descriptor_read_master_readdatavalid       => CONNECTED_TO_descriptor_read_master_readdatavalid,       --                        .readdatavalid
			descriptor_write_master_address            => CONNECTED_TO_descriptor_write_master_address,            -- descriptor_write_master.address
			descriptor_write_master_write              => CONNECTED_TO_descriptor_write_master_write,              --                        .write
			descriptor_write_master_byteenable         => CONNECTED_TO_descriptor_write_master_byteenable,         --                        .byteenable
			descriptor_write_master_writedata          => CONNECTED_TO_descriptor_write_master_writedata,          --                        .writedata
			descriptor_write_master_waitrequest        => CONNECTED_TO_descriptor_write_master_waitrequest,        --                        .waitrequest
			descriptor_write_master_response           => CONNECTED_TO_descriptor_write_master_response,           --                        .response
			descriptor_write_master_writeresponsevalid => CONNECTED_TO_descriptor_write_master_writeresponsevalid, --                        .writeresponsevalid
			prefetcher_csr_address                     => CONNECTED_TO_prefetcher_csr_address,                     --          prefetcher_csr.address
			prefetcher_csr_read                        => CONNECTED_TO_prefetcher_csr_read,                        --                        .read
			prefetcher_csr_write                       => CONNECTED_TO_prefetcher_csr_write,                       --                        .write
			prefetcher_csr_writedata                   => CONNECTED_TO_prefetcher_csr_writedata,                   --                        .writedata
			prefetcher_csr_readdata                    => CONNECTED_TO_prefetcher_csr_readdata,                    --                        .readdata
			csr_irq_irq                                => CONNECTED_TO_csr_irq_irq,                                --                 csr_irq.irq
			mm_write_address                           => CONNECTED_TO_mm_write_address,                           --                mm_write.address
			mm_write_write                             => CONNECTED_TO_mm_write_write,                             --                        .write
			mm_write_byteenable                        => CONNECTED_TO_mm_write_byteenable,                        --                        .byteenable
			mm_write_writedata                         => CONNECTED_TO_mm_write_writedata,                         --                        .writedata
			mm_write_waitrequest                       => CONNECTED_TO_mm_write_waitrequest,                       --                        .waitrequest
			st_sink_data                               => CONNECTED_TO_st_sink_data,                               --                 st_sink.data
			st_sink_valid                              => CONNECTED_TO_st_sink_valid,                              --                        .valid
			st_sink_ready                              => CONNECTED_TO_st_sink_ready,                              --                        .ready
			st_sink_startofpacket                      => CONNECTED_TO_st_sink_startofpacket,                      --                        .startofpacket
			st_sink_endofpacket                        => CONNECTED_TO_st_sink_endofpacket,                        --                        .endofpacket
			st_sink_empty                              => CONNECTED_TO_st_sink_empty,                              --                        .empty
			st_sink_error                              => CONNECTED_TO_st_sink_error                               --                        .error
		);

