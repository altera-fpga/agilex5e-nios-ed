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


// $Id: //acds/rel/25.3/ip/iconnect/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2025/08/01 $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// the address.
//
// Also sets the binary-encoded destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

// ------------------------------------------
// Generation parameters:
//    decoder_type            0 (address decoder)
//    default_channel         8
//    default_destid          2
//    default_rd_channel      -1
//    default_wr_channel      -1
//    has_default_slave       0
//    memory_aliasing_decode  0
//    output_name             qsys_top_altera_merlin_router_1921_k42z6hy
//    pkt_addr_h              67
//    pkt_addr_l              36
//    pkt_dest_id_h           111
//    pkt_dest_id_l           108
//    pkt_protection_h        115
//    pkt_protection_l        113
//    pkt_trans_read          71
//    pkt_trans_write         70
//    slaves_info             2:000100000000:0x0:0x200000:both:1:0:0:1,0:000000100000:0x200000:0x210000:both:1:0:0:1,3:001000000000:0x210000:0x212000:both:1:0:0:1,7:000000000010:0x212000:0x212400:both:1:0:0:1,1:100000000000:0x212400:0x212440:both:1:0:0:1,11:000010000000:0x212440:0x212460:both:1:0:0:1,10:000000010000:0x212460:0x212480:both:1:0:0:1,9:000001000000:0x212480:0x2124a0:both:1:0:0:1,8:000000001000:0x2124a0:0x2124c0:both:1:0:0:1,5:010000000000:0x2124c0:0x2124d0:both:1:0:0:1,6:000000000100:0x2124d0:0x2124d8:read:1:0:0:1,4:000000000001:0x2124d8:0x2124e0:both:1:0:0:1
//    st_channel_w            12
//    st_data_w               179
// ------------------------------------------

module qsys_top_altera_merlin_router_1921_k42z6hy_default_decode
  #(
     parameter DEFAULT_CHANNEL = 8,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 2 
   )
  (output [111 - 108 : 0] default_destination_id,
   output [12-1 : 0] default_wr_channel,
   output [12-1 : 0] default_rd_channel,
   output [12-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[111 - 108 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 12'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 12'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 12'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module qsys_top_altera_merlin_router_1921_k42z6hy
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [179-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [179-1    : 0] src_data,
    output reg [12-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 111;
    localparam PKT_DEST_ID_L = 108;
    localparam PKT_PROTECTION_H = 115;
    localparam PKT_PROTECTION_L = 113;
    localparam ST_DATA_W = 179;
    localparam ST_CHANNEL_W = 12;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h2124e0;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [12-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    qsys_top_altera_merlin_router_1921_k42z6hy_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

        // slave 0: [0x0, 0x200000) : sel [21:21]
        if ( {address[21:21],{21 {1'b0}}} == 22'h0   ) begin
            src_channel = 12'b000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
        end

        // slave 1: [0x200000, 0x210000) : sel [21:16]
        if ( {address[21:16],{16 {1'b0}}} == 22'h200000   ) begin
            src_channel = 12'b000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
        end

        // slave 2: [0x210000, 0x212000) : sel [21:13]
        if ( {address[21:13],{13 {1'b0}}} == 22'h210000   ) begin
            src_channel = 12'b001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
        end

        // slave 3: [0x212000, 0x212400) : sel [21:10]
        if ( {address[21:10],{10 {1'b0}}} == 22'h212000   ) begin
            src_channel = 12'b000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
        end

        // slave 4: [0x212400, 0x212440) : sel [21:6]
        if ( {address[21:6],{6 {1'b0}}} == 22'h212400   ) begin
            src_channel = 12'b100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
        end

        // slave 5: [0x212440, 0x212460) : sel [21:5]
        if ( {address[21:5],{5 {1'b0}}} == 22'h212440   ) begin
            src_channel = 12'b000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
        end

        // slave 6: [0x212460, 0x212480) : sel [21:5]
        if ( {address[21:5],{5 {1'b0}}} == 22'h212460   ) begin
            src_channel = 12'b000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
        end

        // slave 7: [0x212480, 0x2124a0) : sel [21:5]
        if ( {address[21:5],{5 {1'b0}}} == 22'h212480   ) begin
            src_channel = 12'b000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
        end

        // slave 8: [0x2124a0, 0x2124c0) : sel [21:5]
        if ( {address[21:5],{5 {1'b0}}} == 22'h2124a0   ) begin
            src_channel = 12'b000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
        end

        // slave 9: [0x2124c0, 0x2124d0) : sel [21:4]
        if ( {address[21:4],{4 {1'b0}}} == 22'h2124c0   ) begin
            src_channel = 12'b010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
        end

        // slave 10: [0x2124d0, 0x2124d8) : sel [21:3]
        if ( {address[21:3],{3 {1'b0}}} == 22'h2124d0  && read_transaction  ) begin
            src_channel = 12'b000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
        end

        // slave 11: [0x2124d8, 0x2124e0) : sel [21:3]
        if ( {address[21:3],{3 {1'b0}}} == 22'h2124d8   ) begin
            src_channel = 12'b000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
        end
    end


    // --------------------------------------------------
    // Ceil(log2()) function
    // It's the 21st century. Consider using $clog2().
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


