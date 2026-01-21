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


// $Id: //acds/rel/25.3/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2025/08/01 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

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
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "pHkNffi7iWdhgH/vP7Nrr5okpDh/ePG5J4w4ngx4Rbtmau/eLMXylu/LFOT+NnF6SXEJ4SsUJX00D8P5HXEh35wNTNZ8hNnrL3rRfiJ5r0JMZdoSeNB5cz2atDTPBlCy69NKsBHC4jBWUD8x+po817+5jvn/4hpaVZrE/6K6Kl/2Z+Kkq3ucmtg9rHJRRqUMqgl0R3pDQh3xK6tdiJ8bmBx1eqMP0SI5XY/2FFS9x9z6L5okOqxqi1REskvPYNNhcCEgg02IJ/oVuSgzhiU6TAdZMYfQ3TuJpcRbMXG4MPE0UOxg4khj3RSXPvD5MIogXkUKBdIa++cW2TfgSPT9veX3I2WEQT+5hZMKZWEwZbHnSJCqrGpeUAtDi3yzCgApCf3ove9Gixgq7sceWcmwyz/7ujY0yCsDizwhJ0CZZfbnYwajz1AfpgW6m0M87UhsjPxa3vCW99PpaNuPC7A8RBtl5Dqn+gHAnm/PO+0/ElOVf07K1XwH2a2dBFFyz8oBZLbYA5PKodSbFma4bF/MrNBQdP5Hv22xhBVGBhNSqoFQBhLlNhkiE17yJXNfLe+2p/xqsz8bQULo+IZLag5Ycy7klu7WqpX89mzhna2eJRjeSQ4BGUy5AlEUuqtTvcjhbyAZz87eSpnnGgynyEmbDM3opNUMGotTR6A37oJkvxiKU2UqbJw85vYAYfJZXd/N3uNoTk9e89j0iNPH+Hmaoy4z+Uy2soQ60FbDCe3ehiz+zALFwyofruaGcqRsiFodXJk1b6oNy5hP6Xs2E7Fc+wu9uRCYr5atYpUn2nAqMMJLKwzM0C7jqbvj4WEDfc4nUfBwTLUpYPWIPHeoPCrrKfVioFGdOglnVrxBApc+go9cx4PQvfaV+rXxblRCH8fC27MpiiD54O+xTf+g36vHsZZW5KxMfFsXx3qR1lqTDlDqmsonkRUNuDROSvibAG1iDHgAguI6Lp9wCTOWSlJM7bTRRxuF4LwfgfkBpmdjimdvcxgXpZ0hvb+UC93dC3iG"
`endif