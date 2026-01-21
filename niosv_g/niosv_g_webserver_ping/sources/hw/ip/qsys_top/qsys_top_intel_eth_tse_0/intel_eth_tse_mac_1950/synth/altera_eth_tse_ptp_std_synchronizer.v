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


`timescale 1ns / 1ns

module altera_eth_tse_ptp_std_synchronizer #(
    parameter width = 1,
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   [width-1:0] din,
    output  [width-1:0] dout
);

genvar i;
generate
for (i = 0; i < width; i = i + 1) begin: nocut_sync    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_nocut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din[i]),
        .dout       (dout[i])
    );
end    
endgenerate
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "tTnsR2Y5Sym1r4K4WdcY1XWPCcsViFKfuEmlRdTbi5jTZZcM5g8KRrryQ6B/AcJKw7WbqN6HFXFkpVW14vwHO4LHnQRmAL01nQot12rHoNE9kJfzL6JHt13qKd7bt06ErFACnpJTwpMLCAyOn+gS5DeMiy5u/otEggP8SzMzY6MWv/4a+Bg49LiE3xr7S9IdudYnA7hVcfZFj9BD1CzD75g9ikkjlSNJcyB8spHTarT0vLkCjFd0AI9AGDDJyZW4RMOi+PgvCTQQ/sR+GKCpasjXOdyJnHvOoDjFmusoJ1S7/YCWBGsqSoPf71N5RF/evJutdbfcYMZfw2ndFn7kXsAvi5qCv+vm1nhDTYRcRZ7ZB5kI5SAhpeuX0W7p8BrDKwcFnWUN47Pq21J4x0K/XRTD6b2bqoZCC1FADQEWhQCHTuL14JgU9LGz/yXuc0uG4XGCle6Gk36DtU9obL/xDBa6dmMWfQmoho40YVLk+e7WyIH6BIDd+x/gSKB+U9w5QmX3Hq3XyA43A3vg2kbjs8R/oY0W/u9O6OA7aCCiPPmPVWoAWY2FskMogAiqSGJgU50aihy0xGr8Q8n33lhAnjHJBzPSjP3VR19iFitS/MRIfkXO0ilwhw8hQVjD1k7pSQ1NVnVrgw187F8f42r++qXlVsf2uLVPum85X+Qm6fvFVEglkVRxardmX8TMqyva8yvKyWOEAgVueJF1bKj1iFLl8hmplDuMo3x7oNeY1WIzVlx9vvp9cUoloTGhBVEmGeGVDxcuC+dB0q7F3DmXyqgbf/dLM7cvWjxHNHOe30zkuLONWinboChQBW6zsiDrDNurMU8yswFs7itYoLgFJ/2Wgj7rFW3jwp73C3VLzLlKf2cuBAdt0wIwsemMjnKF4e712maoPsI5VwMyxM9nYno2bB23w8vAQYRvAXDX85wSxHEQEMTYJzwGpjDqUlCX0DoPAbJcGhtlrk2lVTEhfMUnky9g8CGZrzVk7cBF4HyAqw0Ngmm39OdbvvgmFqp2"
`endif