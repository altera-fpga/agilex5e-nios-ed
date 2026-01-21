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



// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_eth_tse_std_synchronizer.v
//
// Description : Contains the simulation model for the altera_eth_tse_std_synchronizer
//
// Owner       : Paul Scheidt
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_eth_tse_std_synchronizer
//
// Description : Single bit clock domain crossing synchronizer. 
//               Composed of two or more flip flops connected in series.
//               Random metastable condition is simulated when the 
//               __ALTERA_STD__METASTABLE_SIM macro is defined.
//               Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//               on the Verilog simulator compiler command line to 
//               enable this mode. In addition, dfine the macro
//               __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//               with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
// END_MODULE_NAME-------------------------------------------------------------

`timescale 1ns / 1ns

module altera_eth_tse_std_synchronizer  #(
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   din,
    output  dout
);
    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_no_cut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din),
        .dout       (dout)
    );
    
endmodule
      
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "tTnsR2Y5Sym1r4K4WdcY1XWPCcsViFKfuEmlRdTbi5jTZZcM5g8KRrryQ6B/AcJKw7WbqN6HFXFkpVW14vwHO4LHnQRmAL01nQot12rHoNE9kJfzL6JHt13qKd7bt06ErFACnpJTwpMLCAyOn+gS5DeMiy5u/otEggP8SzMzY6MWv/4a+Bg49LiE3xr7S9IdudYnA7hVcfZFj9BD1CzD75g9ikkjlSNJcyB8spHTarTqy3CnrzqVkFkZzSmh2cMj7DKMGXBGQpA6OUfz35T5kufxTuoODgn9h/3Pylmqc08R0fpdiRyycZaLofExW8tHRUAPQeh4phv1uRqTGR8ynJAiBhwKI94eduyjWspjtROm/1187u+/g9vxONewsm4OK9L3g/RqBqNWAGsgRA7CdpowJkWZXcWnhZSxznTMrKMlavUW8Ux59scsKHUWtvFtMHh4OQDBwt7oReTVV+/0mIWV4K342zdhlgwKjvKkNcn42S7irQzEZMAT5A9ekdfTNVm4UqXyY5ssVosvJJW4i8ANJLxUg9A3HU5d0nXL4AHmb/JvJ16TxKXj92cz3/7hO7bLiFecylIB/F63K57C1irFUoZ4QZRPaKS9hTmH+4NDVboerfaBrZlR1yY82H2UWLIVv0Vr5Zo4k9hqVuT+ajhUfcsh/nFRLQaGPOqmQ5w91tnapENofnxSH6+ZNsZNrgmgzTW8Cuqxo91vNKQe/JFjLdddaheWfARrYJMhyBleO7e33u15C2UqAIEBoxu/6IcSIV7iiED0erjjRW9dQqYdFYFv6Hfd6jUZUPs9i135PP4YUfS2uZRt5R1b+BUHmxLHWjXB4wr6y0chbQLFacMdJu6/1szf1MULmHrAx6t3gh+BY993syW+VorFTxqpSefVoBUVab44ltaGveCio0SXwjSlc7w0cUjLE9wimI/+SjauZmjpQfY7aP5IFTKP3x0VY/uJxy30FtBifnTf9YlTPkwFpbD1+lmgpUSOcyxJCYCq0LPTuGlJkd01Kwk7"
`endif