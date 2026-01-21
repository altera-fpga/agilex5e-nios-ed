// (C) 2001-2025 Altera Corporation. All rights reserved.
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


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

 
// $Id: //acds/rel/13.1/ip/.../avalon-st_timing_adapter.sv.terp#1 $
// $Revision: #1 $
// $Date: 2013/09/27 $
// $Author: dmunday, korthner $

// --------------------------------------------------------------------------------
//| Avalon Streaming Timing Adapter
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
// ------------------------------------------
// Generation parameters:
//   output_name:        qsys_top_timing_adapter_1950_4blnw3y
//   in_use_ready:       true
//   out_use_ready:      true
//   in_use_valid:       true
//   out_use_valid:      true
//   use_packets:        true
//   use_empty:          1
//   empty_width:        2
//   data_width:         32
//   channel_width:      0
//   error_width:        6
//   in_ready_latency:   2
//   out_ready_latency:  0
//   in_payload_width:   42
//   out_payload_width:  42
//   in_payload_map:     in_data,in_startofpacket,in_endofpacket,in_empty,in_error
//   out_payload_map:    out_data,out_startofpacket,out_endofpacket,out_empty,out_error
//   fifo_depth:         8
//   fifo_depth_bits:    3
//   family_setting:     Agilex 5
// ------------------------------------------



module qsys_top_timing_adapter_1950_4blnw3y #(parameter SYNC_RESET = 0,
                      parameter FIFO_MEM_TYPE = 0)
(  
 output reg         in_ready,
 input               in_valid,
 input     [32-1: 0]  in_data,
 input     [6-1: 0] in_error,
 input              in_startofpacket,
 input              in_endofpacket,
 input     [2-1: 0] in_empty,
 // Interface: out
 input               out_ready,
 output reg          out_valid,
 output reg [32-1: 0] out_data,
 output reg [6-1: 0] out_error,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 output reg [2-1: 0] out_empty,
  // Interface: clk
 input              clk,
 // Interface: reset
 input              reset_n

 /*AUTOARG*/);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------
   
   reg  [42-1:0]   in_payload;
   wire [42-1:0]   out_payload;
   wire            in_ready_wire;
   wire            out_valid_wire;
   wire [3:0]      fifo_fill;
   wire [3-1:0]  fifo_usedw;
   wire            fifo_full;
   wire            fifo_empty;
   wire            fifo_wrreq;
   wire            fifo_rdreq;
   reg [1-1:0]   ready;   

   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @* begin
     in_payload = {in_data,in_startofpacket,in_endofpacket,in_empty,in_error};
     {out_data,out_startofpacket,out_endofpacket,out_empty,out_error} = out_payload;
   end


generate if(FIFO_MEM_TYPE == 1) begin

assign out_valid_wire = ~fifo_empty;
assign fifo_rdreq     = ready[0] & out_valid; 
assign fifo_wrreq     = (~fifo_full) & in_valid; 
assign fifo_fill      = fifo_full ? {1'b1, 3'b0}
                                  : {1'b0, fifo_usedw};

// MLAB based FIFO
    scfifo  scfifo_mlab (
                .clock  (clk),
                .data   (in_payload),
                .rdreq  (fifo_rdreq),
                .wrreq  (fifo_wrreq),
                .empty  (fifo_empty),
                .full   (fifo_full),
                .q      (out_payload),
                .aclr   (1'b0),
                .almost_empty (),
                .almost_full (),
                .eccstatus (),
                .sclr   (1'b0),
                .usedw  (fifo_usedw));
    defparam
        scfifo_mlab.add_ram_output_register  = "ON",
        scfifo_mlab.enable_ecc  = "FALSE",
        scfifo_mlab.intended_device_family  = "Agilex 5",
        scfifo_mlab.lpm_hint  = "RAM_BLOCK_TYPE=MLAB",
        scfifo_mlab.lpm_numwords  = 8,
        scfifo_mlab.lpm_showahead  = "ON",
        scfifo_mlab.lpm_type  = "scfifo",
        scfifo_mlab.lpm_width  = 42,
        scfifo_mlab.lpm_widthu  = 3,
        scfifo_mlab.overflow_checking  = "ON",
        scfifo_mlab.underflow_checking  = "ON",
        scfifo_mlab.use_eab  = "OFF";

end
else if(FIFO_MEM_TYPE == 2) begin
assign out_valid_wire = ~fifo_empty;
assign fifo_rdreq     = ready[0] & out_valid; 
assign fifo_wrreq     = (~fifo_full) & in_valid; 
assign fifo_fill      = fifo_full ? {1'b1, 3'b0}
                                  : {1'b0, fifo_usedw};

// MLAB based FIFO
    scfifo  scfifo_le (
                .clock  (clk),
                .data   (in_payload),
                .rdreq  (fifo_rdreq),
                .wrreq  (fifo_wrreq),
                .empty  (fifo_empty),
                .full   (fifo_full),
                .q      (out_payload),
                .aclr   (1'b0),
                .almost_empty (),
                .almost_full (),
                .eccstatus (),
                .sclr   (1'b0),
                .usedw  (fifo_usedw));
    defparam
        scfifo_le.add_ram_output_register  = "ON",
        scfifo_le.enable_ecc  = "FALSE",
        scfifo_le.intended_device_family  = "Agilex 5",
        scfifo_le.lpm_numwords  = 8,
        scfifo_le.lpm_showahead  = "ON",
        scfifo_le.lpm_type  = "scfifo",
        scfifo_le.lpm_width  = 42,
        scfifo_le.lpm_widthu  = 3,
        scfifo_le.overflow_checking  = "ON",
        scfifo_le.underflow_checking  = "ON",
        scfifo_le.use_eab  = "ON";

end
else begin
   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------                           
   qsys_top_timing_adapter_1950_4blnw3y_fifo qsys_top_timing_adapter_1950_4blnw3y_fifo 
     ( 
       .clk        (clk),
       .reset_n    (reset_n),
       .in_ready   (),
       .in_valid   (in_valid),      
       .in_data    (in_payload),
       .out_ready  (ready[0]),
       .out_valid  (out_valid_wire),      
       .out_data   (out_payload),
       .fill_level (fifo_fill)
       );
end
endgenerate

   // ---------------------------------------------------------------------
   //| Ready & valid signals.
   // ---------------------------------------------------------------------
   always @* begin
      in_ready = (8 - fifo_fill > 2);
      out_valid = out_valid_wire;
      ready[0] = out_ready;
   end
generate if(SYNC_RESET == 0) begin

end
else begin
reg internal_sclr;
always @ (posedge clk) begin
internal_sclr <= reset_n;
end

end
endgenerate

endmodule


