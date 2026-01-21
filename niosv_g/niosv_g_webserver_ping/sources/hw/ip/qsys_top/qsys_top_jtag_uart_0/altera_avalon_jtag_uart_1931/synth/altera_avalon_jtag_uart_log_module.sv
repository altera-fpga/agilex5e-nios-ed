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

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 13469 16735 16788 

module altera_avalon_jtag_uart_log_module #(
  parameter FIFO_WIDTH = 8
  ) (
  // inputs:
   clk,
   data,
   strobe,
   valid
    )
;

  input                     clk;
  input   [FIFO_WIDTH-1: 0] data;
  input                     strobe;
  input                     valid;



//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
   reg [31:0] text_handle; // for $fopen
   initial text_handle = $fopen ("altera_avalon_jtag_uart_output_stream.dat");

   always @(posedge clk) begin
      if (valid && strobe) begin
	 // Send \n (linefeed) instead of \r (^M, Carriage Return)...
         $fwrite (text_handle, "%s", ((data == 8'hd) ? 8'ha : data));
	 // non-standard; poorly documented; required to get real data stream.
	 $fflush (text_handle);
      end
   end // clk


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KOSTHiyshA8uxJMF8T8U//41sb1R7Z3fHelntRYjdiZlwSk7t4aHraEavYrayv1wn6fP6shvVdhyZI2wHRwy84bLSWgZNmqJDFydHJpg3VkLWrXoi4akRn4gkeNl5TjcVD/tcxM8ictsVGdlQY5q7UBZHheAGTwQcKg9LqbX4RxpwEbliYCMQc6ULiyw71c8kYiKEc9I0GMjaCbUH/uFMBB4J0fpFXRcnh5NR8y5P5JK04xJKbPi5BeU+cMm0ojPTVuxsFhT/lP9SlXgdAYMHh5erJA3UwB4Ht++eOAfIqOf2v+XDGIP8MdhyAuWLOhyzvZh3iDTLaeGCOyweT3mnoCPg1E9e3oPg4cBtaRvJLJf1kGHBKoLEfhbganmGsMIw5aWcUm3i5+Zg1Dy7u5iZKDENFy4SLESfVpALjoG0mz+SUocwr6K4WzItvR4tFnxKCyst/l1dJe60nTar0o6nNF6FGyYPrVHxOc15nd7+fHDw3Uy7Ne6bFi2IoH0ErFmZsKDcfl2rnXTxZ3gV3FoYl+abH2T2ipFeH+QdbyRg6bvn/6V+g68cBiV5bMildKDGs26vDIqiESZbZbISjhvG/fNWI95fFp5H8XcspyY1cHKVie+atY0eL9WRQs56+0D2vjH3j7Ko6FQxsraGaX3WT+omeq4WEWB5+ZmWdxa+qPb7vjoGXVBJraWnnW7GazXXSHQYoTHjazFmpWwwqIeuAUw+iAPtIP3GGEddgt3yyJZaOVdkcsnzmNMR7acrHVfapkobDdMpDpiQMRSDxY+8+JE//vStzVz6zntm/xxzwJooobnSAUvKqD5Meq74bu05FUWUTkeB4jIKDmDyWJ+OoAbpUQZmMIQ5f6CAUUY8abPbnPS1rHR+X5OLgPw6h7O4fYkGglJ4aaFV1upxslfgZKvi2eqMFI9lXM440/U5YbtvivtvvYih/ZBGiD9YYW7uy3TvDKrkpflv+riDwNHb5oV0VTdyQoZaZ/AAapTygSGd2fRvQTE3lvQk5WJrpco"
`endif