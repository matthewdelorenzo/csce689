//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin);
  wire c1, c2, c3;
  full_adder FA1(sum[0], c1, in1[0], in2[0], cin);
  full_adder FA2(sum[1], c2, in1[1], in2[1], c1);
  full_adder FA3(sum[2], c3, in1[2], in2[2], c2);
  full_adder FA4(sum[3], cout, in1[3], in2[3], c3);
  full_adder FA5(sum[4], c3, in1[4], in2[4], c3);
  full_adder FA6(sum[5], c3, in1[5], in2[5], c3);
  full_adder FA7(sum[6], c3, in1[6], in2[6], c3);
  full_adder FA8(sum[7], c3, in1[7], in2[7], c3);
  full_adder FA9(sum[8], c3, in1[8], in2[8], c3);
  full_adder FA10(sum[9], c3, in1[9], in2[9], c3);
  full_adder FA11(sum[10], c3, in1[10], in2[10], c3);
  full_adder FA12(sum[11], c3, in1[11], in2[11], c3);
  full_adder FA13(sum[12], c3, in1[12], in2[12], c3);
  full_adder FA14(sum[13], c3, in1[13], in2[13], c3);
  full_adder FA15(sum[14], c3, in1[14], in2[14], c3);
  full_adder FA16(sum[15], c3, in1[15], in2[15], c3);
  full_adder FA17(sum[16], c3, in1[16], in2[16], c3);
  full_adder FA18(sum[17], c3, in1[17], in2[17], c3);
  full_adder FA19(sum[18], c3, in1[18], in2[18], c3);
  full_adder FA20(sum[19], c3, in1[19], in2[19], c3);
  full_adder FA21(sum[20], c3, in1[20], in2[20], c3);
  full_adder FA22(sum[21], c3, in1[21], in2[21], c3);
  full_adder FA23(sum[22], c3, in1[22], in2[22], c3);
  full_adder FA24(sum[23], c3, in1[23], in2[23], c3);
  full_adder FA25(sum[24], c3, in1[24], in2[24], c3);
  full_adder FA26(sum[25], c3, in1[25], in2[25], c3);
  full_adder FA27(sum[26], c3, in1[26], in2[26], c3);
  full_adder FA28(sum[27], c3, in1[27], in2[27], c3);
  full_adder FA29(sum[28], c3, in1[28], in2[28], c3);
  full_adder FA30(sum[29], c3, in1[29], in2[29], c3);
  full_adder FA31(sum[30], c3, in1[30], in2[30], c3);
  full_adder FA32(sum[31], cout, in1[31], in2[31], c3);
endmodule