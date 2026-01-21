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


/*
  This optional block is used for two purposes:

  1)  Relay response information back to the host typically in ST->MM mode.
      This information is 'actual bytes transferred', 'error', and 'early termination'.

  2)  Relay response and interrupt information back to a prefetching master block
      that will write the contents back to memory.  Interrupt information is also passed
      since the interrupt needs to occur when the prefetching master block overwrites
      the descriptor in main memory and not when the event occurs.  The host needs to read
      the interrupt condition out of memory so it could potentially get out of sync if
      the interrupt information wasn't buffered and delayed.

  This block has three response port options:  MM slave, ST source, and disabled.
  When you don't need access to response information (MM->MM or MM->ST) or interrupts in
  the case of a prefetching descriptor master then you can safely disable the port.
  By disabling the port you will not consume any logic resources or on-chip memory blocks.

  When the source port is enabled bit 52 of the data stream represents the "descriptor full"
  condition.  The descriptor prefetching master can use this signal to perform pipelined reads
  without having to worry about flow control (since there is room for an entire descriptor to be
  written).  This is benefical as apposed to performing descriptor reads, buffering the data, then
  writting it out to the descriptor buffer block.


  Version 1.0

  1.0 - If you attempt to use the wrong response port type you will be issued a warning
        but allowed to generate.  This is because in some cases you may not need the typical
        behavior.  For example if you perform MM->MM transfers with some streaming IP between
        the read and write masters you still might need access to error bits.  Likewise
        if you don't enable the streaming sink port while using a descriptor pre-fetching block
        you may not care if you get interrupted early and want to use the CSR block for interrupts
        instead.

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 


module response_block (
  clk,
  reset,

  mm_response_readdata,
  mm_response_read,
  mm_response_address,
  mm_response_byteenable,
  mm_response_waitrequest,

  src_response_data,
  src_response_valid,
  src_response_ready,

  sw_reset,
  response_watermark,
  response_fifo_full,
  response_fifo_empty,
  done_strobe,
  actual_bytes_transferred,
  error,
  early_termination,
  transfer_complete_IRQ_mask,
  error_IRQ_mask,
  early_termination_IRQ_mask,
  descriptor_buffer_full
);

  parameter DEVICE_FAMILY = "Agilex";
  parameter RESPONSE_PORT = 0;   // when disabled all the outputs will be disconnected by the component wrapper
  parameter FIFO_DEPTH = 256;    // needs to be double the descriptor FIFO depth
  parameter FIFO_DEPTH_LOG2 = 8;
  localparam FIFO_WIDTH = (RESPONSE_PORT == 0)? 41 : 51;  // when 'RESPONSE_PORT' is 1 then the response port is set to streaming and must pass the interrupt masks as well

  input clk;
  input reset;

  output wire [31:0] mm_response_readdata;
  input mm_response_read;
  input mm_response_address;  // only have 2 addresses
  input [3:0] mm_response_byteenable;
  output wire mm_response_waitrequest;

  output wire [255:0] src_response_data;  // not going to use all these bits, the remainder will be grounded
  output wire src_response_valid;
  input src_response_ready;

  input sw_reset;
  output wire [15:0] response_watermark;
  output wire response_fifo_full;
  output wire response_fifo_empty;
  input done_strobe;
  input [31:0] actual_bytes_transferred;
  input [7:0] error;
  input early_termination;
  // all of these signals are only used the ST source response port since the pre-fetching master component will handle the interrupt generation as apposed to the CSR block
  input transfer_complete_IRQ_mask;
  input [7:0] error_IRQ_mask;
  input early_termination_IRQ_mask;
  input descriptor_buffer_full;  // handy signal for the prefetching master to use so that it known when to blast a new descriptor into the dispatcher


  /* internal signals and registers */
  wire [FIFO_DEPTH_LOG2-1:0] fifo_used;
  wire fifo_full;
  wire fifo_empty;
  wire fifo_read;
  wire [FIFO_WIDTH-1:0] fifo_input;
  wire [FIFO_WIDTH-1:0] fifo_output;


  generate
    if (DEVICE_FAMILY == "eASIC N5X")
	begin
	  if (RESPONSE_PORT == 0)  // slave port used for response data
      begin
        assign fifo_input = {early_termination, error, actual_bytes_transferred};  
        assign fifo_read = (mm_response_read == 1) & (fifo_empty == 0) & (mm_response_address == 1) & (mm_response_byteenable[3] == 1);  // reading from the upper byte (byte offset 7) pops the fifo

        scfifo #(
          .lpm_width (FIFO_WIDTH),
          .lpm_widthu  (FIFO_DEPTH_LOG2),
          .lpm_numwords (FIFO_DEPTH),
          .lpm_showahead ("ON"), 
          .use_eab ("ON"),
          .add_ram_output_register ("ON"),
          .underflow_checking  ("OFF"),
          .overflow_checking  ("OFF"),
          .lpm_type  ("scfifo")
        
           ) the_response_FIFO (
              .clock (clk),
              .aclr (reset), 
              .sclr (sw_reset | reset),
              .data (fifo_input),
              .wrreq (done_strobe),
              .rdreq (fifo_read),
              .q (fifo_output),
              .full (fifo_full),
              .empty (fifo_empty),
              .usedw (fifo_used)
            );
            // defparam the_response_FIFO.lpm_width = FIFO_WIDTH;
            // defparam the_response_FIFO.lpm_numwords = FIFO_DEPTH;
            // defparam the_response_FIFO.lpm_widthu = FIFO_DEPTH_LOG2;
            // defparam the_response_FIFO.lpm_showahead = "ON";
            // defparam the_response_FIFO.use_eab = "ON";
            // defparam the_response_FIFO.overflow_checking = "OFF";
            // defparam the_response_FIFO.underflow_checking = "OFF";
            // defparam the_response_FIFO.add_ram_output_register = "ON";
            // defparam the_response_FIFO.lpm_type = "scfifo";
	  
        // either actual bytes transfered when address == 0 or {zero padding, early_termination, error[7:0]} when address = 1
        assign mm_response_readdata = (mm_response_address == 0)? fifo_output[31:0] : {{23{1'b0}}, fifo_output[40:32]};
        assign mm_response_waitrequest = fifo_empty;
        assign response_watermark = {{(16-(FIFO_DEPTH_LOG2+1)){1'b0}}, fifo_full, fifo_used};  // zero padding plus the 'true used' FIFO amount
        assign response_fifo_full = fifo_full;
        assign response_fifo_empty = fifo_empty;
	  
        // no streaming port so ground all of its outputs
        assign src_response_data = 0;
        assign src_response_valid = 0;
	  
      end
      else if (RESPONSE_PORT == 1)  // streaming source port used for response data (prefetcher will catch this data)
      begin
	  
        assign fifo_input = {early_termination_IRQ_mask, error_IRQ_mask, transfer_complete_IRQ_mask, early_termination, error, actual_bytes_transferred};
        assign fifo_read = (fifo_empty == 0) & (src_response_ready == 1);

        scfifo #( 
          .lpm_width (FIFO_WIDTH),
          .lpm_widthu  (FIFO_DEPTH_LOG2),
          .lpm_numwords (FIFO_DEPTH),
          .lpm_showahead ("ON"), 
          .use_eab ("ON"),
          .add_ram_output_register ("ON"),
          .underflow_checking  ("OFF"),
          .overflow_checking  ("OFF"),
          .lpm_type  ("scfifo")
          ) the_response_FIFO (
              .clock (clk),
              .aclr (reset),
              .sclr (sw_reset | reset),
              .data (fifo_input),
              .wrreq (done_strobe),
              .rdreq (fifo_read),
              .q (fifo_output),
              .full (fifo_full),
              .empty (fifo_empty),
              .usedw (fifo_used)
          );
            // defparam the_response_FIFO.lpm_width = FIFO_WIDTH;
            // defparam the_response_FIFO.lpm_numwords = FIFO_DEPTH;
            // defparam the_response_FIFO.lpm_widthu = FIFO_DEPTH_LOG2;
            // defparam the_response_FIFO.lpm_showahead = "ON";
            // defparam the_response_FIFO.use_eab = "ON";
            // defparam the_response_FIFO.overflow_checking = "OFF";
            // defparam the_response_FIFO.underflow_checking = "OFF";
            // defparam the_response_FIFO.add_ram_output_register = "ON";
            // defparam the_response_FIFO.lpm_type = "scfifo";

        assign src_response_data = {{204{1'b0}}, descriptor_buffer_full, fifo_output};  // zero padding the upper bits, also sending out the descriptor buffer full signal to simplify the throttling in the prefetching master (bit 52)
        assign src_response_valid = (fifo_empty == 0);
        assign response_watermark = {{(16-(FIFO_DEPTH_LOG2+1)){1'b0}}, fifo_full, fifo_used};  // zero padding plus the 'true used' FIFO amount;
        assign response_fifo_full = fifo_full;
        assign response_fifo_empty = fifo_empty;
	  
        // no slave port so ground all of its outputs
        assign mm_response_readdata = 0;
        assign mm_response_waitrequest = 0;
	  
      end
      else  // no response port so grounding all outputs
      begin
        assign fifo_input = 0;
        assign fifo_output = 0;
        assign mm_response_readdata = 0;
        assign mm_response_waitrequest = 0;
        assign src_response_data = 0;
        assign src_response_valid = 0;
        assign response_watermark = 0;
        assign response_fifo_full = 0;
        assign response_fifo_empty = 0;
      end
	end else //other than Diamond Mesa
	begin
	  if (RESPONSE_PORT == 0)  // slave port used for response data
      begin
	  
        assign fifo_input = {early_termination, error, actual_bytes_transferred};  
        assign fifo_read = (mm_response_read == 1) & (fifo_empty == 0) & (mm_response_address == 1) & (mm_response_byteenable[3] == 1);  // reading from the upper byte (byte offset 7) pops the fifo

        (* altera_attribute = "-name MESSAGE_DISABLE 14320" *)
        scfifo #(
          .intended_device_family (DEVICE_FAMILY),
          .lpm_width (FIFO_WIDTH),
          .lpm_widthu  (FIFO_DEPTH_LOG2),
          .lpm_numwords (FIFO_DEPTH),
          .lpm_showahead ("ON"), 
          .use_eab ("ON"),
          .add_ram_output_register ("ON"),
          .underflow_checking  ("OFF"),
          .overflow_checking  ("OFF"),
          .lpm_type  ("scfifo")
          ) the_response_FIFO (
              .clock (clk),
              //.aclr (reset),
              .sclr (sw_reset | reset),
              .data (fifo_input),
              .wrreq (done_strobe),
              .rdreq (fifo_read),
              .q (fifo_output),
              .full (fifo_full),
              .empty (fifo_empty),
              .usedw (fifo_used)
          );
        (* altera_attribute = "-name MESSAGE_ENABLE 14320" *)
            // defparam the_response_FIFO.lpm_width = FIFO_WIDTH;
            // defparam the_response_FIFO.lpm_numwords = FIFO_DEPTH;
            // defparam the_response_FIFO.lpm_widthu = FIFO_DEPTH_LOG2;
            // defparam the_response_FIFO.lpm_showahead = "ON";
            // defparam the_response_FIFO.use_eab = "ON";
            // defparam the_response_FIFO.overflow_checking = "OFF";
            // defparam the_response_FIFO.underflow_checking = "OFF";
            // defparam the_response_FIFO.add_ram_output_register = "ON";
            // defparam the_response_FIFO.lpm_type = "scfifo";

        // either actual bytes transfered when address == 0 or {zero padding, early_termination, error[7:0]} when address = 1
        assign mm_response_readdata = (mm_response_address == 0)? fifo_output[31:0] : {{23{1'b0}}, fifo_output[40:32]};
        assign mm_response_waitrequest = fifo_empty;
        assign response_watermark = {{(16-(FIFO_DEPTH_LOG2+1)){1'b0}}, fifo_full, fifo_used};  // zero padding plus the 'true used' FIFO amount
        assign response_fifo_full = fifo_full;
        assign response_fifo_empty = fifo_empty;
	  
        // no streaming port so ground all of its outputs
        assign src_response_data = 0;
        assign src_response_valid = 0;
	  
      end
      else if (RESPONSE_PORT == 1)  // streaming source port used for response data (prefetcher will catch this data)
      begin
	  
        assign fifo_input = {early_termination_IRQ_mask, error_IRQ_mask, transfer_complete_IRQ_mask, early_termination, error, actual_bytes_transferred};
        assign fifo_read = (fifo_empty == 0) & (src_response_ready == 1);
    
        (* altera_attribute = "-name MESSAGE_DISABLE 14320" *)
        scfifo #(
          .intended_device_family (DEVICE_FAMILY),
          .lpm_width (FIFO_WIDTH),
          .lpm_widthu  (FIFO_DEPTH_LOG2),
          .lpm_numwords (FIFO_DEPTH),
          .lpm_showahead ("ON"), 
          .use_eab ("ON"),
          .add_ram_output_register ("ON"),
          .underflow_checking  ("OFF"),
          .overflow_checking  ("OFF"),
          .lpm_type  ("scfifo")
          ) the_response_FIFO (
              .clock (clk),
              .aclr (reset | sw_reset),
              .data (fifo_input),
              .wrreq (done_strobe),
              .rdreq (fifo_read),
              .q (fifo_output),
              .full (fifo_full),
              .empty (fifo_empty),
              .usedw (fifo_used)
          );
        (* altera_attribute = "-name MESSAGE_ENABLE 14320" *)
            // defparam the_response_FIFO.lpm_width = FIFO_WIDTH;
            // defparam the_response_FIFO.lpm_numwords = FIFO_DEPTH;
            // defparam the_response_FIFO.lpm_widthu = FIFO_DEPTH_LOG2;
            // defparam the_response_FIFO.lpm_showahead = "ON";
            // defparam the_response_FIFO.use_eab = "ON";
            // defparam the_response_FIFO.overflow_checking = "OFF";
            // defparam the_response_FIFO.underflow_checking = "OFF";
            // defparam the_response_FIFO.add_ram_output_register = "ON";
            // defparam the_response_FIFO.lpm_type = "scfifo";
	  
        assign src_response_data = {{204{1'b0}}, descriptor_buffer_full, fifo_output};  // zero padding the upper bits, also sending out the descriptor buffer full signal to simplify the throttling in the prefetching master (bit 52)
        assign src_response_valid = (fifo_empty == 0);
        assign response_watermark = {{(16-(FIFO_DEPTH_LOG2+1)){1'b0}}, fifo_full, fifo_used};  // zero padding plus the 'true used' FIFO amount;
        assign response_fifo_full = fifo_full;
        assign response_fifo_empty = fifo_empty;
	  
        // no slave port so ground all of its outputs
        assign mm_response_readdata = 0;
        assign mm_response_waitrequest = 0;
	  
      end
      else  // no response port so grounding all outputs
      begin
	  
        assign fifo_input = 0;
        assign fifo_output = 0;
        assign mm_response_readdata = 0;
        assign mm_response_waitrequest = 0;
        assign src_response_data = 0;
        assign src_response_valid = 0;
        assign response_watermark = 0;
        assign response_fifo_full = 0;
        assign response_fifo_empty = 0;
	  
      end
	end
  endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NQKOkvDFlGcTNUMkJvw2ttetzSTTRcmqMXtCpVxbYpHSe/L3qSecw9a1EXPMakU1VYx6vvbBICr+JBPP8pkrQQ0o5PyddE1FOQHdjMEWE3KZHR7a0a6plKytx6UO2TxDM8PD+pcHrYPZHBSOdZGrM38Mf8dlnqzdd7SxajS8qcadHwbz65y59cud3osNTVHojD8q2KrQ87Og7PFU6Dvc7zK4O6xpuGdx3ucCyCcqlHHmyClcvcjp2ufuRH5HADXpq101ZRJc8ma99ywvxh3Gyam5O2vQYl2yZ3d882D2NKrZ/3EVNaWlJxNIimnzVoW+Sy6Lj7gXLxlgZYBZNZq0S24QRJw4T07VW9EkFEMOluL48paStXfRzWgL09nLD1kbqskums/ymEP2EmYWqsvf6LcDS8EpW+SVlOXfCB+34nvgH8AUBYDe7vlmjH79hD2Fn6gMF9oYK14XxdKoXp3vVC84jY/fEtSEbpRc2iEbKxXiuMI5/zgBmApf8r/Qpxy8FbamypjNoBFOhG31xchY0Lg3qZvdG9iT/ZPF9cO6WagjbGaAkx5cjVBL0R3/5vH1N9sF9WGl+1sQqQC5eXka1oqP/Y9nVKTcbNGxvyPjLMO+myjIUMWg3qpDSiVcuqReTtrwJNNiBi/uHE58Zyrg4enFo2q4cLDNx7YkPUtoiTo1X+Gk9KMtR+Xg41mKoG2NOdWeAqo8GpLR5Puy7XnI8j3lohX0wQYkiQMC7bZDlw/ZkvPTH8KlcexaMZqHJ/2fDAxjVlXcArneqvnS1/+G+OY"
`endif