// Build a decade counter that counts from 0 through 9, inclusive, with a period of 10. The reset input is synchronous, and should reset the counter to 0.

module top_module (
    input clk,
    input reset,        // Synchronous active-high reset
    output [3:0] q);

    always @(posedge clk) begin
        if (reset) begin
            q <= 4'b0000; // Reset counter to 0
        end
        else if (q == 4'b1001) begin
            q <= 4'b0000; // Reset counter to 0 after 9
        end
        else begin
            q <= q + 1; // Increment counter
        end
    end
endmodule