// Build a decade counter that counts from 0 through 9, inclusive, with a period of 10. The reset input is synchronous, and should reset the counter to 0.

module top_module (
    input clk,
    input reset,        // Synchronous active-high reset
    output [3:0] q);
        
    always @ (posedge clk)
        begin
            if(reset)
                q <= 4'd0;
            else
                begin
                    q[3] <= q[2];
                    q[2] <= q[1];
                    q[1] <= q[0];
                    q[0] <= 1'b0;
                end
        end

endmodule