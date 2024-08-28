//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin);

  wire [31:0] sum_internal;
  wire cout_internal;

  assign sum = sum_internal;
  assign cout = cout_internal;

  adder_16 adder_16_0(sum_internal[15:0], cout_internal, in1[15:0], in2[15:0], cin);
  adder_16 adder_16_1(sum_internal[31:16], cout_internal, in1[31:16], in2[31:16], cout_internal);

endmodule

//Design a 16-bit adder.
//There are two 16 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 16 bit value, [15:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_16(output [15:0] sum,
                      output cout,
                      input [15:0] in1, in2,
                      input cin);

  wire [15:0] sum_internal;
  wire cout_internal;

  assign sum = sum_internal;
  assign cout = cout_internal;

  adder_8 adder_8_0(sum_internal[7:0], cout_internal, in1[7:0], in2[7:0], cin);
  adder_8 adder_8_1(sum_internal[15:8], cout_internal, in1[15:8], in2[15:8], cout_internal);

endmodule

//Design an 8-bit adder.
//There are two 8 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 8 bit value, [7:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_8(output [7:0] sum,
                     output cout,
                     input [7:0] in1, in2,
                     input cin);

  wire [7:0] sum_internal;
  wire cout_internal;

  assign sum = sum_internal;
  assign cout = cout_internal;

  adder_4 adder_4_0(sum_internal[3:0], cout_internal, in1[3:0], in2[3:0], cin);
  adder_4 adder_4_1(sum_internal[7:4], cout_internal, in1[7:4], in2[7:4], cout_internal);

endmodule

//Design a 4-bit adder.
//There are two 4 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 4 bit value, [3:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_4(output [3:0] sum,
                     output cout,
                     input [3:0] in1, in2,
                     input cin);

  wire [3:0] sum_internal;
  wire cout_internal;

  assign sum = sum_internal;
  assign cout = cout_internal;

  adder_2 adder_2_0(sum_internal[1:0], cout_internal, in1[1:0], in2[1:0], cin);
  adder_2 adder_2_1(sum_internal[3:2], cout_internal, in1[3:2], in2[3:2], cout_internal);

endmodule

//Design a 2-bit adder.
//There are two 2 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 2 bit value, [1:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_2(output [1:0] sum,
                     output cout,
                     input [1:0] in1, in2,
                     input cin);

  wire [1:0] sum_internal;
  wire cout_internal;

  assign sum = sum_internal;
  assign cout = cout_internal;

  assign sum_internal = in1 ^ in2 ^ cin;
  assign cout_internal = (in1 & in2) | (in1 & cin) | (in2 & cin);

endmodule