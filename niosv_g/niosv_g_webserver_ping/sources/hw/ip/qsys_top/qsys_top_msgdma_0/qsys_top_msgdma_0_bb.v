module qsys_top_msgdma_0 (
		input  wire        clock_clk,                                  //                   clock.clk,               Clock Input
		input  wire        reset_n_reset_n,                            //                 reset_n.reset_n,           Reset Input
		input  wire [31:0] csr_writedata,                              //                     csr.writedata
		input  wire        csr_write,                                  //                        .write
		input  wire [3:0]  csr_byteenable,                             //                        .byteenable
		output wire [31:0] csr_readdata,                               //                        .readdata
		input  wire        csr_read,                                   //                        .read
		input  wire [2:0]  csr_address,                                //                        .address
		output wire [31:0] descriptor_read_master_address,             //  descriptor_read_master.address
		output wire        descriptor_read_master_read,                //                        .read
		input  wire [31:0] descriptor_read_master_readdata,            //                        .readdata
		input  wire        descriptor_read_master_waitrequest,         //                        .waitrequest
		input  wire        descriptor_read_master_readdatavalid,       //                        .readdatavalid
		output wire [31:0] descriptor_write_master_address,            // descriptor_write_master.address
		output wire        descriptor_write_master_write,              //                        .write
		output wire [3:0]  descriptor_write_master_byteenable,         //                        .byteenable
		output wire [31:0] descriptor_write_master_writedata,          //                        .writedata
		input  wire        descriptor_write_master_waitrequest,        //                        .waitrequest
		input  wire [1:0]  descriptor_write_master_response,           //                        .response
		input  wire        descriptor_write_master_writeresponsevalid, //                        .writeresponsevalid
		input  wire [2:0]  prefetcher_csr_address,                     //          prefetcher_csr.address
		input  wire        prefetcher_csr_read,                        //                        .read
		input  wire        prefetcher_csr_write,                       //                        .write
		input  wire [31:0] prefetcher_csr_writedata,                   //                        .writedata
		output wire [31:0] prefetcher_csr_readdata,                    //                        .readdata
		output wire        csr_irq_irq,                                //                 csr_irq.irq
		output wire [31:0] mm_read_address,                            //                 mm_read.address
		output wire        mm_read_read,                               //                        .read
		output wire [3:0]  mm_read_byteenable,                         //                        .byteenable
		input  wire [31:0] mm_read_readdata,                           //                        .readdata
		input  wire        mm_read_waitrequest,                        //                        .waitrequest
		input  wire        mm_read_readdatavalid,                      //                        .readdatavalid
		output wire [31:0] st_source_data,                             //               st_source.data
		output wire        st_source_valid,                            //                        .valid
		input  wire        st_source_ready,                            //                        .ready
		output wire        st_source_startofpacket,                    //                        .startofpacket
		output wire        st_source_endofpacket,                      //                        .endofpacket
		output wire [1:0]  st_source_empty,                            //                        .empty
		output wire        st_source_error                             //                        .error
	);
endmodule

