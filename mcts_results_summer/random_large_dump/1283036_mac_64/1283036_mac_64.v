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

reg [31:0] acc_r=0;
reg [31:0] temp=0;

always@(posedge clk) begin
    if(reset) begin
        accumulator <= 0;
        acc_r <= 0;
    end
    else begin
        acc_r <= acc_r+B;
        temp <= A*acc_r;
        accumulator <= temp + accumulator;
    end
end

endmodule