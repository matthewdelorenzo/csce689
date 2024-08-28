//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin);
  //internal variables
  wire [31:0] sum_temp;
  wire [31:0] carry_in;
  wire [32:0] carry;
  assign carry[0] = cin;
  assign carry_in[0] = cin;
  assign carry[32:1] = {carry_in[31:0], 1'b0};
  assign sum_temp[0] = in1[0] ^ in2[0] ^ carry_in[0];
  assign sum_temp[31:1] = in1[30:0] ^ in2[30:0] ^ carry[31:1];
  assign sum[0] = sum_temp[0];
  assign sum[31:1] = sum_temp[31:1];
  assign cout = carry[32];
endmodule