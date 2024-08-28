// Build a decade counter that counts from 0 through 9, inclusive, with a period of 10. The reset input is synchronous, and should reset the counter to 0.

module top_module (
    input clk,
    input reset,        // Synchronous active-high reset
    output [3:0] q);

    always @(posedge clk) begin
        if(reset)
            q <= 4'd0;
        else begin
            q <= q + 4'd1;
            if(q == 9)
                q <= 4'd0;
        end
    end
endmodule