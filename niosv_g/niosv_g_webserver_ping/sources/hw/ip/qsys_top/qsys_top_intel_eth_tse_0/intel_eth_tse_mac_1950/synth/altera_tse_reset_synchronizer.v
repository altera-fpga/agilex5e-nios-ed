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

// $Id: //acds/main/ip/merlin/altera_reset_controller/altera_tse_reset_synchronizer.v#7 $
// $Revision: #7 $
// $Date: 2010/04/27 $
// $Author: jyeap $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1ns / 1ns

module altera_tse_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R101,R105\"" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    // Please check the false paths setting in TSE SDC
    
    (*preserve*) reg [DEPTH-1:0] altera_tse_reset_synchronizer_chain;
    reg altera_tse_reset_synchronizer_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_tse_reset_synchronizer_chain <= {DEPTH{1'b1}};
                altera_tse_reset_synchronizer_chain_out <= 1'b1;
            end
            else begin
                altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
                altera_tse_reset_synchronizer_chain[DEPTH-1] <= 0;
                altera_tse_reset_synchronizer_chain_out <= altera_tse_reset_synchronizer_chain[0];
            end
        end

        assign reset_out = altera_tse_reset_synchronizer_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
            altera_tse_reset_synchronizer_chain[DEPTH-1] <= reset_in;
            altera_tse_reset_synchronizer_chain_out <= altera_tse_reset_synchronizer_chain[0];
        end

        assign reset_out = altera_tse_reset_synchronizer_chain_out;
 
    end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "tTnsR2Y5Sym1r4K4WdcY1XWPCcsViFKfuEmlRdTbi5jTZZcM5g8KRrryQ6B/AcJKw7WbqN6HFXFkpVW14vwHO4LHnQRmAL01nQot12rHoNE9kJfzL6JHt13qKd7bt06ErFACnpJTwpMLCAyOn+gS5DeMiy5u/otEggP8SzMzY6MWv/4a+Bg49LiE3xr7S9IdudYnA7hVcfZFj9BD1CzD75g9ikkjlSNJcyB8spHTarQM1ofA6DWxYiGcpip3NVe+T6UyuGLraxn5XUD23HDIhX/WTCthHsuHzlnPpQP79ErGitEo+aIVp994T4+dNMR0iXI/evGodNXwjBR6FBizfoTxNgD1IQdvAdUzsXXBTHPnNipi3VzBIOPvxcfcXrCJgPeDaK8A9pFF2xRAJVFWy+jSGnPJKqMr9DCURwxds/FvuVvGYx0/FRnpSd8LHTqyOMgzvca7eYgR3jtYRGcLbLrPWx3ZPadMcOaQlzjnORGM1fpgZeRr3Gsb3bZv58T6SHXBQf3X+Eghb9mzxffwBfHT170A0hw/WmkVxVFOmTAzHkbp/aMf0m7sfyv8QgkXi5C5dIA/+IB9oPulseKUeWhEjJjgwqua6xRUZLpGVjGdMyORSJjec5hdmbcw1Q9Sjyz+usi8jMKGFQjRe77DLnbVEazdczA0NwHIWPbTqTiiP9iQan9pDFT7jadAmhrDGy2q59edjxYFgcL+N13+Hv8kH2tNnNl267c9JKespezkGohCJyNjIGbyZhJEFlM8KO4T06CfO4dpUtot+n56+Ct2Tzf22DfrNkDnmVhJItydceMn/0oygZ7CfacHpSK1MigidzWfJ8L5MUbRmhpWXyA3zdaeYwGmwLskh2pHKTRWI6cEW7y5JeDxLI5eUj2LD4bCvOQBQ9vGMMDs4HJBcM0CCBDf5WOL9Fy8rK4JKzzVYwJIumGBXkKhR8B4kRix2OrF32WPZYKMwzU28BLQrmuhRb+lOx48EtGSpUlH9kMQHOGQLW5tjEFOAhBRJ9LU"
`endif