module pb_debounce(
    input wire clk,
    input wire [3:0]pb_in,
    output reg [3:0]pb_out
);
 parameter M = 8;
 reg [M:0]shift;
 //shift: wait for stable input
 always @ (posedge clk) 
 begin
 // shift register to capture input
   shift <= {shift[4:0],pb_in};
   if(~|shift)
     pb_out <= 1'b0;
   else if(&shift)
	  pb_out <= 1'b1;
   else pb_out <= pb_out;
 end
 endmodule