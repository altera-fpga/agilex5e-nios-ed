	qsys_top_intel_onchip_memory_0 u0 (
		.clk        (_connected_to_clk_),        //   input,   width = 1,   clk1.clk
		.address    (_connected_to_address_),    //   input,  width = 11,     s1.address
		.read       (_connected_to_read_),       //   input,   width = 1,       .read
		.readdata   (_connected_to_readdata_),   //  output,  width = 32,       .readdata
		.byteenable (_connected_to_byteenable_), //   input,   width = 4,       .byteenable
		.write      (_connected_to_write_),      //   input,   width = 1,       .write
		.writedata  (_connected_to_writedata_),  //   input,  width = 32,       .writedata
		.reset      (_connected_to_reset_),      //   input,   width = 1, reset1.reset
		.reset_req  (_connected_to_reset_req_)   //   input,   width = 1,       .reset_req
	);

