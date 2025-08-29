// Copyright (C) 2022 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.
//
// -----------------------------------------------------------------------------
// File: top.sv
// -----------------------------------------------------------------------------


`timescale 1 ps / 1 ps
`default_nettype none

module top (

    input wire [3:0] pio_1_external_connection_export,
    output wire [3:0]pio_0_external_connection_export ,
    input wire clk_clk );


    wire n_init_done;
    wire top_reset;
    wire pll_outclk_0;
    wire pll_lock;
    wire n_pll_lock;
    
	//agilex reset release 
    agilex_reset_release reset_release_0 (
        .ninit_done(n_init_done)
    );


    assign top_reset = n_init_done;

 
    // Drive clock from IOPLL

    iopll iopll_inst_0 (
	
        .refclk(clk_clk),   //  refclk.clk,    The reference clock source that drives the I/O PLL.
        .locked(pll_lock),   //  locked.export, The IOPLL IP core drives this port high when the PLL acquires lock. The port remains high as long as the I/O PLL is locked. The I/O PLL asserts the locked port when the phases and frequencies of the reference clock and feedback clock are the same or within the lock circuit tolerance. When the difference between the two clock signals exceeds the lock circuit tolerance, the I/O PLL loses lock.
        .rst(top_reset),      //   reset.reset,  The asynchronous reset port for the output clocks. Drive this port high to reset all output clocks to the value of 0.
        .outclk_0(pll_outclk_0) // Out Clock for Qsys and other blocks in logic
	
    );
	
    assign n_pll_lock = !pll_lock;

    reg [3:0] pio_1_pb;
    
	// Switch debounce logic
    pb_debounce pb_debounce_inst(
        .clk(pll_outclk_0),
        .pb_in(pio_1_external_connection_export),
        .pb_out(pio_1_pb)
    );
	

    qsys_top u0 (
        .clk_clk(pll_outclk_0),     //   input,  width = 1,   clk.clk
        .pio_0_external_connection_export (pio_0_external_connection_export), // Connect to LEDs
        .pio_1_external_connection_export (pio_1_pb),  // Connect to Push Button
        .reset_controller_0_reset_in0_reset(n_pll_lock)
	);

	
endmodule
    

