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

wire [3:0] sum0, sum1, sum2, sum3;
    wire cout0, cout1, cout2;

    // Instantiate 4 BCD full adders
    bcd_fadd adder0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(cin),
        .cout(cout0),
        .sum(sum0)
    );

    bcd_fadd adder1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(cout0),
        .cout(cout1),
        .sum(sum1)
    );

    bcd_fadd adder2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(cout1),
        .cout(cout2),
        .sum(sum2)
    );

    bcd_fadd adder3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(cout2),
        .cout(cout),
        .sum(sum3)
    );

    // Concatenate the sums to form the 16-bit output sum
    assign sum = {sum3, sum2, sum1, sum0};

endmodule