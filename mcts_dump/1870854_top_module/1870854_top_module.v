// Build a decade counter that counts from 0 through 9, inclusive, with a period of 10. The reset input is synchronous, and should reset the counter to 0.

module top_module (
    input clk,
    input reset,        // Synchronous active-high reset
    output [3:0] q);
reg[3:0]count;
always@(posedgeclkorposededgereset)
{
if(reset)
count <= 4'b0000;
else
count <= count + 1'b1;
}

assign q = count[3:0];

endmodule