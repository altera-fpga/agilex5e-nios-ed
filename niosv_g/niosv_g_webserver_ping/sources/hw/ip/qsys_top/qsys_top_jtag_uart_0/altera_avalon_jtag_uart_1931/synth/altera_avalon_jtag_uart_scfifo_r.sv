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

module altera_avalon_jtag_uart_scfifo_r #(
  parameter FIFO_WIDTH = 8,
  parameter RD_WIDTHU = 6,
  parameter read_le = "ON",
  parameter readBufferDepth = 64,
  parameter HEX_READ_DEPTH_STR = 64
  ) (
  // inputs:
   clk,
   fifo_clear,
   fifo_rd,
   rst_n,
   t_dat,
   wr_rfifo,

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
  input                     fifo_clear;
  input                     fifo_rd;
  input                     rst_n;
  input   [FIFO_WIDTH-1: 0] t_dat;
  input                     wr_rfifo;


wire                      fifo_EF;
wire    [FIFO_WIDTH-1: 0] fifo_rdata;
wire                      rfifo_full;
wire    [RD_WIDTHU-1: 0]  rfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  altera_avalon_jtag_uart_sim_scfifo_r
  #(
      .FIFO_WIDTH         (FIFO_WIDTH),
      .RD_WIDTHU          (RD_WIDTHU),
      .HEX_READ_DEPTH_STR (HEX_READ_DEPTH_STR)
   )
altera_avalon_jtag_uart_sim_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n)
    );


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  scfifo rfifo
//    (
//      .aclr (fifo_clear),
//      .sclr (1'b0),
//      .clock (clk),
//      .data (t_dat),
//      .empty (fifo_EF),
//      .full (rfifo_full),
//      .q (fifo_rdata),
//      .rdreq (fifo_rd),
//      .usedw (rfifo_used),
//      .wrreq (wr_rfifo)
//    );
//
//  defparam rfifo.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
//           rfifo.lpm_numwords = readBufferDepth,
//           rfifo.lpm_showahead = "OFF",
//           rfifo.lpm_type = "scfifo",
//           rfifo.lpm_width = FIFO_WIDTH,
//           rfifo.lpm_widthu = RD_WIDTHU,
//           rfifo.overflow_checking = "OFF",
//           rfifo.underflow_checking = "OFF",
//           rfifo.use_eab = read_le;
//
//synthesis read_comments_as_HDL off

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KOSTHiyshA8uxJMF8T8U//41sb1R7Z3fHelntRYjdiZlwSk7t4aHraEavYrayv1wn6fP6shvVdhyZI2wHRwy84bLSWgZNmqJDFydHJpg3VkLWrXoi4akRn4gkeNl5TjcVD/tcxM8ictsVGdlQY5q7UBZHheAGTwQcKg9LqbX4RxpwEbliYCMQc6ULiyw71c8kYiKEc9I0GMjaCbUH/uFMBB4J0fpFXRcnh5NR8y5P5LA5jfMDN4FjvcztLqqk/dsFeMZrI6zjF9RElQRQksa9auSPJrwKnU5lWGZSS7AfXqxduhMVjdpUnkh6WfeRWRqiepuxnNmNwKgDKACdcGl9Wu5pueIZa8CIwqZ1+7z7o215n2E551LIgZTlixxAtl28WBI6xVoizI2J2gEEqOuB8aj+c5YyOZiV0hleUkJKrHroXzaZaAUmwAK/eZ8B628CNit6kHHoYsAP3ZWuMiiPuCqItVbjwvHldgVCyiEBFDzicWMVZFOv1LfIwoocaoiyT+zX9JBvKwREZiREnYUJr0m1AIiLqYIMhESi6nw96/OSZWFjwleWlNUxcsrIPcBBg7GAFgk8K6s6SjDYGwLNx1f8I12PslCIvo7ncsbfgIc1fZICI5Z7i/d3XcWhLzrsdw87sJ7SSaoEcd2JAET5YkLhtSTxDrP7zVlIEyrFq2EMfv1C700kBwzE6Ef5YtGJ1fms/rdGOuq4xL7/KUAjFZKACeIooFVS0LGJ5sSr5n0xG+ayYEB4BsdEJhoYUSfYcGEUhTGVQytmn7GULDhIYX58o8qC0gnbfXSmYou3SrlygEYF6P38y6p1bQMAkLFj8IHaBu4RfZfbaz5Uxtlvd+hzhDeRMDLvKRqTLWLLc+p7OkdIy3ubo49dnK5Q6uI3Ow/lNRchKY9zo1HrZUIWylZo4la3weinAmm0bcySLrEp0wKvdsEnDOuxdvHPlDCuqEpFyUX2Og+6G8s7slD7AUvC3qRFl+Mb4Th7KNzPJ4Dy30YlLXHJbg6WkQsrQ5H"
`endif