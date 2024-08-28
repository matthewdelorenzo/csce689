//Design a Verilog module for a MAC (Multiplier and Accumulator) unit.
//The MAC unit takes two inputs, A and B, and multiplies them.
//The result of the multiplication is accumulated with a third register, C.
//The accumulated result is stored in an output register, accumulator.
//The module should have a control input, clk (clock), to synchronize the operations.
//The module should have a control input, reset (reset), to reset the accumulated result.
module mac_32(
    input wire clk,
    input wire reset,
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [63:0] accumulator
);

    reg [31:0] product;
    reg [31:0] accumulator_reg;

    always @(posedge clk) begin
        if (reset) begin
            accumulator_reg <= 32'b0;
        end
        else begin
            product <= A * B;
            accumulator_reg <= accumulator_reg + product;
        end
    end

    assign accumulator = {accumulator_reg, 32'b0};

endmodule