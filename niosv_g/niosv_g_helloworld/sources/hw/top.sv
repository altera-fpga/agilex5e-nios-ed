// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps
`default_nettype none

module top ();

   
   // What is the minumum number of cycles required to reset the BSP.
   localparam MIN_BSP_RESET_CYCLES = 1000; // For now use 1000
   localparam BSP_RESET_COUNTER_WIDTH = $clog2(MIN_BSP_RESET_CYCLES);


    //// Instantiate the internal oscilator
    wire osc_clk;
    reg [1:0] osc_clk_div2 = 0;
    wire osc_clk_div2_global;

	clock_config_ip osc (
		.clkout(osc_clk)
	);
    
    
    // Directly instantiate the GLOBAL to ensure that the
    // inverter to reg is local, but the reg to sinks is
    // global
    always_ff @(posedge osc_clk) begin
      osc_clk_div2 <= osc_clk_div2 + 1'b1;
    end

    GLOBAL u_clk(.in(osc_clk_div2[1]), .out(osc_clk_div2_global));
	 
	 
   wire tcd2um_reset;
   tcd2um #(
      .REF_CLOCK_SPEED_MHZ(250)
   ) u_tcd2um_cntr
   (
      .clk(osc_clk),
      .reset_out(tcd2um_reset)
   );
   

   // The synchronizer aclr clears to 0. Invert the CD2UM reset so we are
   // passing 1 into the synchronizer once reset is complete
   wire tcd2um_reset_sync;
   wire tcd2um_reset_sync_n;
   synchronizer #(
      .WIDTH (1),
      .STAGES(10)
   ) u_reset_sync (
      .clk_in(osc_clk),
      .arst_in(tcd2um_reset),
      .clk_out(osc_clk_div2_global),
      .arst_out(tcd2um_reset),
      .dat_in(!tcd2um_reset),
      .dat_out(tcd2um_reset_sync_n)
   );
   assign tcd2um_reset_sync = !tcd2um_reset_sync_n;
   
   
wire bsp_reset_n;
   // Instantiate an ISSP source
   wire issp_reset;
   issp_out_ip rst_src (
		.source(issp_reset),
		.probe(bsp_reset_n)
	);
   

   wire bsp_reset_source;
   assign bsp_reset_source = issp_reset | tcd2um_reset_sync;

   // Hold the reset for the require minimum time to reset the design.
   wire bsp_reset;
   reg [BSP_RESET_COUNTER_WIDTH-1:0] bsp_reset_counter;
   always_ff @(posedge osc_clk_div2_global) begin
      if (bsp_reset_source) begin
         bsp_reset_counter <= 0;
      end
      else begin
         if (bsp_reset_counter < MIN_BSP_RESET_CYCLES) begin
            bsp_reset_counter <= bsp_reset_counter + 1'b1;
         end
      end
   end
   assign bsp_reset = (bsp_reset_counter != MIN_BSP_RESET_CYCLES);
//assign bsp_reset_n = !bsp_reset;
	

	qsys_top u0 (
		.clk_clk     (osc_clk_div2_global),     //   input,  width = 1,   clk.clk
		.reset_reset (bsp_reset)  //   input,  width = 1, reset.reset
	);

	
endmodule
    

