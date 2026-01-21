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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altera_msgdma_prefetcher_write_back #(
    parameter ENHANCED_FEATURES = 0,
    parameter SIDEBAND_ENABLE = 0,
    parameter DATA_WIDTH = 32,
    parameter DATA_BYTEENABLE_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32,
    parameter RESPONSE_FIFO_WIDTH = 64
) (
    input                                   clk,
    input                                   reset,

    input                                   mm_write_waitrequest,
    input                                   mm_write_writeresponsevalid,
    input [1:0]                             mm_write_response,  // don't care the response status
    output reg [ADDRESS_WIDTH-1:0]          mm_write_address,
    output reg                              mm_write_write,
    output reg [DATA_WIDTH-1:0]             mm_write_writedata,
    output reg [DATA_BYTEENABLE_WIDTH-1:0]  mm_write_byteenable,

    input                                   st_snk_valid,
    input [255:0]                           st_snk_data,
    output reg                              st_snk_ready,

    input [RESPONSE_FIFO_WIDTH-1:0]         resp_fifo_rdata,
    output                                  get_resp_fifo,

    output                                  write_back_done,
    output                                  transfer_complete_irq_mask,
    output [7:0]                            error_irq_mask,
    output                                  early_termination_irq_mask,
    output [7:0]                            error,
    output                                  early_termination,

    input                                   reset_prefetcher,
    input                                   park_mode,
    input                                   run,
    output reg                              reset_complete

);

localparam [2:0]    IDLE        = 3'b000; 
localparam [2:0]    START       = 3'b001; 
localparam [2:0]    WR_REQ      = 3'b010; 
localparam [2:0]    WR_WAIT     = 3'b011; 
localparam [2:0]    WR_PEND     = 3'b100; 
localparam [2:0]    WR_DONE     = 3'b101; 
localparam [2:0]    ST_READY    = 3'b110; 

localparam	    PTR_SIZE	= (ENHANCED_FEATURES == 1) ? 64 : 32;

reg [2:0]                           desc_wrback_state;
reg [2:0]                           desc_wrback_state_nxt;
reg [2:0]                           wr_req_cnt;
reg [2:0]                           wr_req_cnt_nxt;
reg [2:0]                           wr_resp_cnt;
reg [2:0]                           wr_resp_cnt_nxt;
reg                                 owned_by_hardware_wrback;

wire                                mm_write_write_nxt;
wire                                idle_state;
wire                                wr_req_state;
wire                                wr_done_state;
wire                                st_ready_state;
wire                                start_state;
wire                                wr_req_done;
wire                                wr_resp_done;
wire [ADDRESS_WIDTH-1:0]            nxt_desc_pointer_base;
wire [ADDRESS_WIDTH-1:0]            mm_write_address_int [0:5];
wire [DATA_BYTEENABLE_WIDTH-1:0]    mm_write_byteenable_int [0:5];
wire [DATA_WIDTH-1:0]               mm_write_writedata_int [0:5];
wire                                reset_complete_nxt;
wire [PTR_SIZE-1:0]	    	    nxt_desc_pointer_i;

wire [2:0]							wr_cnt_init;	

//--------------------------------------------------------------------------------------------//
// Main FSM
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        desc_wrback_state  <= IDLE;
    else
        desc_wrback_state  <= desc_wrback_state_nxt;
end

always @* begin
    case (desc_wrback_state)
        IDLE: begin
            if (run & ~reset_prefetcher)
                desc_wrback_state_nxt   = START;
            else
                desc_wrback_state_nxt   = IDLE;
        end

        START: begin
            if (reset_prefetcher) // to handle case where reset prefetcher occurs during descriptor poll events and no more response from dispatcher
                desc_wrback_state_nxt   = IDLE;
            else if (st_snk_valid)
                desc_wrback_state_nxt   = WR_REQ;
            else
                desc_wrback_state_nxt   = START;
        end

        WR_REQ: begin
            desc_wrback_state_nxt       = WR_WAIT;
        end
        
        WR_WAIT: begin
            if (wr_req_done)
                desc_wrback_state_nxt   = WR_PEND;
            else
                desc_wrback_state_nxt   = WR_WAIT;
        end
        
        WR_PEND: begin
            if (wr_resp_done)
                desc_wrback_state_nxt   = WR_DONE;
            else
                desc_wrback_state_nxt   = WR_PEND;
        end
        
        WR_DONE: begin
            desc_wrback_state_nxt       = ST_READY;
        end
        
        ST_READY: begin
            if (reset_prefetcher)
                desc_wrback_state_nxt       = IDLE;
            else
                desc_wrback_state_nxt       = START;
        end

        default: begin
            desc_wrback_state_nxt  = IDLE;
        end

    endcase
end 



//--------------------------------------------------------------------------------------------//
// Avalon MM Write Back registers
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        mm_write_write  <= 1'b0;
    else
        mm_write_write  <= mm_write_write_nxt;
end

assign mm_write_write_nxt = mm_write_write ? ~wr_req_done : wr_req_state;

always @(posedge clk) begin
    if (reset) begin
        mm_write_address        <= 0;
        mm_write_byteenable     <= 0;
        mm_write_writedata      <= 0;
    end
    else begin
        mm_write_address        <= mm_write_address_int[wr_req_cnt_nxt];
        mm_write_byteenable     <= mm_write_byteenable_int[wr_req_cnt_nxt];
        mm_write_writedata      <= mm_write_writedata_int[wr_req_cnt_nxt];
    end
end



//--------------------------------------------------------------------------------------------//
// Write req counter
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        wr_req_cnt   <= 0;
    else
        wr_req_cnt   <= wr_req_cnt_nxt;
end

always @* begin
    if (wr_req_state)
        wr_req_cnt_nxt = wr_cnt_init;
    else if ((wr_req_cnt > 0) & mm_write_write & ~mm_write_waitrequest)
        wr_req_cnt_nxt = wr_req_cnt - 3'h1;
    else
        wr_req_cnt_nxt = wr_req_cnt;
end


//--------------------------------------------------------------------------------------------//
// Write resp counter
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        wr_resp_cnt   <= 0;
    else
        wr_resp_cnt   <= wr_resp_cnt_nxt;
end

always @* begin
    if (wr_req_state)
        wr_resp_cnt_nxt = wr_cnt_init;
    else if ((wr_resp_cnt > 0) & mm_write_writeresponsevalid)
        wr_resp_cnt_nxt = wr_resp_cnt - 3'h1;
    else
        wr_resp_cnt_nxt = wr_resp_cnt;
end


//--------------------------------------------------------------------------------------------//
// Snapshot park_mode csr value each time before write back transaction begins case:321667
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        owned_by_hardware_wrback    <= 0;
    else if (wr_req_state)
        owned_by_hardware_wrback    <= park_mode;
end


//--------------------------------------------------------------------------------------------//
// Avalon ST registers
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        st_snk_ready    <= 1'b0;
    else if (wr_done_state)
        st_snk_ready    <= 1'b1;
    else
        st_snk_ready    <= 1'b0;
end


//--------------------------------------------------------------------------------------------//
// Reset Prefetcher Complete bit
//--------------------------------------------------------------------------------------------//
always @(posedge clk) begin
    if (reset)
        reset_complete  <= 1'b0;
    else
        reset_complete  <= reset_complete_nxt;
end

assign reset_complete_nxt = reset_complete ? reset_prefetcher : (reset_prefetcher & (idle_state | st_ready_state | start_state));


//--------------------------------------------------------------------------------------------//
// Combinatorial assignment
//--------------------------------------------------------------------------------------------//
assign idle_state                   = (desc_wrback_state == IDLE);
assign wr_req_state                 = (desc_wrback_state == WR_REQ);
assign wr_done_state                = (desc_wrback_state == WR_DONE);
assign st_ready_state               = (desc_wrback_state == ST_READY);
assign start_state                  = (desc_wrback_state == START);
assign wr_req_done                  = ~mm_write_waitrequest & (wr_req_cnt == 0);
assign wr_resp_done                 = mm_write_writeresponsevalid & (wr_resp_cnt == 0);
assign get_resp_fifo                = wr_done_state; // Ensure the next resp data is available during worst case scenario (back to back write back).Resp fifo has read latency of 2. 
assign write_back_done              = st_snk_ready;
assign error                        = st_snk_data[39:32];
assign early_termination            = st_snk_data[40];
assign transfer_complete_irq_mask   = st_snk_data[41];
assign error_irq_mask               = st_snk_data[49:42];
assign early_termination_irq_mask   = st_snk_data[50];

generate
if (ENHANCED_FEATURES) begin

    assign nxt_desc_pointer_i 	    = resp_fifo_rdata[63:0];
    assign nxt_desc_pointer_base    = nxt_desc_pointer_i[ADDRESS_WIDTH-1:0];
	
	if (SIDEBAND_ENABLE) begin
	
	if (DATA_WIDTH == 32) begin
        assign wr_cnt_init                  = 3'h5;

        assign mm_write_address_int[5]      = nxt_desc_pointer_base + 16; // 0x10
        assign mm_write_address_int[4]      = nxt_desc_pointer_base + 20; // 0x14   	
        assign mm_write_address_int[3]      = nxt_desc_pointer_base + 48; // 0x30
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 52; // 0x34
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 56; // 0x38
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 60; // 0x3C

        assign mm_write_byteenable_int[5]   = 4'hf;
        assign mm_write_byteenable_int[4]   = 4'h3;
        assign mm_write_byteenable_int[3]   = 4'hf;
        assign mm_write_byteenable_int[2]   = 4'hf;
        assign mm_write_byteenable_int[1]   = 4'hf;
        assign mm_write_byteenable_int[0]   = 4'hf;
                                                            
        assign mm_write_writedata_int[5]   = {st_snk_data[31:0]};
        assign mm_write_writedata_int[4]   = {23'h0, st_snk_data[40:32]};
        assign mm_write_writedata_int[3]   = {st_snk_data[191:160]};
        assign mm_write_writedata_int[2]   = {st_snk_data[223:192]};
        assign mm_write_writedata_int[1]   = {st_snk_data[255:224]};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64]};

    end
    else if (DATA_WIDTH == 64) begin
        assign wr_cnt_init                  = 3'h3;
   	
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};		
        assign mm_write_address_int[3]      = nxt_desc_pointer_base + 16; // 0x10
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; // 0x10
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 48; // 0x30
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 56; // 0x38
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = 8'h0f;
        assign mm_write_byteenable_int[2]   = 8'h30;
        assign mm_write_byteenable_int[1]   = 8'hff;
        assign mm_write_byteenable_int[0]   = 8'hff;
         
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[3]   = {32'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[2]   = {23'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[1]   = {st_snk_data[223:160]};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], st_snk_data[255:224]};

    end
    else if (DATA_WIDTH == 128) begin
        assign wr_cnt_init                  = 3'h2;

        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; // 0x10
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 16; // 0x10
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 48; // 0x30
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 16'h000f;
        assign mm_write_byteenable_int[1]   = 16'h0030;
        assign mm_write_byteenable_int[0]   = 16'hffff;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], st_snk_data[255:160]};

    end
    else if (DATA_WIDTH == 256) begin
        assign wr_cnt_init                  = 3'h2;
   	
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 0;  // 0x0
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 0;  // 0x0
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 32; // 0x20
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 32'h000f0000;
        assign mm_write_byteenable_int[1]   = 32'h00300000;
        assign mm_write_byteenable_int[0]   = 32'hffff0000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0], 128'h0};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 160'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], st_snk_data[255:160], 128'h0};

    end
    else if (DATA_WIDTH == 512) begin
        assign wr_cnt_init                  = 3'h2;
	
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 0;  // 0x0
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 0;  // 0x0
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 0;  // 0x0
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 64'h00000000000f0000;
        assign mm_write_byteenable_int[1]   = 64'h0000000000300000;
        assign mm_write_byteenable_int[0]   = 64'hffff000000000000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {352'h0, st_snk_data[31:0], 128'h0};
        assign mm_write_writedata_int[1]   = {343'h0, st_snk_data[40:32], 160'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], st_snk_data[255:160], 384'h0};

    end
    end
    else begin

        assign wr_cnt_init                  = 3'h2;
		
    if (DATA_WIDTH == 32) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 20; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 60; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 4'hf;
        assign mm_write_byteenable_int[1]   = 4'h3;
        assign mm_write_byteenable_int[0]   = 4'hf;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {23'h0, st_snk_data[40:32]};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64]};

    end
    else if (DATA_WIDTH == 64) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 56; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 8'h0f;
        assign mm_write_byteenable_int[1]   = 8'h30;
        assign mm_write_byteenable_int[0]   = 8'hf0;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[2]   = {32'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {23'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], 32'h0};

    end
    else if (DATA_WIDTH == 128) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 48; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 16'h000f;
        assign mm_write_byteenable_int[1]   = 16'h0030;
        assign mm_write_byteenable_int[0]   = 16'hf000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}};  
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], 96'h0};

    end
    else if (DATA_WIDTH == 256) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 32; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 32'h000f0000;
        assign mm_write_byteenable_int[1]   = 32'h00300000;
        assign mm_write_byteenable_int[0]   = 32'hf0000000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0], 128'h0};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 160'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], 224'h0};

    end
    else if (DATA_WIDTH == 512) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 0; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 64'h00000000000f0000;
        assign mm_write_byteenable_int[1]   = 64'h0000000000300000;
        assign mm_write_byteenable_int[0]   = 64'hf000000000000000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {352'h0, st_snk_data[31:0], 128'h0};
        assign mm_write_writedata_int[1]   = {343'h0, st_snk_data[40:32], 160'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[95], owned_by_hardware_wrback, resp_fifo_rdata[93:64], 480'h0};

    end
    end
end
else begin

    assign nxt_desc_pointer_i	    = resp_fifo_rdata[31:0];
    assign nxt_desc_pointer_base    = nxt_desc_pointer_i[ADDRESS_WIDTH-1:0];
    assign wr_cnt_init              = 3'h2;

    if (DATA_WIDTH == 32) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 20; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 28; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 4'hf;
        assign mm_write_byteenable_int[1]   = 4'h3;
        assign mm_write_byteenable_int[0]   = 4'hf;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[2]   = {st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {23'h0, st_snk_data[40:32]};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[63], owned_by_hardware_wrback, resp_fifo_rdata[61:32]};
    
    end
    else if (DATA_WIDTH == 64) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 24; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 8'h0f;
        assign mm_write_byteenable_int[1]   = 8'h30;
        assign mm_write_byteenable_int[0]   = 8'hf0;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[2]   = {32'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {23'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[63], owned_by_hardware_wrback, resp_fifo_rdata[61:32], 32'h0};

    end
    else if (DATA_WIDTH == 128) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}}; 
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 16; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 16; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 16'h000f;
        assign mm_write_byteenable_int[1]   = 16'h0030;
        assign mm_write_byteenable_int[0]   = 16'hf000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0]};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 32'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[63], owned_by_hardware_wrback, resp_fifo_rdata[61:32], 96'h0};

    end
    else if (DATA_WIDTH == 256) begin
        assign mm_write_address_int[5]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[4]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[3]      = {ADDRESS_WIDTH{1'b0}};
        assign mm_write_address_int[2]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[1]      = nxt_desc_pointer_base + 0; 
        assign mm_write_address_int[0]      = nxt_desc_pointer_base + 0; 
        
        assign mm_write_byteenable_int[5]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[4]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[3]   = {DATA_BYTEENABLE_WIDTH{1'b0}};
        assign mm_write_byteenable_int[2]   = 32'h000f0000;
        assign mm_write_byteenable_int[1]   = 32'h00300000;
        assign mm_write_byteenable_int[0]   = 32'hf0000000;
        
        assign mm_write_writedata_int[5]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[4]   = {DATA_WIDTH{1'b0}}; 
        assign mm_write_writedata_int[3]   = {DATA_WIDTH{1'b0}};
        assign mm_write_writedata_int[2]   = {96'h0, st_snk_data[31:0], 128'h0};
        assign mm_write_writedata_int[1]   = {87'h0, st_snk_data[40:32], 160'h0};
        assign mm_write_writedata_int[0]   = {resp_fifo_rdata[63], owned_by_hardware_wrback, resp_fifo_rdata[61:32], 224'h0};

    end
end
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NQpDz4IHgraQEF2wYJeBgp9UFeIdbiyfRL7QFGPKbj8L7vAq/rRPjW8yN8JpZJLz4vLe7VUFn6Bv8sK67cqMFxpS5eR6GhxMn75gUHX0cYsuESFTzkk4TNfUARlA2CBbvD+PPe18goCMQeFaq4/Cdf6F3E5ReCWkdNS+5iJ9u8rIUBzY/wwn4UNc6cCgEosyvcd6c9/WiwW/aEzjratP82bRzmha6j2/cE22ASfoNragKFc07D1Li/07HWZCMqRgmo1pZP05BT+q1KXQWpy9tXRnNzdS8bYFNGaoKJW6Ji02E5v1U0SGJKm2ho6ELW412ndHEdRXmas2uAG4LRa/zt8zffX/fxuOcl6trjljMpzFasSl3RWvP7a7QID2oudZIfHgkNiHlq7ZUGf/dshwbDwDDo95Fg8+830f6B+5bLftfnMvbGlwsXe7HWP2ybYgwzJjMCsddnJWiSC8muYUGnTWKqbbdLCCulqLIlwLHJZTy8+xPqJuB9+G60VeYehKxv/w/cQa17fngOes2VKLWOsmm8s5UrI+u4kwjvfLG+ZaTMJMAm9A+c7nhZri5SORqQPBpptAn+YRHhk5jqd1dxFJGOGrZALd3TI2glmGHQV1hujqGCEjAaI7q7rXWntfF6+B6cTMyQcYvpWWijiRjC8OV72rR9U1dowadSZHrlhDkVpzXzvBMBNQkfqpoPa/ceDXFiFAifF5Jc7ybdxCxRjS61fzrX276sPuiFy2cX5/kP3tQZ8rgBc5fJnUqCHgwDaui5WHF/2YdEIHQ1RrOcL"
`endif