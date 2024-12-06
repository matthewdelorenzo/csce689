// Build a decade counter that counts from 0 through 9, inclusive, with a period of 10. The reset input is synchronous, and should reset the counter to 0.

module top_module (
    input clk,
    input reset,        // Synchronous active-high reset
    output [3:0] q);
   //assign q =4'b0000;   
   
    always @(posedge clk) begin
        if (reset) begin
            q <= 4'b0000;
        end
        else if (q == 4'b1001) begin
            q <= 4'b0000;
        end
        else begin
            q <= q + 1;
        end
    end
endmodule