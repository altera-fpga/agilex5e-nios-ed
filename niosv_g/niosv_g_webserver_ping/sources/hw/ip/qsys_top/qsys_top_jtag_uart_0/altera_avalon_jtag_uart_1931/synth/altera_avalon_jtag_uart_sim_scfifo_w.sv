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

module altera_avalon_jtag_uart_sim_scfifo_w #(
  parameter FIFO_WIDTH = 8,
  parameter WR_WIDTHU = 6,
  parameter printingMethod = 0
  ) (
  // inputs:
   clk,
   fifo_wdata,
   fifo_wr,
   rst_n,

  // outputs:
   fifo_FF,
   r_dat,
   wfifo_empty,
   wfifo_used
    )
;

  output                    fifo_FF;
  output  [FIFO_WIDTH-1: 0] r_dat;
  output                    wfifo_empty;
  output  [WR_WIDTHU-1: 0]  wfifo_used;
  input                     clk;
  input   [FIFO_WIDTH-1: 0] fifo_wdata;
  input                     fifo_wr;
  input                     rst_n;


wire                            fifo_FF;
wire  [FIFO_WIDTH-1: 0]         r_dat;
wire                            wfifo_empty;
wire  [WR_WIDTHU-1: 0]          wfifo_used;


`ifndef QUARTUS_CDC
//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  altera_avalon_jtag_uart_log_module
    #(
      .FIFO_WIDTH (FIFO_WIDTH)
     )

altera_avalon_jtag_uart_log
    (
      .clk    (clk),
      .data   (fifo_wdata),
      .strobe (fifo_wr),
      .valid  (fifo_wr)
    );

string str_buf = "";

generate
  if (printingMethod == 0)
  begin
    always @(posedge clk)
      begin
        if (fifo_wr)
          $write("%c", fifo_wdata);
      end
    end

  else if (printingMethod == 1)
  begin
    always @(posedge clk or negedge rst_n)
      begin
        if (rst_n == 0)
          begin
            str_buf = "";
          end
        else if (fifo_wr)
          begin
            str_buf = $sformatf("%s%c", str_buf, fifo_wdata);
            if (fifo_wdata == "\n")
              begin
                #2 $write("%s", str_buf);
                str_buf = "";
              end
          end
      end
  end
endgenerate

  assign wfifo_used = {WR_WIDTHU{1'b0}};
  assign r_dat = {FIFO_WIDTH{1'b0}};
  assign fifo_FF = 1'b0;
  assign wfifo_empty = 1'b1;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KOSTHiyshA8uxJMF8T8U//41sb1R7Z3fHelntRYjdiZlwSk7t4aHraEavYrayv1wn6fP6shvVdhyZI2wHRwy84bLSWgZNmqJDFydHJpg3VkLWrXoi4akRn4gkeNl5TjcVD/tcxM8ictsVGdlQY5q7UBZHheAGTwQcKg9LqbX4RxpwEbliYCMQc6ULiyw71c8kYiKEc9I0GMjaCbUH/uFMBB4J0fpFXRcnh5NR8y5P5LIJ9ZKho82zMp1eZKEQbEKj827T6umBuAXarvAiyT66SBnlHa9oQl+hfGEMkDAd9SIyZQNVoZk1GbYRM22md7j4jvunBjYRvBXGUYgTJhHUiFcCOFIvUC7E/xcsNzo9l2Pnh2vbbodZeLnHcQ6o5s/exosvWpM5psQslxKpihbAHgm8zFmzSRcTfE4a3dUMxtoGEg1t3NN4RWux/ljWDREGJXvVLtN/khB+dUp4JBewqueoOYLF/Jiah9IVHe0zUEedldGeqxlTQRufdjcemkgB3Epun5nHkDT7vI5PFMlrC3sxl1XzD7migJbpi77h6Gi90eIVY1xe8TfSCrrF4OYCenovMqJKY2D1No4SGaLm22G+Rhkwpkh9YKdPT4q6Zz9+KYuivV/f+zJM2RQw4zeuA0iCFlmk9OxQlmzk2ZKBYNWvZVz6oUG2XhK1eHVyyCr4I/gsWjqmDvued6dklc+X3woTrnx4Kizh7dmQJ/GXpwglvNF2FFmjfxOA65UzbeFRtYrEZIl42R1v+6wNME+KQNsRMELcnzuUu4SIq1Muxv5Xgg7Jf9m3hceTCM1zhhUS7e5A9GdLbh7xno7G7g9SHpLgJ5nyQpDZpDW/tmTLK0XAn34HF9ccQLJACa+CiBofLB8JXuq7Suq2XSr8VvK6W89Q19LVWhaHEr52lN3qGM721jr0+Zlfr8PvoSZK6YJ2mna1UxCZkD+epIdZxGJ9TmHUp+91Etg7YoZ71fMpzNUHeXKweXhKqG+xHkoDK5+3MHZZTLTdklzX8sdid+1"
`endif