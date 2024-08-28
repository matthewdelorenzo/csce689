//Please finish designing the 32 bit multiplier module (multiplier_32) below.
//There are two 32 bit inputs (A and B) and a 64 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_32(output [63:0] product, input [31:0] A, B);

    reg [63:0] product_reg;
    reg [31:0] A_reg, B_reg;

    always @(A, B) begin
        A_reg <= A;
        B_reg <= B;
    end

    always @(A_reg, B_reg) begin
        product_reg <= A_reg * B_reg;
    end

    assign product = product_reg;

endmodule