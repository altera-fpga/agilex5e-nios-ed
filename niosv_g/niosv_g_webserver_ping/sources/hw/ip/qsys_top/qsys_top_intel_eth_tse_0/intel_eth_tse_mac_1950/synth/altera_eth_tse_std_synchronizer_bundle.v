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


//
// Module Name : altera_eth_tse_std_synchronizer_bundle
//
// Description : Bundle of bit synchronizers. 
//               WARNING: only use this to synchronize a bundle of 
//               *independent* single bit signals or a Gray encoded 
//               bus of signals. Also remember that pulses entering 
//               the synchronizer will be swallowed upon a metastable
//               condition if the pulse width is shorter than twice
//               the synchronizing clock period.
//

`timescale 1 ps / 1 ps
module altera_eth_tse_std_synchronizer_bundle  (
                                        clk,
                                        reset_n,
                                        din,
                                        dout
                                        );
    // GLOBAL PARAMETER DECLARATION
    parameter width = 1;
    parameter depth = 3;   
   
    // INPUT PORT DECLARATION
    input clk;
    input reset_n;
    input [width-1:0] din;

    // OUTPUT PORT DECLARATION
    output [width-1:0] dout;
   
    generate
        genvar i;
        for (i=0; i<width; i=i+1)
        begin : sync
            altera_eth_tse_std_synchronizer #(.depth(depth))
                                    u  (
                                        .clk(clk), 
                                        .reset_n(reset_n), 
                                        .din(din[i]), 
                                        .dout(dout[i])
                                        );
        end
    endgenerate
   
endmodule // altera_eth_tse_std_synchronizer_bundle
// END OF MODULE
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "tTnsR2Y5Sym1r4K4WdcY1XWPCcsViFKfuEmlRdTbi5jTZZcM5g8KRrryQ6B/AcJKw7WbqN6HFXFkpVW14vwHO4LHnQRmAL01nQot12rHoNE9kJfzL6JHt13qKd7bt06ErFACnpJTwpMLCAyOn+gS5DeMiy5u/otEggP8SzMzY6MWv/4a+Bg49LiE3xr7S9IdudYnA7hVcfZFj9BD1CzD75g9ikkjlSNJcyB8spHTarRYHejbv7SG63v9Mv0krWNUpVDpv8T+ff5zpqxNZRHQfUhSDz3blayVHrEdOuyLl11pGnJH8tc1wiJurOHqKiJ5nYT+t7ME6QeEdrsBPKt706HK4JUcnpTX28XbGmi8f9we4HDqwaxa8BxXRD1xoMSX5j+Xzr7zsa+gmGIUlJmrl8WfQwI0xY+RcFclMtIpZWlJRvq2M7HLx5FLjYuS6/j/ujKQMzGpAWPorKuGUQ2D+BymbwcRakFoCbOJZbjpMvqDLZLylGymaFkQvO/Kgo9R0En/CU0pMLxuikHEJeACfxjwaicByT9ZQGKkHOXTyWGoC2FdBP2MBWhHbPV2VPnkfWPLAOeVNWCUVwuDes5FGgI0qigVyyh4qoC6keEZatWPNgmR3KS+Vdk209jYn9qTWsUEQ1zrnPcBWMki/XkFrNGT3VlUiXo+23YBF7ZCETBUo7SfSgSuR6OZV+1Pqcm/1LmXbDIxLQCpul2caEGYdpKCem8cCqkGXiQ3eDDg/CWnWAn03Ae+Th1rxkyOP3jBY6dvRoIbhy7JbgJcsEU8CVVNWDss8QYFhWyoX+EXWGNWCPhcEzTv5Rn+KNqNwe0SgjD7dkpS7JTWQ30BYjqJDq5VD3lwgGJ0GQqdG2G08YOkwUsSqPyF6arM8Hk7E8qR68SJWJaZrMcr2AV/omzgsVyPQvWMELTjA/C7IkWlKVMKHQfWaDksH4lsIvZcVMzjPU4x0QlopXy3t/p6NnnV6Rigao50KBbpdv9xQd+Ym8QNN9jE1n14hPqQ/EVL7zl8"
`endif