// For each bit in an 8-bit vector, detect when the input signal changes from one clock cycle to the next (detect any edge). The output bit should be set the cycle after a 0 to 1 transition occurs.

module top_module (
    input clk,
    input [7:0] in,
    output [7:0] anyedge
);
    reg [7:0] prev_in;

    always @(posedge clk) begin
        prev_in <= in;
        anyedge <= (in & ~prev_in);
    end

endmodule