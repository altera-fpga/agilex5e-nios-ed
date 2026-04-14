// (C) 2001-2026 Altera Corporation. All rights reserved.
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

 
 module pb_debounce(
    input wire clk_clk,
    input wire [3:0] pb_in,
    output reg [3:0] pb_out
);
    parameter M = 20;
    reg [M:0] shift [3:0];  // shift registers, each M+1 bits wide
    integer i;

    always @(posedge clk_clk) begin
        // Shift register captures input, shifting left by 1
        for (i = 0; i < 4; i = i + 1) begin
            shift[i] <= {shift[i][M-1:0], pb_in[i]};
        end

        // Debounce output logic
        for (i = 0; i < 4; i = i + 1) begin
            if (~|shift[i])
                pb_out[i] <= 1'b0;
            else if (&shift[i])
                pb_out[i] <= 1'b1;
            else
                pb_out[i] <= pb_out[i];
        end
    end
endmodule