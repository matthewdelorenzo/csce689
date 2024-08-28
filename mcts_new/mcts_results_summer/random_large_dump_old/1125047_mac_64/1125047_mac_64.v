//Design a Verilog module for a MAC (Multiplier and Accumulator) unit.
//The MAC unit takes two inputs, A and B, and multiplies them.
//The result of the multiplication is accumulated with a third register, C.
//The accumulated result is stored in an output register, accumulator.
//The module should have a control input, clk (clock), to synchronize the operations.
//The module should have a control input, reset (reset), to reset the accumulated result.
module mac_64(
    input wire clk,
    input wire reset,
    input wire [63:0] A,
    input wire [63:0] B,
    output reg [127:0] accumulator
);

reg [63:0] A_reg;
reg [63:0] B_reg;
reg [127:0] accumulator_reg;

always @(posedge clk) begin
    if (reset) begin
        accumulator <= 0;
        accumulator_reg <= 0;
    end
    else begin
        A_reg <= A;
        B_reg <= B;
        accumulator_reg <= A_reg * B_reg;
        accumulator <= accumulator_reg;
    end
end

endmodule