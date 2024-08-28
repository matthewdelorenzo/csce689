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

    wire [99:0] carry;
    bcd_fadd fadd_0 (a[3:0], b[3:0], cin, carry[0], sum[3:0]);
    generate
        genvar i;
        for (i = 4; i < 400; i = i + 4) begin : adder
            bcd_fadd fadd_temp(a[i+3:i], b[i+3:i], carry[i-4], carry[i], sum[i+3:i]);
        end
    endgenerate
    assign cout = carry[99];

endmodule