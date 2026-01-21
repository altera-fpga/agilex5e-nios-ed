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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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
// 
// -----------------------------------------------
// False path marker module
// This module creates a level of flops for the 
// targetted clock, and cut the timing path to the
// flops using embedded SDC constraint
//
// Only use this module to clock cross the path
// that is being clock crossed properly by correct
// concept.
// -----------------------------------------------
`timescale 1ns / 1ns

module altera_tse_false_path_marker 
#(
   parameter MARKER_WIDTH = 1
)
(
   input    reset,
   input    clk,
   input    [MARKER_WIDTH - 1 : 0] data_in,
   output   [MARKER_WIDTH - 1 : 0] data_out
);

(*preserve*) reg [MARKER_WIDTH - 1 : 0] data_out_reg;


assign data_out = data_out_reg;

always @(posedge clk or posedge reset) 
begin
   if (reset)
   begin
      data_out_reg <= {MARKER_WIDTH{1'b0}};
   end
   else
   begin
      data_out_reg <= data_in;
   end
end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OXNnFQivOaTbYDBteuj9TDjrjldAV0lMv2HTqMs7MXoA9NkZBOZEaGOButyjAZHX6kJW/zRSgaX/3FYjRd66VjWrRcsck1f2RCfuYUWD5ZB2r6cf8+rWfYfGuvVCp17DPb2xMrBysNpoNRUgwih8w10gq6e3qqEnRGVCBmf/PtehtpPlGv2Ly7GyUBhZChvL+AuZDQNzprNpVQnNVH1BUOdGd6NlcV9AondqkcKGtCYPAcsO641j/pvNIinVIXrr4gDW9WaCNout02FKc5zLyRACIBHBEpBrHGBKqBVrO28MaQQsgDubdFvl2jT0+V87Pp74T0Fo9aufGtLrVwTP2cDQ9ujqCXJLF410dHvdkEE0UDASrgqaKIQtDKpFeNY0YCTF4ddMFy6mLE8r1g4NXf4B1WD94cxgCbJEmKAaQ43w0gZwhNp2uRqM5XWAKg1hL8w9oMa1z02w2NUCO+EX9F4LUmSCdMK8ELNdpa78IVWoL05HilarGPv5fj7KCokW8qS4HdCWS55OWNFICEITTu49Ps9kHhNRwQwJRvFEF20ti1rr1NMDd3rTR1puK45XNVn9yj4qPcjcOgXkeKVQar63YQucN4W0ydh3K2G7ANbs5uET/foHI/wglUQUIag0ya+50SdTlHSBxV1WbMhiyTlEuyF/Awb8vjZfd7nNPcXpWSyVelJOYlPF69vkqzhWgcXeuJJ+Xfjr8eoAtkyW/+Tog4IYwHWf9mQLt39nEnmI3SyJpg+qIxEsYxlEKM6lxEUb+rlPutWRWDkiFc6FjTzxIPehRnuTPk/OrVHMl7lag8ToVD+YWVpwTjqxWx6Y3Ei0/ff3G4rIswim/kC+m+dmXASXg2YZubYBjXniJ9iy5eqnj6OOVtIMAcANbPDSamwygMpEPNA/CektXZ1FFUjSnWSxXhNIGxuvMK977wwx+XNadcQWmg/9aVspEK6A4NORpNinRNKsLhpaEWaweZfgl/u1UueWA+tOUUcevl8NkZFrz8SSTID8sM2TBdYW"
`endif