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


module pb_debounce(
    input wire clk,
    input wire [3:0]pb_in,
    output reg [3:0]pb_out
);
 parameter M = 8;
 reg [M:0]shift;
 //shift: wait for stable input
 always @ (posedge clk) 
 begin
 // shift register to capture input
   shift <= {shift[4:0],pb_in};
   if(~|shift)
     pb_out <= 1'b0;
   else if(&shift)
	  pb_out <= 1'b1;
   else pb_out <= pb_out;
 end
 endmodule