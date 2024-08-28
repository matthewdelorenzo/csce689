//Please finish designing the 64 bit multiplier module (multiplier_64) below.
//There are two 64 bit inputs (A and B) and a 128 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_64(output [127:0] product, input [63:0] A, B);
    /* Please fill in the implementation here... */
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: mul_digit
            assign product[(8 * i) + 7:8 * i] = mul_digit[i].A * mul_digit[i].B;
        end
    endgenerate
endmodule