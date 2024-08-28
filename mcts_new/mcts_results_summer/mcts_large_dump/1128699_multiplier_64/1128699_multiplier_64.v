//Please finish designing the 64 bit multiplier module (multiplier_64) below.
//There are two 64 bit inputs (A and B) and a 128 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_64(output [127:0] product, input [63:0] A, B);
    /*
        Implement a 64 bit multiplier with a 128 bit output.
        The output should be the same as the input (A) and (B) multiplied together.
        This implementation uses a 64 bit by 64 bit multiply and a 128 bit adder.
    */
    
    //Declare intermediate products
    wire [63:0] product1, product2, product3;
    
    //Multiply the inputs
    assign product1 = A * B;
    
    //Add the intermediate products
    assign product2 = product1[63:0] + product[95:64];
    assign product3 = product1[127:64] + product2[127:64];
    
    //Assign the final product
    assign product[127:64] = product3[127:64];
    assign product[63:0] = product2[63:0];
    
endmodule