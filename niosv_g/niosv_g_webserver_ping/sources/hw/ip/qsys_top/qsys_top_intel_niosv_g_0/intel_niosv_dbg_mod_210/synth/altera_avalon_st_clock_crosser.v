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


// $File: //acds/rel/25.3/ip/iconnect/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v $
// $Revision: #1 $
// $Date: 2025/08/01 $
// $Author: psgswbuild $
//------------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_st_clock_crosser(
                                 in_clk,
                                 in_reset,
                                 in_ready,
                                 in_valid,
                                 in_data,
                                 out_clk,
                                 out_reset,
                                 out_ready,
                                 out_valid,
                                 out_data
                                );

  parameter  SYMBOLS_PER_BEAT    = 1;
  parameter  BITS_PER_SYMBOL     = 8;
  parameter  FORWARD_SYNC_DEPTH  = 2;
  parameter  BACKWARD_SYNC_DEPTH = 2;
  parameter  USE_OUTPUT_PIPELINE = 1;
  
  localparam  DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;

  input                   in_clk;
  input                   in_reset;
  output                  in_ready;
  input                   in_valid;
  input  [DATA_WIDTH-1:0] in_data;

  input                   out_clk;
  input                   out_reset;
  input                   out_ready;
  output                  out_valid;
  output [DATA_WIDTH-1:0] out_data;

  // Data is guaranteed valid by control signal clock crossing.  Cut data
  // buffer false path.
  (* altera_attribute = {"-name SUPPRESS_DA_RULE_INTERNAL \"D101,D102\""} *) reg [DATA_WIDTH-1:0] in_data_buffer;
  (* altera_attribute = {"-name DESIGN_ASSISTANT_EXCLUDE \"CDC-50001,CDC-50006\""} *) reg    [DATA_WIDTH-1:0] out_data_buffer;

  reg                     in_data_toggle;
  wire                    in_data_toggle_returned;
  wire                    out_data_toggle;
  reg                     out_data_toggle_flopped, out_data_toggle_1, out_data_toggle_flopped_n;

  wire                    take_in_data;
  wire                    out_data_taken;

  wire                    out_valid_internal;
  wire                    out_ready_internal;
  wire                    reset_merged;
  wire                    out_reset_merged;
  wire                    in_reset_merged;

  assign in_ready =  (in_data_toggle_returned ^ in_data_toggle);
  assign take_in_data = in_valid & in_ready;
  assign out_valid_internal = out_data_toggle_1 ^ out_data_toggle_flopped;
  assign out_data_taken = out_ready_internal & out_valid_internal;
 
assign reset_merged = in_reset  | out_reset;
 
   altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_in_rst
        (
            .clk        (in_clk),
            .reset_in   (reset_merged),
            .reset_out  (in_reset_merged)
        );
 
 altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_out_rst
        (
            .clk        (out_clk),
            .reset_in   (reset_merged),
            .reset_out  (out_reset_merged)
        );

  always @(posedge in_clk or posedge in_reset_merged) begin
    if (in_reset_merged) begin
      in_data_buffer <= {DATA_WIDTH{1'b0}};
      in_data_toggle <= 1'b0;
    end else begin
      if (take_in_data) begin
        in_data_toggle <= ~in_data_toggle;
        in_data_buffer <= in_data;
      end
    end //in_reset
  end //in_clk always block

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_1 <= 1'b0;
    end else begin
        out_data_toggle_1 <= out_data_toggle;
    end //end if
  end //out_clk always block
  
  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped <= 1'b0;
      out_data_buffer <= {DATA_WIDTH{1'b0}};
    end else begin
      out_data_buffer <= in_data_buffer;
      if (out_data_taken) begin
        out_data_toggle_flopped <= out_data_toggle_1;
      end
    end //end if
  end //out_clk always block

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped_n <= 1'b0;
    end else begin
        out_data_toggle_flopped_n <= ~out_data_toggle_flopped;
     end //end if
  end //out_clk always block
 
  altera_std_synchronizer_nocut #(.depth(FORWARD_SYNC_DEPTH)) in_to_out_synchronizer (
				     .clk(out_clk),
				     .reset_n(~out_reset_merged),
				     .din(in_data_toggle),
				     .dout(out_data_toggle)
				     );
  
  altera_std_synchronizer_nocut #(.depth(BACKWARD_SYNC_DEPTH)) out_to_in_synchronizer (
				     .clk(in_clk),
				     .reset_n(~in_reset_merged),
				     .din(out_data_toggle_flopped_n),
				     .dout(in_data_toggle_returned)
				     );


  generate if (USE_OUTPUT_PIPELINE == 1) begin

      altera_avalon_st_pipeline_base 
      #(
         .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
         .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT)
      ) output_stage (
         .clk(out_clk),
         .reset(out_reset_merged),
         .in_ready(out_ready_internal),
         .in_valid(out_valid_internal),
         .in_data(out_data_buffer),
         .out_ready(out_ready),
         .out_valid(out_valid),
         .out_data(out_data)
      );
 
  end else begin

      assign out_valid = out_valid_internal;
      assign out_ready_internal = out_ready;
      assign out_data = out_data_buffer;
 
  end
 
  endgenerate
 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "vw3bYUhBrDCRVQkEGfEsUoUZSvT2HFE5JzrvX1p7/k9xH868wtAl5OLRIPUtW8qnf81czLER91g7yYTOpCWkUE4uk9n5EidnGPZvBQV09faPLhUBg7gYNVolf4jF/yGqncnRnHTzvez9wHgDrPRxO0v0Q8zmayZxEemhBYAmsGxWLjzyXt5jDwWEuvvwcOBiyJULsUhXvjEArqusxP+5knKew4nY9kIIYKmxkaaDArTqZhsdeIFvCK1RBBbTPmC6lT0RlhmH3qKICNzCTbx/35L3PiZZevLDvdL5jUAcUnL7ifo87023un5SWONVA51ZmE4zK6ez7hjubSYMHh54MUAZxPkBcwg0bmeuRR2ZVRBOzGvYl/1CYFJlFbl8pTZfpfyTJd5eOrR1+Yo72zhzGvLJ7+YYtQWni889oSa7d3nScN1/K6E6yClEbGg2sPoxlizhIiu27HG/oawh7+4QQdLuTNRil75gdLiyukSVAyr7AWxS38ZAMlMiVO1AMgcFPxewPxcpZEbqRQ3xJ9uSntynNT2N19wCI/kaBnMMJ+BkhGtUwAuZ0oq30cOaESDm4uQOuzq1J5P5yzYTSQS0Ay9wpoRF8V52XXbm1xEUpPotDEpbDuFuSWmKbKBEHCvST1qhhFmvkIduTQili4WMRIw42fzw1P0ptaA9fcKt/9Zww4XLsf8lkgMk8GzUWCw3sBXa3wKnTUuSKnCP4hpTznGEwCokPIvM4KTLRKN8JlcswjKyF3rm5cXK14eIikKcB6xrnEP8ZyHXkmjutKyb3TaICSPjGIRXXds0WkFnm7c6gv6OtUxltY3w8//G8hfsKtxrxxRc1SShRRvhuSRqqj0UICyZSPWdyP7NVb2xNV62UyiXPLJL8IVU5jkMSovCJbo0SxyOsfMDxJpYUGL3e1rhXRP7lLjsJ9N0Q669Yw5G8xJLLiJIoqjjkJSRR2dRz+/AEC/gVGLYRj2/Sqy+a3xuRb8k11msBhxbsvsQRnJiUzCF5eyRkaRe24aC9RO9"
`endif