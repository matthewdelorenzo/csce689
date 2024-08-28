//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin);  
  wire c1, c2, c3;
  wire [31:0] s1, s2;
  wire [31:0] sum;
  wire cout;
  assign {cout, sum} = in1 + in2 + cin;
endmodule