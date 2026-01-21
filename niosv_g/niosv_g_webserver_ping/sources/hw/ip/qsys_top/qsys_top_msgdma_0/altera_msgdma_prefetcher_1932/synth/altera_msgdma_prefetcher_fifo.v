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

(* altera_attribute = "-name MESSAGE_DISABLE 14320" *)
module altera_msgdma_prefetcher_fifo #(
    parameter DEVICE_FAMILY = "Agilex",
    parameter RESPONSE_FIFO_WIDTH   = 64,
    parameter RESPONSE_FIFO_DEPTH   = 256,
    parameter RESPONSE_FIFO_DEPTH_LOG2 = 7,
    parameter LATENCY = 2
) (
    input                               clk,
    input                               areset,
    input                               sreset,
    input [RESPONSE_FIFO_WIDTH-1:0]     wr_data,
    input                               wrreq,
    input                               rdreq,
    
    output                              full,
    output [RESPONSE_FIFO_WIDTH-1:0]    rd_data
);


reg [RESPONSE_FIFO_DEPTH_LOG2-1:0]  write_address;
reg [RESPONSE_FIFO_DEPTH_LOG2-1:0]  read_address;
reg [RESPONSE_FIFO_DEPTH_LOG2:0] internal_used;

wire internal_full;
//wire internal_empty;
wire [(RESPONSE_FIFO_WIDTH/8)-1:0]  write_byteenables;


  always @ (posedge clk)
  begin
    if (areset)
    begin
      write_address <= 0;
    end
    else
    begin
      if (sreset)
      begin
        write_address <= 0;
      end
      else if (wrreq == 1)
      begin
        write_address <= write_address + 1'b1;
      end
    end
  end

  always @ (posedge clk)
  begin
    if (areset)
    begin
      read_address <= 0;
    end
    else
    begin
      if (sreset)
      begin
        read_address <= 0;
      end
      else if (rdreq == 1)
      begin
        read_address <= read_address + 1'b1;
      end
    end
  end

  assign write_byteenables = {(RESPONSE_FIFO_WIDTH/8){1'b1}};

  generate
    if (DEVICE_FAMILY == "eASIC N5X")
	  begin
		altsyncram #( 
			.operation_mode                     ("DUAL_PORT"),
			.lpm_type                           ("altsyncram"),
			.read_during_write_mode_mixed_ports ("DONT_CARE"),
			.power_up_uninitialized             ("TRUE"),
			.byte_size                          (8),
			.width_a                            (RESPONSE_FIFO_WIDTH),
			.width_b                            (RESPONSE_FIFO_WIDTH),
			.widthad_a                          (RESPONSE_FIFO_DEPTH_LOG2),
			.widthad_b                          (RESPONSE_FIFO_DEPTH_LOG2),
			.width_byteena_a                    (RESPONSE_FIFO_WIDTH/8),
			.numwords_a                         (RESPONSE_FIFO_DEPTH),
			.numwords_b                         (RESPONSE_FIFO_DEPTH),
			.address_reg_b                      ("CLOCK0"),
			.outdata_reg_b                      ((LATENCY == 2)? "CLOCK0" : "UNREGISTERED")
		
		) the_dp_ram (
         .clock0 (clk),
         .wren_a (wrreq),
         .byteena_a (write_byteenables),
         .data_a (wr_data),
         .address_a (write_address),
         .q_b (rd_data),
         .address_b (read_address),
		 .clock1 (clk),
		 .aclr0 (areset|sreset),
		 .aclr1 (areset|sreset),
		 .clocken0 (1'b1),
		 .clocken1 (1'b1),
		 .clocken2 (1'b1),
		 .clocken3 (1'b1),
		 .rden_a (1'b1),
		 .addressstall_a (1'b0),
		 .wren_b (1'b0),
		 .rden_b (1'b1),
		 .data_b ({RESPONSE_FIFO_WIDTH{1'b1}}),
		 .byteena_b ({(RESPONSE_FIFO_WIDTH/8){1'b1}}),
	     .addressstall_b (1'b0)
	   );
       // defparam the_dp_ram.operation_mode = "DUAL_PORT";  // simple dual port (one read, one write port)
       // defparam the_dp_ram.lpm_type = "altsyncram";
       // defparam the_dp_ram.read_during_write_mode_mixed_ports = "DONT_CARE";
       // defparam the_dp_ram.power_up_uninitialized = "TRUE";
       // defparam the_dp_ram.byte_size = 8;
       // defparam the_dp_ram.width_a = RESPONSE_FIFO_WIDTH;
       // defparam the_dp_ram.width_b = RESPONSE_FIFO_WIDTH;
       // defparam the_dp_ram.widthad_a = RESPONSE_FIFO_DEPTH_LOG2;
       // defparam the_dp_ram.widthad_b = RESPONSE_FIFO_DEPTH_LOG2;
       // defparam the_dp_ram.width_byteena_a = (RESPONSE_FIFO_WIDTH/8);
       // defparam the_dp_ram.numwords_a = RESPONSE_FIFO_DEPTH;
       // defparam the_dp_ram.numwords_b = RESPONSE_FIFO_DEPTH;
       // defparam the_dp_ram.address_reg_b = "CLOCK0";
       // defparam the_dp_ram.outdata_reg_b = (LATENCY == 2)? "CLOCK0" : "UNREGISTERED";
	   
	  end else //other than Diamond Mesa 
	  begin
	    // TODO:  Change this to an inferrered RAM when Quartus II supports byte enables for inferred RAM
       altsyncram #( 
			.operation_mode                     ("DUAL_PORT"),
			.lpm_type                           ("altsyncram"),
			.read_during_write_mode_mixed_ports ("DONT_CARE"),
			.power_up_uninitialized             ("TRUE"),
			.byte_size                          (8),
			.width_a                            (RESPONSE_FIFO_WIDTH),
			.width_b                            (RESPONSE_FIFO_WIDTH),
			.widthad_a                          (RESPONSE_FIFO_DEPTH_LOG2),
			.widthad_b                          (RESPONSE_FIFO_DEPTH_LOG2),
			.width_byteena_a                    (RESPONSE_FIFO_WIDTH/8),
			.numwords_a                         (RESPONSE_FIFO_DEPTH),
			.numwords_b                         (RESPONSE_FIFO_DEPTH),
			.address_reg_b                      ("CLOCK0"),
			.outdata_reg_b                      ((LATENCY == 2)? "CLOCK0" : "UNREGISTERED")
	
	   ) the_dp_ram (
         .clock0 (clk),
         .wren_a (wrreq),
         .byteena_a (write_byteenables),
         .data_a (wr_data),
         .address_a (write_address),
         .q_b (rd_data),
         .address_b (read_address)
       );
       // defparam the_dp_ram.operation_mode = "DUAL_PORT";  // simple dual port (one read, one write port)
       // defparam the_dp_ram.lpm_type = "altsyncram";
       // defparam the_dp_ram.read_during_write_mode_mixed_ports = "DONT_CARE";
       // defparam the_dp_ram.power_up_uninitialized = "TRUE";
       // defparam the_dp_ram.byte_size = 8;
       // defparam the_dp_ram.width_a = RESPONSE_FIFO_WIDTH;
       // defparam the_dp_ram.width_b = RESPONSE_FIFO_WIDTH;
       // defparam the_dp_ram.widthad_a = RESPONSE_FIFO_DEPTH_LOG2;
       // defparam the_dp_ram.widthad_b = RESPONSE_FIFO_DEPTH_LOG2;
       // defparam the_dp_ram.width_byteena_a = (RESPONSE_FIFO_WIDTH/8);
       // defparam the_dp_ram.numwords_a = RESPONSE_FIFO_DEPTH;
       // defparam the_dp_ram.numwords_b = RESPONSE_FIFO_DEPTH;
       // defparam the_dp_ram.address_reg_b = "CLOCK0";
       // defparam the_dp_ram.outdata_reg_b = (LATENCY == 2)? "CLOCK0" : "UNREGISTERED";
	  end
  endgenerate
  

  always @ (posedge clk)
  begin
    if (areset)
    begin
      internal_used <= 0;
    end
    else
    begin
      if (sreset)
      begin
        internal_used <= 0;
      end
      else
      begin
        case ({wrreq, rdreq})
          2'b01: internal_used <= internal_used - 1'b1;
          2'b10: internal_used <= internal_used + 1'b1;
          default: internal_used <= internal_used;
        endcase
      end
    end
  end


  //assign internal_empty = (read_address == write_address) & (internal_used == 0);
  //assign internal_full = (write_address == read_address) & (internal_used != 0);
  assign internal_full = (internal_used[RESPONSE_FIFO_DEPTH_LOG2] == 1);

  //assign used = internal_used;    // this signal reflects the number of words in the FIFO
  //assign empty = internal_empty;  // combinational so it'll glitch a little bit
  assign full = internal_full;    // dito


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NRiRzr3LwZyyP+21SPqRCN8BBwkSnvCtxedxoBCxTwMQb9RpfioeEePnwWELKDH16WdTxA+PbZdClpwSf9sBpg5197lxyHdmkJjkMfpFbVb8mtxygKVA4Wb2Nu3F9quGg2fmf065nMWzJ0BRHvW41enH68R/FjYDB5HbiUPIlGNfneIKJXkNFxVFRMQC8WkgaaT6Fux8/iV4RFkW4qMXZkgwDIQFMk+yP9/Zg7iSnsr52KjvyqKt7fP3l66jkjESEwpvfBTRPwQMJst2ieKA8WOqhzpbi+Y6bp8uKdoeliLqfSsgrshrnVcpqJZZ1TU411qjAwiXF1B4q3rsIJU22ZI81m8TlZrKCcg3mDbwlZ3AZz/8kJiRy0xoMZniC6rXW2y48ur/wDbFFx/7imSc46Y7w9+NPSUyIch/CE7t0eUrRLn36H3pXDwwnKz7nGgD9OU8WE8UrQ9UwWKvafhC5VLuefoIUaBWSkScppERTkwzqpwbJKTz7PXpZ6BnAfQjR10rh7JJapuS39rKKYk8jd/Uv3OT1gQFdb2GO7humZbourUxdYz2bJGA0MKQ8mr2Hm7scbDNmcHrR7X99cOVrwiKQnaWhssZXs9uL2GWCR2LDGqn3Ivh3kLlCG5DrBuKDretBM0xBAHzvtzk7DZTxPiE9aCMpAHoZwwyF0/0/wqbV3vkiB+pmz7YV5mFHVRZtAspb5/BP6ERacxXz7lO+QSz+nRzVDCUDkpqXACIb4EaaClj0i2lR94RWG3W3hMJVDnDr53z+83xyMc/0fqAueN"
`endif