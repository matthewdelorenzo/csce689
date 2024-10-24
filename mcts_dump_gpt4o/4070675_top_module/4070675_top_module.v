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
``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````verilog
    wire [100:0] carry; // Intermediate carry signals

    assign carry[0] = cin; // Initial carry-in

    genvar i;
    generate
        for (i = 0; i < 100; i = i + 1) begin: bcd_adder
            bcd_fadd adder (
                .a(a[i*4 +: 4]),
                .b(b[i*4 +: 4]),
                .cin(carry[i]),
                .cout(carry[i+1]),
                .sum(sum[i*4 +: 4])
            );
        end
    endgenerate

    assign cout = carry[100]; // Final carry-out

endmodule