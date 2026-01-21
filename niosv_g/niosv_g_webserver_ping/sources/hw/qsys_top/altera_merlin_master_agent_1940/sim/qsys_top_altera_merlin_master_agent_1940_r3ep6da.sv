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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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

// --------------------------------------
// Merlin Master Agent
//
// Converts Avalon-MM transactions into
// Merlin network packets.
// --------------------------------------

`timescale 1 ns / 1 ns

module qsys_top_altera_merlin_master_agent_1940_r3ep6da
#(
   // -------------------
   // Packet Format Parameters
   // -------------------
   parameter 
   PKT_QOS_H                  = 109,
   PKT_QOS_L                  = 106,
   PKT_DATA_SIDEBAND_H        = 105,
   PKT_DATA_SIDEBAND_L        = 98,
   PKT_ADDR_SIDEBAND_H        = 97, 
   PKT_ADDR_SIDEBAND_L        = 93,
   PKT_CACHE_H                = 92,
   PKT_CACHE_L                = 89,
   PKT_THREAD_ID_H            = 88,
   PKT_THREAD_ID_L            = 87,
   PKT_BEGIN_BURST            = 81,
   PKT_PROTECTION_H           = 80,
   PKT_PROTECTION_L           = 80,
   PKT_BURSTWRAP_H            = 79,
   PKT_BURSTWRAP_L            = 77,
   PKT_BYTE_CNT_H             = 76,
   PKT_BYTE_CNT_L             = 74,
   PKT_ADDR_H                 = 73,
   PKT_ADDR_L                 = 42,
   PKT_BURST_SIZE_H           = 86,
   PKT_BURST_SIZE_L           = 84,
   PKT_BURST_TYPE_H           = 94,
   PKT_BURST_TYPE_L           = 93,
   PKT_TRANS_EXCLUSIVE        = 83,
   PKT_TRANS_LOCK             = 82,
   PKT_TRANS_COMPRESSED_READ  = 41,
   PKT_TRANS_POSTED           = 40,
   PKT_TRANS_WRITE            = 39,
   PKT_TRANS_READ             = 38,
   PKT_DATA_H                 = 37,
   PKT_DATA_L                 = 6,
   PKT_BYTEEN_H               = 5,
   PKT_BYTEEN_L               = 2,
   PKT_SRC_ID_H               = 1,
   PKT_SRC_ID_L               = 1,
   PKT_DEST_ID_H              = 0,
   PKT_DEST_ID_L              = 0,
   PKT_RESPONSE_STATUS_L      = 110,
   PKT_RESPONSE_STATUS_H      = 111,
   PKT_ORI_BURST_SIZE_L       = 112,
   PKT_ORI_BURST_SIZE_H       = 114,
   PKT_DOMAIN_L               = 115,
   PKT_DOMAIN_H               = 116,
   PKT_SNOOP_L                = 117,
   PKT_SNOOP_H                = 120,
   PKT_BARRIER_L              = 121,
   PKT_BARRIER_H              = 122,
   PKT_WUNIQUE                = 123,
   PKT_POISON_L               = 126,
   PKT_POISON_H               = 126,
   PKT_DATACHK_L              = 127,
   PKT_DATACHK_H              = 127,
   PKT_ADDRCHK_L              = 128,
   PKT_ADDRCHK_H              = 128,
   PKT_SAI_L                  = 129,
   PKT_SAI_H                  = 129,
   PKT_USER_DATA_L            = 130,
   PKT_USER_DATA_H            = 130,
   PKT_ATRACE                 = 131,
   PKT_TRACE                  = 132,
   PKT_AWAKEUP                = 133,   
   ST_DATA_W                  = 134,
   ST_CHANNEL_W               = 1,
   SYNC_RESET                 = 0,
   ENABLE_AXI5                = 0,
   ROLE_BASED_USER            = 0,
   OPTIMIZED_READS_WITH_BE    = 0,// updates to align addr during read
   //ACE5-Lite signals
   PKT_AWATOP_L               = 154,
   PKT_AWATOP_H               = 159,
   PKT_AWSTASHNID_L           = 160,
   PKT_AWSTASHNID_H           = 170,
   PKT_AWSTASHNIDEN           = 171,
   PKT_AWSTASHLPID_L          = 172,
   PKT_AWSTASHLPID_H          = 176,
   PKT_AWSTASHLPIDEN          = 177,
   PKT_MMUSECSID              = 178,
   PKT_MMUSID_L               = 179,
   PKT_MMUSID_H               = 195,
   PKT_DATALESS               = 196,
  
   // -------------------
   // Agent Parameters
   // -------------------
   AV_BURSTCOUNT_W       = 3,
   ID                    = 1,
   SUPPRESS_0_BYTEEN_RSP = 1,
   BURSTWRAP_VALUE       = 4,
   CACHE_VALUE           = 0,
   SECURE_ACCESS_BIT     = 1,
   USE_READRESPONSE      = 0,
   USE_WRITERESPONSE     = 0,
   DOMAIN_VALUE          = 3,    // System 
   BARRIER_VALUE         = 2,    // Normal access, ignoring barriers
   SNOOP_VALUE           = 0,    // No snoop
   WUNIQUE_VALUE         = 0,   
   USE_PKT_DATACHK       = 1,    
   USE_PKT_ADDRCHK       = 0,       
   AWATOP_VALUE          = 0,
   AWSTASHNID_VALUE      = 0,
   AWSTASHNIDEN_VALUE    = 0,
   AWSTASHLPID_VALUE     = 0,
   AWSTASHLPIDEN_VALUE   = 0,
   MMUSECSID_VALUE       = 0,
   MMUSID_VALUE          = 0,
   DATALESS_VALUE        = 0,
   
  
   // -------------------
   // Derived Parameters
   // -------------------
   PKT_BURSTWRAP_W   = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
   PKT_BYTE_CNT_W    = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
   PKT_PROTECTION_W  = PKT_PROTECTION_H - PKT_PROTECTION_L + 1,
   PKT_ADDR_W        = PKT_ADDR_H - PKT_ADDR_L + 1,
   PKT_DATA_W        = PKT_DATA_H - PKT_DATA_L + 1,
   PKT_BYTEEN_W      = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
   PKT_SRC_ID_W      = PKT_SRC_ID_H - PKT_SRC_ID_L + 1,
   PKT_DEST_ID_W     = PKT_DEST_ID_H - PKT_DEST_ID_L + 1,
   PKT_BURST_SIZE_W  = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1,
   ADDRCHK_WIDTH     = (USE_PKT_ADDRCHK)? PKT_ADDRCHK_H - PKT_ADDRCHK_L + 1: 1,
   PADDING_ZERO      = (USE_PKT_ADDRCHK)? ((ADDRCHK_WIDTH*8) - PKT_ADDR_W) : 1,
   PARITY_ADDR_WIDTH =  PADDING_ZERO + PKT_ADDR_W,
   PKT_DATACHK_W     = PKT_DATA_W /8  // field width in packet shrinks to 1 when inactive
) (
   // -------------------
   // Clock & Reset
   // -------------------
   input                         clk,
   input                         reset,

   // -------------------
   // Avalon-MM Anti-Master
   // -------------------
   input [PKT_ADDR_W-1 : 0]      av_address,
   input                         av_write,
   input                         av_read,
   input [PKT_DATA_W-1 : 0]      av_writedata,
   output reg [PKT_DATA_W-1 : 0] av_readdata,
   output wire                   av_waitrequest,
   output reg                    av_readdatavalid,
   input [PKT_BYTEEN_W-1 : 0]    av_byteenable,
   input [AV_BURSTCOUNT_W-1 : 0] av_burstcount,
   input                         av_debugaccess,
   input                         av_lock,
   output reg [1 : 0]            av_response,
   output reg                    av_writeresponsevalid,

   // -------------------
   // Command Source
   // -------------------
   output reg                    cp_valid,
   output reg [ST_DATA_W-1 : 0]  cp_data,
   output wire                   cp_startofpacket,
   output wire                   cp_endofpacket,
   input                         cp_ready,

   // -------------------
   // Response Sink
   // -------------------
   input                         rp_valid,
   input [ST_DATA_W-1 : 0]       rp_data,
   input [ST_CHANNEL_W-1 : 0]    rp_channel,
   input                         rp_startofpacket,
   input                         rp_endofpacket,
   output reg                    rp_ready
);
    // ------------------------------------------------------------
    // Utility Functions
    // ------------------------------------------------------------
   function integer clogb2;
      input [31 : 0] value;
      begin
         for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
            value = value >> 1;
         clogb2 = clogb2 - 1;
      end
   endfunction // clogb2

   function reg [PKT_DATACHK_W-1:0] calcParity (
       input [PKT_DATA_W-1:0] data
    );
       for (int i=0; i<PKT_DATACHK_W; i++)
           calcParity[i] = ~(^ data[i*8 +:8]);
   endfunction
   
    function reg [ADDRCHK_WIDTH-1:0] addrcalcParity (
        input [PARITY_ADDR_WIDTH-1:0] addr
     );
        for (int i=0; i<ADDRCHK_WIDTH; i++)
            addrcalcParity[i] = ~(^ addr[i*8 +:8]);
    endfunction  

   localparam MAX_BURST    = 1 << (AV_BURSTCOUNT_W - 1);
   localparam NUMSYMBOLS   = PKT_BYTEEN_W; 
   localparam BURSTING     = (MAX_BURST > NUMSYMBOLS);
   localparam BITS_TO_ZERO = clogb2(NUMSYMBOLS);
   localparam BURST_SIZE   = clogb2(NUMSYMBOLS);

   typedef enum bit  [1 : 0]
   {
      FIXED       = 2'b00,
      INCR        = 2'b01,
      WRAP        = 2'b10,
      OTHER_WRAP  = 2'b11
   } MerlinBurstType;

   // --------------------------------------
   // Potential optimization: compare in words to save bits?
   // --------------------------------------
   wire is_burst;
   assign is_burst = (BURSTING) & (av_burstcount > NUMSYMBOLS);

   wire [31 : 0] burstwrap_value_int = BURSTWRAP_VALUE;
   wire [31 : 0] id_int              = ID; 
   wire [PKT_BURST_SIZE_W-1 : 0] burstsize_sig ;
   generate
       if (OPTIMIZED_READS_WITH_BE) begin : AXSIZE_UPDATES
           if(NUMSYMBOLS==2) begin : SIZE_16
               // no need of fancy function here
               assign burstsize_sig = ((av_byteenable==2)||(av_byteenable==1)) ? 0 : 1 ;    
           end 
           else if (NUMSYMBOLS<=128) begin : SIZE_32_1024
               wire [PKT_BURST_SIZE_W-1 : 0] byte_cnt_sig_0 = bytecnt_chunk_4(av_byteenable[3:0]); 
               reg  [BURST_SIZE : 0] byte_cnt_tmp; // max count = total BEs
               always @* begin
                   byte_cnt_tmp = byte_cnt_sig_0;
               end 
               assign burstsize_sig = bytecnt_to_axsize(byte_cnt_tmp);
           end 
           else begin : SIZE_DEFAULTS
               // We know this is Avalon only case if Size exceeds 1K
               // even 1byte should stay default
               assign burstsize_sig = BURST_SIZE[PKT_BURST_SIZE_W-1 : 0];
           end
       end
       else begin : NO_AXSIZE_UPDATES
           assign burstsize_sig = BURST_SIZE[PKT_BURST_SIZE_W-1 : 0];
       end
   endgenerate
   wire [1 : 0] bursttype_value = burstwrap_value_int[PKT_BURSTWRAP_W-1] ? INCR : WRAP;

   // --------------------------------------
   // Update burstsize value based on ByteEn
   //
   // look at BE 4 bits at a chunk in parallel
   // generate narrow size Xfer 
   // add AxSize for all chunks of BE that leads
   // to final value of AxSize
   // It is guaranted that all BEs are adjacent by AVMM protocol
   //
   // This can be done at smaller than 4 bits as well
   // Overall operation
   // parallel Calc of Chunk --> add all chunks
   // smaller the chunks, higher the adder
   // bigget  the chunks, bigger the decoder
   // Chunk of 4 is somewhat balanced
   //
   // Also this operates on 4 chunk => 32 bits, we need to handle 16b word
   // size as special case
   //
   // --------------------------------------
   function reg [2:0] bytecnt_chunk_4;
       input [3:0] byte_en;
       begin
           case (byte_en)
               4'b0000 : bytecnt_chunk_4 = 3'b000;

               4'b0001 : bytecnt_chunk_4 = 3'b001;
               4'b0010 : bytecnt_chunk_4 = 3'b001;
               4'b0100 : bytecnt_chunk_4 = 3'b001;
               4'b1000 : bytecnt_chunk_4 = 3'b001;

               4'b0011 : bytecnt_chunk_4 = 3'b010;
               4'b1100 : bytecnt_chunk_4 = 3'b010;
               // only 3 valid cases for AVMM Master
               default : bytecnt_chunk_4 = 3'b100; 
           endcase
       end
   endfunction
// AXI byte count to Size conversion
  function reg [PKT_BURST_SIZE_W-1 : 0] bytecnt_to_axsize;
       input [7:0] bytecnt;    
       begin
           case(bytecnt)
               1       : bytecnt_to_axsize = 3'b000;
               2       : bytecnt_to_axsize = 3'b001;
               4       : bytecnt_to_axsize = 3'b010;
               8       : bytecnt_to_axsize = 3'b011;
               16      : bytecnt_to_axsize = 3'b100;
               32      : bytecnt_to_axsize = 3'b101;
               64      : bytecnt_to_axsize = 3'b110;
               default : bytecnt_to_axsize = 3'b111;
           endcase
       end
   endfunction 



   // --------------------------------------
   // Address alignment
   //
   // The packet format requires that addresses be aligned to
   // the transaction size.
   // New feature support for interconnect - OPTIMIZED_READS_WITH_BE
   // WHEN BYTE_EN ARE NOT ALL 1s ==>
   // In that case we need so send unaligned address
   //  -> AXI S will understand unaligned addr
   //  -> AVM S does not understand this, hence undo it in AVM slave agent
   // --------------------------------------
   function reg [BITS_TO_ZERO-1:0] unaligned_address_lsb;
       input [PKT_BYTEEN_W-1:0] byte_en;
       begin
           casez (byte_en)

               4'b??10      :   unaligned_address_lsb = 2'b01;

               4'b?100      :   unaligned_address_lsb = 2'b10;

               4'b1000      :   unaligned_address_lsb = 2'b11;
               default :   unaligned_address_lsb = 2'b00;
           endcase
       end
   endfunction 
   wire [PKT_ADDR_W-1 : 0] av_address_aligned;
   generate 
      if (NUMSYMBOLS > 1) begin
         assign av_address_aligned [PKT_ADDR_W-1 : BITS_TO_ZERO] = av_address[PKT_ADDR_W-1 : BITS_TO_ZERO];
         if (OPTIMIZED_READS_WITH_BE) begin
             assign av_address_aligned [BITS_TO_ZERO-1: 0] =  av_read ? unaligned_address_lsb(av_byteenable) : av_address[BITS_TO_ZERO-1:0];
         end else begin
             assign av_address_aligned [BITS_TO_ZERO-1: 0] =  {BITS_TO_ZERO {1'b0}};
         end
      end
      else begin
         assign av_address_aligned = av_address;
      end 
   endgenerate

   // If USE_PKT_DATACHK = 0, calculate parity based on data. Otherwise
   // drive to zero. 
   wire [PKT_DATACHK_W-1:0] datachk_wire;
   generate
   if (USE_PKT_DATACHK ==0) begin
      assign   datachk_wire = calcParity(av_writedata);
   end
   else begin
      assign   datachk_wire = '0;
   end
   endgenerate
   
   wire [ADDRCHK_WIDTH-1:0] addrchk_wire;
   generate
   if (USE_PKT_ADDRCHK) begin
      assign   addrchk_wire = addrcalcParity(av_address);
   end
   else begin
      assign   addrchk_wire = '0;
   end
   endgenerate   

   // --------------------------------------
   // Command & Response Construction
   // --------------------------------------
   always_comb begin
      cp_data                                              = '0;

      cp_data[PKT_PROTECTION_L]                            = av_debugaccess;    
      cp_data[PKT_PROTECTION_L+1]                          = SECURE_ACCESS_BIT[0];  // secure cache bit
      cp_data[PKT_PROTECTION_L+2]                          = 1'b0;                  // instruction/data cache bit
      cp_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L]           = burstwrap_value_int[PKT_BURSTWRAP_W-1 : 0];
      cp_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L]             = av_burstcount;
      cp_data[PKT_ADDR_H : PKT_ADDR_L]                     = av_address_aligned;
      cp_data[PKT_TRANS_EXCLUSIVE]                         = 1'b0;
      cp_data[PKT_TRANS_LOCK]                              = av_lock;
      cp_data[PKT_TRANS_COMPRESSED_READ]                   = av_read & is_burst;
      cp_data[PKT_TRANS_READ]                              = av_read;
      cp_data[PKT_TRANS_WRITE]                             = av_write;
      cp_data[PKT_TRANS_POSTED]                            = av_write & !USE_WRITERESPONSE;
      cp_data[PKT_DATA_H : PKT_DATA_L]                     = av_writedata;
      cp_data[PKT_BYTEEN_H : PKT_BYTEEN_L]                 = av_byteenable;
      cp_data[PKT_BURST_SIZE_H : PKT_BURST_SIZE_L]         = burstsize_sig;
      cp_data[PKT_ORI_BURST_SIZE_H : PKT_ORI_BURST_SIZE_L] = burstsize_sig;
      cp_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L]         = bursttype_value;
      cp_data[PKT_SRC_ID_H : PKT_SRC_ID_L]                 = id_int[PKT_SRC_ID_W-1 : 0];
      cp_data[PKT_THREAD_ID_H : PKT_THREAD_ID_L]           = '0;
      cp_data[PKT_CACHE_H : PKT_CACHE_L]                   = CACHE_VALUE[3 : 0];
      cp_data[PKT_QOS_H : PKT_QOS_L]                       = '0;        
      cp_data[PKT_ADDR_SIDEBAND_H : PKT_ADDR_SIDEBAND_L]   = '0;
      cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]   = '0;
      cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L]                 = DOMAIN_VALUE[1:0];
      cp_data[PKT_BARRIER_H : PKT_BARRIER_L]               = BARRIER_VALUE[1:0];
      cp_data[PKT_SNOOP_H : PKT_SNOOP_L]                   = SNOOP_VALUE[3:0];
      cp_data[PKT_WUNIQUE]                                 = WUNIQUE_VALUE[0];
      if (ENABLE_AXI5) begin
          cp_data[PKT_DATACHK_H:PKT_DATACHK_L]                 = datachk_wire;      
          cp_data[PKT_POISON_H:PKT_POISON_L]                   = '0;
          cp_data[PKT_ATRACE]                                  = '0;
          cp_data[PKT_TRACE]                                   = '0;
          cp_data[PKT_AWAKEUP]                                 = '0;
          cp_data[PKT_SAI_H:PKT_SAI_L]                         = '0;     
       end
       if (ROLE_BASED_USER) begin
          cp_data[PKT_DATACHK_H:PKT_DATACHK_L]                  = datachk_wire;
          cp_data[PKT_POISON_H:PKT_POISON_L]                    = '0;
          cp_data[PKT_ADDRCHK_H:PKT_ADDRCHK_L]                  = addrchk_wire;
          cp_data[PKT_SAI_H:PKT_SAI_L]                          = '0;
          cp_data[PKT_USER_DATA_H:PKT_USER_DATA_L]              = '0;
       end 
      cp_data[PKT_AWATOP_H:PKT_AWATOP_L]           = AWATOP_VALUE;
      cp_data[PKT_AWSTASHNID_H:PKT_AWSTASHNID_L]   = AWSTASHNID_VALUE;
      cp_data[PKT_AWSTASHNIDEN]                    = AWSTASHNIDEN_VALUE;
      cp_data[PKT_AWSTASHLPID_H:PKT_AWSTASHLPID_L] = AWSTASHLPID_VALUE;
      cp_data[PKT_AWSTASHLPIDEN]                   = AWSTASHLPIDEN_VALUE;
      cp_data[PKT_MMUSECSID]                       = MMUSECSID_VALUE;
      cp_data[PKT_MMUSID_H:PKT_MMUSID_L]           = MMUSID_VALUE;
      cp_data[PKT_DATALESS]                        = DATALESS_VALUE;

      av_readdata                                          = rp_data[PKT_DATA_H : PKT_DATA_L];
      if (USE_WRITERESPONSE || USE_READRESPONSE)
         av_response = rp_data[PKT_RESPONSE_STATUS_H : PKT_RESPONSE_STATUS_L];
      else
         av_response = '0;
      end

   // Generation of internal reset synchronization
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

   // --------------------------------------
   // Command Control
   // --------------------------------------
   reg hold_waitrequest;

   generate
   if (SYNC_RESET == 0) begin: async_reg0
      always @ (posedge clk, posedge reset) begin
         if (reset)
            hold_waitrequest <= 1'b1;
         else
            hold_waitrequest <= 1'b0;
      end 
   end // async_reg0

   else begin //sync_reg0
      always @ (posedge clk) begin
         if (internal_sclr)
            hold_waitrequest <= 1'b1;
         else
            hold_waitrequest <= 1'b0;
      end 
   end  // sync_reg0
   endgenerate
 
   always_comb begin
      cp_valid = 0;
         if ((av_write || av_read) && ~hold_waitrequest)
            cp_valid = 1;
   end

   generate if (BURSTING) begin
      reg sop_enable;

      if (SYNC_RESET == 0) begin :async_reg1
         always @(posedge clk, posedge reset) begin
            if (reset) begin
               sop_enable <= 1'b1;
            end
            else begin
               if (cp_valid && cp_ready) begin
                  sop_enable <= 1'b0;
                  if (cp_endofpacket)
                     sop_enable <= 1'b1;
               end
            end
         end
      end // async_reg1

      else begin //sync_reg1
         always @(posedge clk) begin
            if (internal_sclr) begin
               sop_enable <= 1'b1;
            end
            else begin
               if (cp_valid && cp_ready) begin
                  sop_enable <= 1'b0;
                  if (cp_endofpacket)
                     sop_enable <= 1'b1;
               end
            end
         end
      end // sync_reg1

      assign cp_startofpacket = sop_enable;
      assign cp_endofpacket   = (av_read) | (av_burstcount == NUMSYMBOLS);

   end 
   else begin

      assign cp_startofpacket = 1'b1;
      assign cp_endofpacket   = 1'b1;

   end
   endgenerate

   // --------------------------------------
   // Backpressure & Readdatavalid
   // --------------------------------------
   generate 
      if(SYNC_RESET == 0) begin
         assign av_waitrequest = (hold_waitrequest) | !cp_ready;
      end
      else begin
         assign av_waitrequest = internal_sclr | !cp_ready;
      end
   endgenerate
   always_comb begin
      rp_ready              = 1;
      av_readdatavalid      = 0;
      av_writeresponsevalid = 0;

      if (USE_WRITERESPONSE && (rp_data[PKT_TRANS_WRITE] == 1))
         av_writeresponsevalid = rp_valid;
      else
         av_readdatavalid      = rp_valid;

      if (SUPPRESS_0_BYTEEN_RSP) begin
         if (rp_data[PKT_BYTEEN_H : PKT_BYTEEN_L] == 0)
            av_readdatavalid = 0;
      end
   end

endmodule

