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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


// $Id: //acds/main/ip/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter.sv#68 $
// $Revision: #68 $
// $Date: 2014/01/23 $

`timescale 1 ns / 1 ns

// -------------------------------------------------------
// Adapter for uncompressed transactions only. This adapter will
// typically be used to adapt burst length for non-bursting 
// wide to narrow Avalon links.
// -------------------------------------------------------
module altera_merlin_burst_adapter_uncompressed_only
#(
    parameter 
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);
    localparam
        PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
        NUM_SYMBOLS    = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

    always_comb begin : source0_data_assignments
        source0_valid         = sink0_valid;
        source0_channel       = sink0_channel;
        source0_startofpacket = sink0_startofpacket;
        source0_endofpacket   = sink0_endofpacket;

        source0_data          = sink0_data;
        source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;

        sink0_ready = source0_ready;
    end

endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "pHkNffi7iWdhgH/vP7Nrr5okpDh/ePG5J4w4ngx4Rbtmau/eLMXylu/LFOT+NnF6SXEJ4SsUJX00D8P5HXEh35wNTNZ8hNnrL3rRfiJ5r0JMZdoSeNB5cz2atDTPBlCy69NKsBHC4jBWUD8x+po817+5jvn/4hpaVZrE/6K6Kl/2Z+Kkq3ucmtg9rHJRRqUMqgl0R3pDQh3xK6tdiJ8bmBx1eqMP0SI5XY/2FFS9x9xIFhHn456CoMED+g9AOxybmhY911slPpYpBSaJviidnSG8SUOvw1jq4OthfHnHUGkD7I6NDT+wEULkMpC87vqdqpOM7Hj+OAx0xDQ5b5Qh/gdN8JP7nQPmJpzDKhHnfXqgppwZ7Vus8GLCXAb7NCp5UuOq2P4VrCOB4zFLDb11X04bqYzKHG69A8RsqXYICzDr+RnmoMRMVVGRc6xY36c21fhrkvPtz7/cB9dMe9SooWV/+JFCTJaZThsk3ZBh90sl4h4zOo10X5sLhFSfriYeWbEFkc0QppYG7qh9z+fN1hdPnMpb5LNxhX7OCzSw14/gPwgITaTzdHGa9KfcpMk7G9IyF+/3GSU4MJSUIIBC9rIYL54eeHXcabjskmrbg6iUkpCI3pGMtf0X44yf9fEzWiJSlEADdLzU5LgYAQPg59sY/tVhhk7EMyij1/YjrMHbXNc+9sLtRlHU8ltynIZBl0hNm8fGDAnzqxJKlr+GgcuPsu8HqBCCuz1Zru5LlYBkxF+5UAeYgI+7fcFhTk0s4Ri9OoQFyIVaHrcjCiE5bHIrVUmSW7Y5a8urv24IspSCbT/8Q8Y9KZdElK3Rmsw+SbMscF8JH7V//qXgVk46t+w0hVcekChZPc8CX/AlKHr2gkAsaXYHtGaVJpH645x693c13OLlzMZDPRajKV8o1SCTSDcEJVMyje4JZs33K3zRU0v53jG58zchB9FgUzWGQvKmWSv/Ay/lmRS7HcqPzFHmEB51WGEGIQlo8ryCCvlIaMXpfsjvbnrYx8/mYctS"
`endif