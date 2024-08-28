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
 
reg [127:0] temp ;
reg [63:0] C ;

always @(posedge clk )
begin
    if (reset)
        accumulator <= 0;
    else
        accumulator <= temp;
end

always @(posedge clk)
begin
    if (reset)
        C <= 0;
    else
        C <= A * B;
end

always @(posedge clk)
begin
    if (reset)
        temp <= 0;
    else
        temp <= C + accumulator;
end

endmodule