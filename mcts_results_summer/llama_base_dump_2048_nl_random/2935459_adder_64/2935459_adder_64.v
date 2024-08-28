//Design a 64-bit adder.
//There are two 64 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 64 bit value, [63:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_64(output [63:0] sum,
                      output cout,
                      input [63:0] in1, in2,
                      input cin);

wire [63:0] sum_temp;
wire cout_temp;

adder_32 adder_32_1(sum[31:0], cout_temp, in1[31:0], in2[31:0], cin);
adder_32 adder_32_2(sum_temp[31:0], cout, in1[31:0], in2[31:0], cout_temp);
adder_32 adder_32_3(sum[63:32], cout, in1[63:32], in2[63:32], cout);

endmodule

//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin);

wire [31:0] sum_temp;
wire cout_temp;

adder_16 adder_16_1(sum[15:0], cout_temp, in1[15:0], in2[15:0], cin);
adder_16 adder_16_2(sum_temp[15:0], cout, in1[15:0], in2[15:0], cout_temp);
adder_16 adder_16_3(sum[31:16], cout, in1[31:16], in2[31:16], cout);

endmodule

//Design a 16-bit adder.
//There are two 16 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 16 bit value, [15:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_16(output [15:0] sum,
                      output cout,
                      input [15:0] in1, in2,
                      input cin);

wire [15:0] sum_temp;
wire cout_temp;

adder_8 adder_8_1(sum[7:0], cout_temp, in1[7:0], in2[7:0], cin);
adder_8 adder_8_2(sum_temp[7:0], cout, in1[7:0], in2[7:0], cout_temp);
adder_8 adder_8_3(sum[15:8], cout, in1[15:8], in2[15:8], cout);

endmodule

//Design an 8-bit adder.
//There are two 8 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 8 bit value, [7:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_8(output [7:0] sum,
                     output cout,
                     input [7:0] in1, in2,
                     input cin);

wire [7:0] sum_temp;
wire cout_temp;

adder_4 adder_4_1(sum[3:0], cout_temp, in1[3:0], in2[3:0], cin);
adder_4 adder_4_2(sum_temp[3:0], cout, in1[3:0], in2[3:0], cout_temp);
adder_4 adder_4_3(sum[7:4], cout, in1[7:4], in2[7:4], cout);

endmodule

//Design a 4-bit adder.
//There are two 4 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 4 bit value, [3:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_4(output [3:0] sum,
                     output cout,
                     input [3:0] in1, in2,
                     input cin);

wire [3:0] sum_temp;
wire cout_temp;

adder_2 adder_2_1(sum[1:0], cout_temp, in1[1:0], in2[1:0], cin);
adder_2 adder_2_2(sum_temp[1:0], cout, in1[1:0], in2[1:0], cout_temp);
adder_2 adder_2_3(sum[3:2], cout, in1[3:2], in2[3:2], cout);

endmodule

//Design a 2-bit adder.
//There are two 2 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 2 bit value, [1:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_2(output [1:0] sum,
                     output cout,
                     input [1:0] in1, in2,
                     input cin);

wire [1:0] sum_temp;
wire cout_temp;

adder_1 adder_1_1(sum[0], cout_temp, in1[0], in2[0], cin);
adder_1 adder_1_2(sum_temp[0], cout, in1[0], in2[0], cout_temp);
adder_1 adder_1_3(sum[1], cout, in1[1], in2[1], cout);

endmodule

//Design a 1-bit adder.
//There are two 1 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 1 bit value, [0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_1(output [0:0] sum,
                     output cout,
                     input [0:0] in1, in2,
                     input cin);

wire [0:0] sum_temp;
wire cout_temp;

assign sum_temp[0] = in1[0] ^ in2[0] ^ cin;
assign cout_temp = (in1[0] & in2[0]) | (in1[0] & cin) | (in2[0] & cin);
assign sum[0] = sum_temp[0];
assign cout = cout_temp;

endmodule