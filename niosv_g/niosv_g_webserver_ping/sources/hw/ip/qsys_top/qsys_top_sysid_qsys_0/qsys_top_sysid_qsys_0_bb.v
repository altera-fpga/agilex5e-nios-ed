module qsys_top_sysid_qsys_0 #(
		parameter MANUAL_ID = -87110914
	) (
		input  wire        clock,    //           clk.clk
		input  wire        reset_n,  //         reset.reset_n
		output wire [31:0] readdata, // control_slave.readdata
		input  wire        address   //              .address
	);
endmodule

