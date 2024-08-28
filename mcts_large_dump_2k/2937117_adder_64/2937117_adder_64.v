<s> //Design a 64-bit adder.
//There are two 64 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 64 bit value, [63:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_64(output [63:0] sum,
                      output cout,
                      input [63:0] in1, in2,
                      input cin);

    wire [63:0] sum_temp;
    wire cout_temp;

    adder_32 adder_32_1(sum_temp[31:0], cout_temp, in1[31:0], in2[31:0], cin);
    adder_32 adder_32_2(sum_temp[63:32], cout, in1[63:32], in2[63:32], cout_temp);

endmodule