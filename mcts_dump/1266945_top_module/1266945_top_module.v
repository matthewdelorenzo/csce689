//Design a 16-bit adder.
//There are two 16 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 16 bit value, [15:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module top_module(output [15:0] sum,
                      output cout,
                      input [15:0] in1, in2,
                      input cin);
\n   wire [15:0 sum;\n]    wire [16:0] full_sum;

    // Perform the addition of in1, in2, and cin
    assign full_sum = in1 + in2 + cin;

    // Assign the lower 16 bits to sum
    assign sum = full_sum[15:0];

    // Assign the 17th bit to cout
    assign cout = full_sum[16];

endmodule