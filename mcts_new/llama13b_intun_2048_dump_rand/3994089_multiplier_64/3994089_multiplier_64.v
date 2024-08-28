//Please finish designing the 64 bit multiplier module (multiplier_64) below.
//There are two 64 bit inputs (A and B) and a 128 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_64(output [127:0] product, input [63:0] A, B);

    wire [127:0] product_wire;

    assign product_wire = A * B;

    assign product = product_wire;

endmodule