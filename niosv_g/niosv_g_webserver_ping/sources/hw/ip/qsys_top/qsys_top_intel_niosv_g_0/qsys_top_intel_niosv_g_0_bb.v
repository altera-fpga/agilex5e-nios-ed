module qsys_top_intel_niosv_g_0 (
		input  wire        clk,                          //                 clk.clk,           Clock Input
		input  wire        reset_reset,                  //               reset.reset,         Reset Input
		input  wire [15:0] platform_irq_rx_irq,          //     platform_irq_rx.irq
		output wire [2:0]  instruction_manager_awsize,   // instruction_manager.awsize
		output wire [7:0]  instruction_manager_awlen,    //                    .awlen
		output wire [1:0]  instruction_manager_awburst,  //                    .awburst
		output wire        instruction_manager_wlast,    //                    .wlast
		output wire [2:0]  instruction_manager_arsize,   //                    .arsize
		output wire [7:0]  instruction_manager_arlen,    //                    .arlen
		output wire [1:0]  instruction_manager_arburst,  //                    .arburst
		input  wire        instruction_manager_rlast,    //                    .rlast
		output wire [31:0] instruction_manager_awaddr,   //                    .awaddr
		output wire [2:0]  instruction_manager_awprot,   //                    .awprot
		output wire        instruction_manager_awvalid,  //                    .awvalid
		input  wire        instruction_manager_awready,  //                    .awready
		output wire [31:0] instruction_manager_wdata,    //                    .wdata
		output wire [3:0]  instruction_manager_wstrb,    //                    .wstrb
		output wire        instruction_manager_wvalid,   //                    .wvalid
		input  wire        instruction_manager_wready,   //                    .wready
		input  wire [1:0]  instruction_manager_bresp,    //                    .bresp
		input  wire        instruction_manager_bvalid,   //                    .bvalid
		output wire        instruction_manager_bready,   //                    .bready
		output wire [31:0] instruction_manager_araddr,   //                    .araddr
		output wire [2:0]  instruction_manager_arprot,   //                    .arprot
		output wire        instruction_manager_arvalid,  //                    .arvalid
		input  wire        instruction_manager_arready,  //                    .arready
		input  wire [31:0] instruction_manager_rdata,    //                    .rdata
		input  wire [1:0]  instruction_manager_rresp,    //                    .rresp
		input  wire        instruction_manager_rvalid,   //                    .rvalid
		output wire        instruction_manager_rready,   //                    .rready
		output wire [2:0]  data_manager_awsize,          //        data_manager.awsize
		output wire [7:0]  data_manager_awlen,           //                    .awlen
		output wire        data_manager_wlast,           //                    .wlast
		output wire [2:0]  data_manager_arsize,          //                    .arsize
		output wire [7:0]  data_manager_arlen,           //                    .arlen
		input  wire        data_manager_rlast,           //                    .rlast
		output wire [31:0] data_manager_awaddr,          //                    .awaddr
		output wire [2:0]  data_manager_awprot,          //                    .awprot
		output wire        data_manager_awvalid,         //                    .awvalid
		input  wire        data_manager_awready,         //                    .awready
		output wire [31:0] data_manager_wdata,           //                    .wdata
		output wire [3:0]  data_manager_wstrb,           //                    .wstrb
		output wire        data_manager_wvalid,          //                    .wvalid
		input  wire        data_manager_wready,          //                    .wready
		input  wire [1:0]  data_manager_bresp,           //                    .bresp
		input  wire        data_manager_bvalid,          //                    .bvalid
		output wire        data_manager_bready,          //                    .bready
		output wire [31:0] data_manager_araddr,          //                    .araddr
		output wire [2:0]  data_manager_arprot,          //                    .arprot
		output wire        data_manager_arvalid,         //                    .arvalid
		input  wire        data_manager_arready,         //                    .arready
		input  wire [31:0] data_manager_rdata,           //                    .rdata
		input  wire [1:0]  data_manager_rresp,           //                    .rresp
		input  wire        data_manager_rvalid,          //                    .rvalid
		output wire        data_manager_rready,          //                    .rready
		input  wire [5:0]  timer_sw_agent_address,       //      timer_sw_agent.address,       The address in the Timer and Software Interrupt Module that the core wants to write to or read from. This is relative to the Timer and Software Interrupt Module base address.
		input  wire [3:0]  timer_sw_agent_byteenable,    //                    .byteenable,    Store byte enable.
		input  wire        timer_sw_agent_read,          //                    .read,          Indicates if the core wants to load from "timer_sw_agent_address" in the Timer and Software Interrupt Module.
		output wire [31:0] timer_sw_agent_readdata,      //                    .readdata,      Load data from the Timer and Software Interrupt Module sent to the core.
		input  wire        timer_sw_agent_write,         //                    .write,         Indicates if the core wants to store to "timer_sw_agent_address" in the Timer and Software Interrupt Module.
		input  wire [31:0] timer_sw_agent_writedata,     //                    .writedata,     Store data to the Timer and Software Interrupt Module sent from the core.
		output wire        timer_sw_agent_waitrequest,   //                    .waitrequest,   Timer and Software Interrupt Module not ready to receive write or read request from the core.
		output wire        timer_sw_agent_readdatavalid, //                    .readdatavalid, Load data valid.
		input  wire [15:0] dm_agent_address,             //            dm_agent.address,       The address in the Debug Module that the core wants to write to or read from. This is relative to the Debug Module base address.
		input  wire        dm_agent_read,                //                    .read,          Indicates if the core wants to load from "dm_agent_address" in the Debug Module.
		output wire [31:0] dm_agent_readdata,            //                    .readdata,      Load data from the Debug Module sent to the core.
		input  wire        dm_agent_write,               //                    .write,         Indicates if the core wants to store to "dm_agent_address" in the Debug Module.
		input  wire [31:0] dm_agent_writedata,           //                    .writedata,     Store data to the Debug Module sent from the core.
		output wire        dm_agent_waitrequest,         //                    .waitrequest,   Debug Module not ready to receive write or read request from the core.
		output wire        dm_agent_readdatavalid        //                    .readdatavalid, Load data valid.
	);
endmodule

