	component qsys_top_msgdma_0 is
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
			mm_read_address                            : out std_logic_vector(31 downto 0);                    -- address
			mm_read_read                               : out std_logic;                                        -- read
			mm_read_byteenable                         : out std_logic_vector(3 downto 0);                     -- byteenable
			mm_read_readdata                           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mm_read_waitrequest                        : in  std_logic                     := 'X';             -- waitrequest
			mm_read_readdatavalid                      : in  std_logic                     := 'X';             -- readdatavalid
			st_source_data                             : out std_logic_vector(31 downto 0);                    -- data
			st_source_valid                            : out std_logic;                                        -- valid
			st_source_ready                            : in  std_logic                     := 'X';             -- ready
			st_source_startofpacket                    : out std_logic;                                        -- startofpacket
			st_source_endofpacket                      : out std_logic;                                        -- endofpacket
			st_source_empty                            : out std_logic_vector(1 downto 0);                     -- empty
			st_source_error                            : out std_logic                                         -- error
		);
	end component qsys_top_msgdma_0;

	u0 : component qsys_top_msgdma_0
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
			mm_read_address                            => CONNECTED_TO_mm_read_address,                            --                 mm_read.address
			mm_read_read                               => CONNECTED_TO_mm_read_read,                               --                        .read
			mm_read_byteenable                         => CONNECTED_TO_mm_read_byteenable,                         --                        .byteenable
			mm_read_readdata                           => CONNECTED_TO_mm_read_readdata,                           --                        .readdata
			mm_read_waitrequest                        => CONNECTED_TO_mm_read_waitrequest,                        --                        .waitrequest
			mm_read_readdatavalid                      => CONNECTED_TO_mm_read_readdatavalid,                      --                        .readdatavalid
			st_source_data                             => CONNECTED_TO_st_source_data,                             --               st_source.data
			st_source_valid                            => CONNECTED_TO_st_source_valid,                            --                        .valid
			st_source_ready                            => CONNECTED_TO_st_source_ready,                            --                        .ready
			st_source_startofpacket                    => CONNECTED_TO_st_source_startofpacket,                    --                        .startofpacket
			st_source_endofpacket                      => CONNECTED_TO_st_source_endofpacket,                      --                        .endofpacket
			st_source_empty                            => CONNECTED_TO_st_source_empty,                            --                        .empty
			st_source_error                            => CONNECTED_TO_st_source_error                             --                        .error
		);

