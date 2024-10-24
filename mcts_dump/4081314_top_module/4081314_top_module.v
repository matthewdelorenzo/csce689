// Create a half adder. A half adder adds two bits (with no carry-in) and produces a sum and carry-out.

module top_module( 
    input a, b,
    output cout, sum );
verilog
    assign sum = a ^ b;  // XOR operation for the sum
    assign cout = a & b; // AND operation for the carry-out
endmodule