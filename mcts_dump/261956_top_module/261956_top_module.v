// Create a half adder. A half adder adds two bits (with no carry-in) and produces a sum and carry-out.

module top_module( 
    input a, b,
    output cout, sum );
assign sum = a ^ b;  // XOR operation for sum
    assign cout = a & b; // AND operation for carry-out
endmodule