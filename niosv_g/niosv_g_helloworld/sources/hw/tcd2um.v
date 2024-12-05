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

module tcd2um #(
   parameter REF_CLOCK_SPEED_MHZ = 50,
   parameter TCD2UM_US = 830
)
(
   input wire clk,
   output wire reset_out
);
      
   `ifdef SIMULATION
      localparam CYCLES = 5;
   `else
      localparam CYCLES = REF_CLOCK_SPEED_MHZ * TCD2UM_US;
   `endif

   localparam RST_CNTR_WIDTH_MSB = $clog2(CYCLES);
   
   reg [RST_CNTR_WIDTH_MSB-1:0] rst_counter = 0;
   
   assign reset_out = (rst_counter != CYCLES) ? 1'b1 : 1'b0;
   
   always @(posedge clk) begin
      if(rst_counter != CYCLES) begin
         rst_counter <= rst_counter + 1'b1;
      end 
      else begin
         rst_counter <= CYCLES;
      end
   end

endmodule