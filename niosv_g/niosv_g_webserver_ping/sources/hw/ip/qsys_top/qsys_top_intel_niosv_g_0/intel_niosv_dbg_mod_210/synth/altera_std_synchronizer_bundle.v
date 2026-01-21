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


// $Id: //acds/rel/25.3/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer_bundle.v#1 $
// $Revision: #1 $
// $Date: 2025/08/01 $
//----------------------------------------------------------------
//
// File: altera_std_synchronizer_bundle.v
//
// Abstract: Bundle of bit synchronizers. 
//           WARNING: only use this to synchronize a bundle of 
//           *independent* single bit signals or a Gray encoded 
//           bus of signals. Also remember that pulses entering 
//           the synchronizer will be swallowed upon a metastable
//           condition if the pulse width is shorter than twice
//           the synchronizing clock period.
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//----------------------------------------------------------------

module altera_std_synchronizer_bundle(
				     clk,
				     reset_n,
				     din,
				     dout
				     );
   parameter width = 1;
   parameter depth = 3;   
   
   input clk;
   input reset_n;
   input [width-1:0] din;
   output [width-1:0] dout;
   
   generate
      genvar i;
      for (i=0; i<width; i=i+1)
	begin : sync
	   altera_std_synchronizer #(.depth(depth))
                                   u (
				      .clk(clk), 
				      .reset_n(reset_n), 
				      .din(din[i]), 
				      .dout(dout[i])
				      );
	end
   endgenerate
   
endmodule 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "/+PPOwjLvL0pcr3VJdDUoytU37rTUUhJUDWtmOfTcFtrQHG58E4MxRVbKCry4loX+f6t3QMk1kPxNxqc0/Jc71BlZ3L7i76oXB6KA8ipMMbRH3NDrvtFQgexr1XVfL3CHLpESPErHRH62pzy4fetk/ijelms5INk32uo3GBFsO3tzej2l3wQZTWyj4D+QvjpxMXISGh9UUNTldgtickLkgug1fCSfaJKuBTyrq0ijI8cFsvpFxx6rybAHvyNzALXVoI1wBUGsslMJg4igjz6s8/JJ4Ccrog91r8m7YutdyWMd7NeVf1Xy7HMt4We0ZTsjgkpQGcIx1/xOiCJ9e9VervkIdUhH6KwK6vfT2Mu4f3f2Fng1PV7wQdU3c7X7zftCMOgC8lsjSgwpOB/GqUXLkSJxo0Wnax80qSREYn3zSBYoTUZrJSDy79hw8NFuhCW3pRLQSWPHBEbmFVFAwl6OU0BGaxQiUQzs29YrvQ75PQd5GGFAfIjwO4yBaRGuLV41cleB/bUM/ER9sJO50uEQThOnLJKxcXO/AXxZS00ZJWDvi2VSgHEOp/2sdtgbPITnDbq1tJGXBNV5zlA7ThAKnKUO9JfqSjw8b1VmG5pU5TI5/ZqHVkvS8v/wYWAyTfOlb2FAK/o0859nYo7HA35TDl3PHCz3A2C6hAsKjT3dxIRW9Pv8Oqb2emLW61mFv7TrHLYFExZfJPH5ksM3glDourEG7UAH+ba2EA24HX315VKAhsg01yQ7Xdk+qXRINhr3PlmXC05BhQF2hjwMkNB7+kiqvrXjFcjVubQbwxfx/6SW85z71wiTEG0S03ITGuHmqDMArekwKTAZ3DRuoZZGNkDrP1IFdwsNq3H3RcpUnwQkAB1KwY1cjbvYyLTcETl/9hzKBU90zgAe+bE9T/DKYSfj+fH7f3SlGz1PZLKKz8Z2vUBCR/078H+C1nIWZ3e1FcYYLYRHMUFwdqJsQZXaEXaAvR1Q2Q/4uXq7P0wbX8iQBSjxMEdUf6pK7E90DPs"
`endif