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

module altera_avalon_jtag_uart_sim_scfifo_r #(
  parameter FIFO_WIDTH = 8,
  parameter RD_WIDTHU = 6,
  parameter HEX_READ_DEPTH_STR = 64
  ) (
  // inputs:
   clk,
   fifo_rd,
   rst_n,

  // outputs:
   fifo_EF,
   fifo_rdata,
   rfifo_full,
   rfifo_used
    )
;

  output                    fifo_EF;
  output  [FIFO_WIDTH-1: 0] fifo_rdata;
  output                    rfifo_full;
  output  [RD_WIDTHU-1: 0]  rfifo_used;
  input                     clk;
  input                     fifo_rd;
  input                     rst_n;


reg     [31: 0]           bytes_left;
wire                      fifo_EF;
reg                       fifo_rd_d;
wire    [FIFO_WIDTH-1: 0] fifo_rdata;
wire                      new_rom;
wire    [31: 0]           num_bytes;
wire    [RD_WIDTHU+1: 0]  rfifo_entries;
wire                      rfifo_full;
wire    [RD_WIDTHU-1: 0]  rfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  // Generate rfifo_entries for simulation
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          bytes_left <= 32'h0;
          fifo_rd_d <= 1'b0;
        end
      else 
        begin
          fifo_rd_d <= fifo_rd;
          // decrement on read
          if (fifo_rd_d)
              bytes_left <= bytes_left - 1'b1;
          // catch new contents
          if (new_rom)
              bytes_left <= num_bytes;
        end
    end


  assign fifo_EF = bytes_left == 32'b0;
  assign rfifo_full = bytes_left > HEX_READ_DEPTH_STR;
  assign rfifo_entries = (rfifo_full) ? HEX_READ_DEPTH_STR : bytes_left;
  assign rfifo_used = rfifo_entries[RD_WIDTHU-1 : 0];
  assign new_rom = 1'b0;
  assign num_bytes = 32'b0;
  assign fifo_rdata = 8'b0;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KOSTHiyshA8uxJMF8T8U//41sb1R7Z3fHelntRYjdiZlwSk7t4aHraEavYrayv1wn6fP6shvVdhyZI2wHRwy84bLSWgZNmqJDFydHJpg3VkLWrXoi4akRn4gkeNl5TjcVD/tcxM8ictsVGdlQY5q7UBZHheAGTwQcKg9LqbX4RxpwEbliYCMQc6ULiyw71c8kYiKEc9I0GMjaCbUH/uFMBB4J0fpFXRcnh5NR8y5P5Ix6R2ueRQu9Dp9sKg8qjhaaNN8kOA7dYqpWz4xw2eMS47kShsolABXzsQF/L7zB9WXPJ1BETVo3PjfNFMTtNXE1HXdB84r60l/fz+X4DN6PjgMmb4rJOzuovBxzULnTFkiZmyKKcpqJG83+Qin5RfOXPlv5elNbzRbducnZJIDCd1vpNG9Foliie1GXUhYqR//FL4D8T46z3xVd9RUHbt04JljZDuEtq7zRK6ZpYPv7XMfns3NUkOM+aszPfH96RTyjPTRla7wtE0eDr9oqQ3v3ySUYLczQHbI6iHt+HFyjzpGbmhjGNFFp+XJ2/l+sUZK3wEqA8QrMbbWbuSjqBqvXkZWL6QCQH/ivl+XvmgOI4lTdUIKOvyY6RHQiaWmJjkc9rKM2rzGuhCRF9njp/AdVqgA2oZbZxtXOvCdpZGs3FhyrNIL9ZprqUbeJLwlpZ6FnPSf4suRVcx6adkyFM86p+0ZSdglz130nVYcot0BJM16+a3i7yjlAakkmpIUcZOAFDMNaZUquSDh59MguPbZPnIlp77AO6RS3mlhnOfVRJI3Okur0DFUSSZ+IzlQcGX+6zKTkookF1U6ClI33J1ut84FoiuRqEPHh4R2UzOf9FcKk/CCAOXuGOYMvAMBJk9kod8Gjejy1AQbEoYUs/7/ezAOQ3KsM7+lIhdY+y2y8XKLOgMvp/qmNXE0MI2pmgshaFzyeWp7CsT8QcxxXmV/njO4ea9qlbJYsqY8xLN5C7iVqcY6/s2QH+FHyWO8Vwr6oCpV9/9qbkHn1rqSpU2o"
`endif