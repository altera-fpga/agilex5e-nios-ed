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
	This logic recieves registers the byte address of the master when 'start'
	is asserted.  This block then barrelshifts the write data based on the byte
	address to make sure that the input data (from the FIFO) is reformatted to
	line up with memory properly.
	
	The only throttling mechanism in this block is the FIFO not empty signal as
	well as waitreqeust from the fabric.
	
	Revision History:
	
	1.0 Initial version
	
	2.0 Removed 'bytes_to_next_boundary' and using the address to determine how
	    much out of alignment the master begins.

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 16753


module ST_to_MM_Adapter (
  clk,
  reset,

  enable,
  address,
  start,
  waitrequest,
  stall,
  write_data,
  
  fifo_data,
  fifo_empty,
  fifo_readack
);

  parameter DATA_WIDTH = 32;
  parameter BYTEENABLE_WIDTH_LOG2 = 2;
  parameter ADDRESS_WIDTH = 32;
  parameter UNALIGNED_ACCESS_ENABLE = 0;  // when set to 0 this block will be a pass through (save on resources when unaligned accesses are not needed)
  localparam BYTES_TO_NEXT_BOUNDARY_WIDTH = BYTEENABLE_WIDTH_LOG2 + 1;  // 2, 3, 4, 5, 6 for byte enable widths of 2, 4, 8, 16, 32

  input clk;
  input reset;
  
  input enable;  // must make sure that the adapter doesn't accept data when a transfer it doesn't know what "bytes_to_transfer" is yet
  input [ADDRESS_WIDTH-1:0] address;
  input start;   // one cycle strobe at the start of a transfer used to determine bytes_to_transfer
  input waitrequest;
  input stall;
  output wire [DATA_WIDTH-1:0] write_data;

  input [DATA_WIDTH-1:0] fifo_data;
  input fifo_empty;
  output wire fifo_readack;
  

  wire [BYTES_TO_NEXT_BOUNDARY_WIDTH-1:0] bytes_to_next_boundary;  
  wire [DATA_WIDTH-1:0] barrelshifter_A;
  wire [DATA_WIDTH-1:0] barrelshifter_B;
  reg [DATA_WIDTH-1:0] barrelshifter_B_d1;
  wire [DATA_WIDTH-1:0] combined_word;  // bitwise OR between barrelshifter_A and barrelshifter_B (each has zero padding so that bytelanes don't overlap)
  wire [BYTES_TO_NEXT_BOUNDARY_WIDTH-2:0] bytes_to_next_boundary_minus_one;  // simplifies barrelshifter select logic
  reg [BYTES_TO_NEXT_BOUNDARY_WIDTH-2:0] bytes_to_next_boundary_minus_one_d1;
  wire [DATA_WIDTH-1:0] barrelshifter_input_A [0:((DATA_WIDTH/8)-1)];  // will be used to create barrelshifter_A inputs
  wire [DATA_WIDTH-1:0] barrelshifter_input_B [0:((DATA_WIDTH/8)-1)];  // will be used to create barrelshifter_B inputs




  always @ (posedge clk)
  begin
    if (reset)
    begin
      bytes_to_next_boundary_minus_one_d1 <= 0;
    end
    else if (start)
    begin
      bytes_to_next_boundary_minus_one_d1 <= bytes_to_next_boundary_minus_one;
    end
  end


  always @ (posedge clk)
  begin
    if (reset)
    begin
      barrelshifter_B_d1 <= 0;
    end
    else
    begin
      if (start == 1)
      begin
        barrelshifter_B_d1 <= 0;
      end
      else if (fifo_readack == 1)
      begin
        barrelshifter_B_d1 <= barrelshifter_B;
      end
    end
  end


  assign bytes_to_next_boundary = (DATA_WIDTH/8) - address[BYTEENABLE_WIDTH_LOG2-1:0];  // bytes per word - unaligned byte offset = distance to next boundary
  assign bytes_to_next_boundary_minus_one = bytes_to_next_boundary[BYTES_TO_NEXT_BOUNDARY_WIDTH-2:0] - {{(BYTES_TO_NEXT_BOUNDARY_WIDTH-2){1'b0}}, {1'b1}};
  assign combined_word = barrelshifter_A | barrelshifter_B_d1;

generate
genvar input_offset;
for(input_offset = 0; input_offset < (DATA_WIDTH/8); input_offset = input_offset + 1)
begin:  barrel_shifter_inputs
  assign barrelshifter_input_A[input_offset] = fifo_data << (8 * ((DATA_WIDTH/8)-(input_offset+1)));
  assign barrelshifter_input_B[input_offset] = fifo_data >> (8 * (input_offset + 1));
end
endgenerate

  assign barrelshifter_A = barrelshifter_input_A[bytes_to_next_boundary_minus_one_d1];
  assign barrelshifter_B = barrelshifter_input_B[bytes_to_next_boundary_minus_one_d1];
  
generate
if (UNALIGNED_ACCESS_ENABLE == 1)
begin
  assign fifo_readack = (fifo_empty == 0) & (stall == 0) & (waitrequest == 0) & (enable == 1) & (start == 0);
  assign write_data = combined_word;
end
else
begin
  assign fifo_readack = (fifo_empty == 0) & (stall == 0) & (waitrequest == 0) & (enable == 1);
  assign write_data = fifo_data;
end
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NRYoowxYXCEVDA5N7VOdRle9KtceSsTqJd6gnOYH0tlcgKHuCzlyAIKqLfTmr+vzCu27aIm4tbQCD9TPTxCGElrVlt3m1VNnwh8z8kn4s6VJZl/I7If/2mbxkZdH8eNE9FWvBBsMl6TuyzZlo85NUQAYMNAi9EcI0uqRuDBJgJ1vTKzOdMsF4bXFP72ALcSmGUZSa8X6V3jrv5SzQWHSIbsbAvpwYVfMhF73At661ziDvZMVC/Kh9coaAWInOu0I6BRTcUqqvUBBqTTc0+MrheJ0QUUS+t0zxwnM4wjUdu5LGpwpcnYPZ+bDBFpNbe5DAmotQLygB7yBbR/+7zmrywm/O9tG/aFgVQK+ShAAq0lSb5SFfXWGBo2SfguO0KpQP3uJ/sBN1Xw7Fm1M0slJ0E8OXeQCgXLqdWLMW05/H0J9Cjrk/PuCNaT22QzisOGTdN4PzFZFGhXP6MhzYTzNx/LHCibKy3ET9rzjlKKKW21Sjkp31eJgJL0UxohjuAqp4QEZKts7ypon2RaaVLTxtZir4jvFOtyL1UrFQ0QNij1N9YVnKBnZaKMjak8PKxxPsxLfXCf8YlUIfE05NCSdAGOGLt8432Q7sNl6Znr9sV/PiQe1FYCjAlE7VZS8d1B6A0PGQY08OIGxsNK5ZJ5IufC/qPek4cV1X6VbMxa4azH+sBIeJ6+auu9gPIIt4Kirl+oOo68yhYOGnqp+Dur+6nH390e/mdBrUpFJ0syHThZh+Q3dxwEFeH1zcI+t3aQmPY5vaovd/fidRbrY41MxgKA"
`endif