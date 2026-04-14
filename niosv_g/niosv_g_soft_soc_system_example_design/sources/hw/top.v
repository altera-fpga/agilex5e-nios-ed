// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module top (
	input clk,
	inout scl_wire, sda_wire,
	input  wire        ref_clk_0_clk,                   //           ref_clk_0.clk
	output wire        emif_mem_0_mem_ck_t,    // emif_mem_0.mem_ck_t
	output wire        emif_mem_0_mem_ck_c,    //                    .mem_ck_c
	output wire        emif_mem_0_mem_cke,     //                    .mem_cke
	output wire        emif_mem_0_mem_reset_n, //                    .mem_reset_n
	output wire        emif_mem_0_mem_cs,      //                    .mem_cs
	output wire [5:0]  emif_mem_0_mem_ca,      //                    .mem_ca
	inout  wire [31:0] emif_mem_0_mem_dq,      //                    .mem_dq
	inout  wire [3:0]  emif_mem_0_mem_dqs_t,   //                    .mem_dqs_t
	inout  wire [3:0]  emif_mem_0_mem_dqs_c,   //                    .mem_dqs_c
	inout  wire [3:0]  emif_mem_0_mem_dmi,     //                    .mem_dmi
	input  wire        emif_oct_0_oct_rzqin,   // emif_oct_0.oct_rzqin
	output wire [3:0]  user_led,
	input wire  [3:0]  pb_input
);

wire scl_wire, sda_wire;
wire host_scl, host_scloe, host_sda, host_sdaoe;
wire agent_scl, agent_scloe, agent_sda, agent_sdaoe;

wire spi_miso, spi_mosi, spi_sclk, spi_ss_n;

wire [3:0] pio_1_pb;
wire [3:0] qsys_led_output;


wire n_init_done;
wire top_reset;
wire pll_outclk_0;
wire pll_lock;
wire n_pll_lock;

    reset_release reset_release_0 (
        .ninit_done(n_init_done)
    );

	 assign top_reset = n_init_done;


    iopll iopll_inst_0 (
        .refclk(clk),   //  refclk.clk,    The reference clock source that drives the I/O PLL.
        .locked(pll_lock),   //  locked.export, The IOPLL IP core drives this port high when the PLL acquires lock. The port remains high as long as the I/O PLL is locked. The I/O PLL asserts the locked port when the phases and frequencies of the reference clock and feedback clock are the same or within the lock circuit tolerance. When the difference between the two clock signals exceeds the lock circuit tolerance, the I/O PLL loses lock.
        .rst(top_reset),      //   reset.reset,  The asynchronous reset port for the output clocks. Drive this port high to reset all output clocks to the value of 0.
        .outclk_0(pll_outclk_0) // Out Clock for Qsys and other blocks in logic
    );
		assign n_pll_lock = !pll_lock;	

    pb_debounce pb_debounce_inst(
        .clk_clk(pll_outclk_0),
        .pb_in(pb_input),
        .pb_out(pio_1_pb)
    ); 

		assign user_led = pio_1_pb & qsys_led_output;
		

	qsys_top u0 (
		.clk_clk                 (pll_outclk_0),     		//   input,  width = 1,              clk.clk
		.reset_top_reset  		 (n_pll_lock),			//reset input
		.i2c_0_i2c_serial_sda_in (host_sda), 		//   input,  width = 1, i2c_0_i2c_serial.sda_in
		.i2c_0_i2c_serial_scl_in (host_scl), 		//   input,  width = 1,                 .scl_in
		.i2c_0_i2c_serial_sda_oe (host_sdaoe), 	//  output,  width = 1,                 .sda_oe
		.i2c_0_i2c_serial_scl_oe (host_scloe), 	//  output,  width = 1,                 .scl_oe
		.spi_0_external_MISO     (spi_miso),     	//   input,  width = 1,   spi_0_external.MISO
		.spi_0_external_MOSI     (spi_mosi),     	//  output,  width = 1,                 .MOSI
		.spi_0_external_SCLK     (spi_sclk),     	//  output,  width = 1,                 .SCLK
		.spi_0_external_SS_n     (spi_ss_n),      	//  output,  width = 1,                 .SS_n
	   .emif_io96b_lpddr4_0_mem_0_mem_cs            (emif_mem_0_mem_cs),            //  output,   width = 1,       emif_io96b_lpddr4_0_mem_0.mem_cs
      .emif_io96b_lpddr4_0_mem_0_mem_ca            (emif_mem_0_mem_ca),            //  output,   width = 6,                                .mem_ca
      .emif_io96b_lpddr4_0_mem_0_mem_cke           (emif_mem_0_mem_cke),           //  output,   width = 1,                                .mem_cke
      .emif_io96b_lpddr4_0_mem_0_mem_dq            (emif_mem_0_mem_dq),            //   inout,  width = 16,                                .mem_dq
      .emif_io96b_lpddr4_0_mem_0_mem_dqs_t         (emif_mem_0_mem_dqs_t),         //   inout,   width = 2,                                .mem_dqs_t
      .emif_io96b_lpddr4_0_mem_0_mem_dqs_c         (emif_mem_0_mem_dqs_c),         //   inout,   width = 2,                                .mem_dqs_c
      .emif_io96b_lpddr4_0_mem_0_mem_dmi           (emif_mem_0_mem_dmi),           //   inout,   width = 2,                                .mem_dmi
      .emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t       (emif_mem_0_mem_ck_t),       //  output,   width = 1,    emif_io96b_lpddr4_0_mem_ck_0.mem_ck_t
      .emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c       (emif_mem_0_mem_ck_c),       //  output,   width = 1,                                .mem_ck_c
      .emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n (emif_mem_0_mem_reset_n), //  output,   width = 1, emif_io96b_lpddr4_0_mem_reset_n.mem_reset_n
      .emif_io96b_lpddr4_0_oct_0_oct_rzqin         (emif_oct_0_oct_rzqin),         //   input,   width = 1,       emif_io96b_lpddr4_0_oct_0.oct_rzqin
      .emif_io96b_lpddr4_0_ref_clk_clk             (ref_clk_0_clk),             //   input,   width = 1,     emif_io96b_lpddr4_0_ref_clk.clk
      .pio_0_external_connection_export            (qsys_led_output),            //  output,   width = 4,       pio_0_external_connection.export
		.pio_1_external_connection_export 				(pio_1_pb)
	);

	qsys_agent v0 (
		.clk_clk                                                (pll_outclk_0),          //   input,  width = 1,                                    clk.clk
		.reset_agent_reset                                      (n_pll_lock),                                                                               //   input,  width = 1,                                     reset_agent.reset
		.i2cslave_to_avlmm_bridge_0_conduit_end_conduit_data_in (agent_sda), 	//   input,  width = 1, i2cslave_to_avlmm_bridge_0_conduit_end.conduit_data_in
		.i2cslave_to_avlmm_bridge_0_conduit_end_conduit_clk_in  (agent_scl),  	//   input,  width = 1,                                       .conduit_clk_in
		.i2cslave_to_avlmm_bridge_0_conduit_end_conduit_data_oe (agent_sdaoe), 	//  output,  width = 1,                                       .conduit_data_oe
		.i2cslave_to_avlmm_bridge_0_conduit_end_conduit_clk_oe  (agent_scloe), 	//  output,  width = 1,                                       .conduit_clk_oe
		.spi_slave_to_avalon_mm_master_bridge_0_export_0_mosi_to_the_spislave_inst_for_spichain          (spi_mosi),         //   input,  width = 1, spi_slave_to_avalon_mm_master_bridge_0_export_0.mosi_to_the_spislave_inst_for_spichain
		.spi_slave_to_avalon_mm_master_bridge_0_export_0_nss_to_the_spislave_inst_for_spichain           (spi_ss_n),         //   input,  width = 1,                                                .nss_to_the_spislave_inst_for_spichain
		.spi_slave_to_avalon_mm_master_bridge_0_export_0_sclk_to_the_spislave_inst_for_spichain          (spi_sclk),         //   input,  width = 1,                                                .sclk_to_the_spislave_inst_for_spichain
		.spi_slave_to_avalon_mm_master_bridge_0_export_0_miso_to_and_from_the_spislave_inst_for_spichain (spi_miso)  			//   inout,  width = 1,                                                .miso_to_and_from_the_spislave_inst_for_spichain
	);

	
// open drain buffer for I2C Host Core in qsys_top and I2C Agent to AvMM bridge Core in qsys_agent
assign host_scl = scl_wire; 
assign agent_scl = scl_wire; 
assign scl_wire = (host_scloe||agent_scloe) ? 1'b0 : 1'bz;  
assign host_sda = sda_wire; 
assign agent_sda = sda_wire; 
assign sda_wire = (host_sdaoe||agent_sdaoe) ? 1'b0 : 1'bz; 

	 
endmodule