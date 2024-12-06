//Design a Verilog module for a MAC (Multiplier and Accumulator) unit.
//The MAC unit takes two inputs, A and B, and multiplies them.
//The result of the multiplication is accumulated with a third register, C.
//The accumulated result is stored in an output register, accumulator.
//The module should have a control input, clk (clock), to synchronize the operations.
//The module should have a control input, reset (reset), to reset the accumulated result.
module top_module(
    input wire clk,
    input wire reset,
    input wire [15:0] A,
    input wire [15:0] B,
    output reg [31:0] accumulator
);

reg [31:0] C; // Register to store the accumulated result

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            C <= 32'b0; // Reset the accumulated result to 0
        end else begin
            C <= C + (A * B); // Multiply A and B, then add the result to C
        end
    end

    always @* begin
        accumulator = C; // Update the output with the current accumulated value
    end

endmodule