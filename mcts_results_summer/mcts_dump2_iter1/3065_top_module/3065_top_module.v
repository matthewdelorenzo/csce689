// You are provided with a BCD (binary-coded decimal) one-digit adder named bcd_fadd that adds two BCD digits and carry-in, and produces a sum and carry-out.

module bcd_fadd (
    input [3:0] a,
    input [3:0] b,
    input     cin,
    output   cout,
    output [3:0] sum );
    
// Instantiate 4 copies of bcd_fadd to create a 4-digit BCD ripple-carry adder. Your adder should add two 4-digit BCD numbers (packed into 16-bit vectors) and a carry-in to produce a 4-digit sum and carry out.

// Hint: The BCD representation for the 5-digit decimal number 12345 is 20'h12345. This is not the same as 14'd12345 (which is 14'h3039).
// The circuit is structured just like a binary ripple-carry adder, except the adders are base-10 rather than base-2.


module top_module ( 
    input [15:0] a, b,
    input cin,
    output cout,
    output [15:0] sum );
    
    bcd_fadd f1 (a[3:0], b[3:0], cin, c1, s1[3:0]);
    bcd_fadd f2 (a[7:4], b[7:4], c1, c2, s2[3:0]);
    bcd_fadd f3 (a[11:8], b[11:8], c2, c3, s3[3:0]);
    bcd_fadd f4 (a[15:12], b[15:12], c3, cout, sum[15:12]);
    
endmodule