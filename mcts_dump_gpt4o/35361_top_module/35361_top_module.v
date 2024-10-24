// You are provided with a BCD one-digit adder named bcd_fadd that adds 
// two BCD digits and carry-in, and produces a sum and carry-out.

module bcd_fadd (
    input [3:0] a,
    input [3:0] b,
    input     cin,
    output   cout,
    output [3:0] sum );
    
// Instantiate 100 copies of bcd_fadd to create a 100-digit BCD ripple-carry adder. 
//Your adder should add two 100-digit BCD numbers (packed into 400-bit vectors) 
//and a carry-in to produce a 100-digit sum and carry out.


// Hint: An instance array or generate statement would be useful here.

module top_module( 
    input [399:0] a, b,
    input cin,
    output cout,
    output [399:0] sum );
`````````````````````````````````````````````````````````````````````````````````````````````wire [99:0] carry; // Internal carry signals between each BCD adder

    genvar i;
    generate
        for (i = 0; i < 100; i = i + 1) begin: bcd_adder_chain
            if (i == 0) begin
                // First BCD adder, uses the input carry-in
                bcd_fadd u_bcd_fadd (
                    .a(a[3:0]),
                    .b(b[3:0]),
                    .cin(cin),
                    .cout(carry[i]),
                    .sum(sum[3:0])
                );
            end else begin
                // Subsequent BCD adders, use carry from previous stage
                bcd_fadd u_bcd_fadd (
                    .a(a[i*4 +: 4]),
                    .b(b[i*4 +: 4]),
                    .cin(carry[i-1]),
                    .cout(carry[i]),
                    .sum(sum[i*4 +: 4])
                );
            end
        end
    endgenerate

    // The final carry-out is the carry from the last BCD adder
    assign cout = carry[99];

endmodule