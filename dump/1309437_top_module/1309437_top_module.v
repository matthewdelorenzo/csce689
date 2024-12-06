// Create a half adder. A half adder adds two bits (with no carry-in) and produces a sum and carry-out.

module top_module( 
    input a, b,
    output cout, sum );

    // XOR gate for sum
    assign sum = a ^ b;
    
    // AND gate for carry-out
    assign cout = a & b;

endmodule