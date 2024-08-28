//Design a 64-bit adder.
//There are two 64 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 64 bit value, [63:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_64(output [63:0] sum,
                      output cout,
                      input [63:0] in1, in2,
                      input cin); 
 
  wire [63:0] sum_wire;
  wire cout_wire;
 
  assign sum = sum_wire;
  assign cout = cout_wire;
 
  full_adder fa0(sum_wire[0], cout_wire, in1[0], in2[0], cin);
  full_adder fa1(sum_wire[1], cout_wire, in1[1], in2[1], cout_wire);
  full_adder fa2(sum_wire[2], cout_wire, in1[2], in2[2], cout_wire);
  full_adder fa3(sum_wire[3], cout_wire, in1[3], in2[3], cout_wire);
  full_adder fa4(sum_wire[4], cout_wire, in1[4], in2[4], cout_wire);
  full_adder fa5(sum_wire[5], cout_wire, in1[5], in2[5], cout_wire);
  full_adder fa6(sum_wire[6], cout_wire, in1[6], in2[6], cout_wire);
  full_adder fa7(sum_wire[7], cout_wire, in1[7], in2[7], cout_wire);
  full_adder fa8(sum_wire[8], cout_wire, in1[8], in2[8], cout_wire);
  full_adder fa9(sum_wire[9], cout_wire, in1[9], in2[9], cout_wire);
  full_adder fa10(sum_wire[10], cout_wire, in1[10], in2[10], cout_wire);
  full_adder fa11(sum_wire[11], cout_wire, in1[11], in2[11], cout_wire);
  full_adder fa12(sum_wire[12], cout_wire, in1[12], in2[12], cout_wire);
  full_adder fa13(sum_wire[13], cout_wire, in1[13], in2[13], cout_wire);
  full_adder fa14(sum_wire[14], cout_wire, in1[14], in2[14], cout_wire);
  full_adder fa15(sum_wire[15], cout_wire, in1[15], in2[15], cout_wire);
  full_adder fa16(sum_wire[16], cout_wire, in1[16], in2[16], cout_wire);
  full_adder fa17(sum_wire[17], cout_wire, in1[17], in2[17], cout_wire);
  full_adder fa18(sum_wire[18], cout_wire, in1[18], in2[18], cout_wire);
  full_adder fa19(sum_wire[19], cout_wire, in1[19], in2[19], cout_wire);
  full_adder fa20(sum_wire[20], cout_wire, in1[20], in2[20], cout_wire);
  full_adder fa21(sum_wire[21], cout_wire, in1[21], in2[21], cout_wire);
  full_adder fa22(sum_wire[22], cout_wire, in1[22], in2[22], cout_wire);
  full_adder fa23(sum_wire[23], cout_wire, in1[23], in2[23], cout_wire);
  full_adder fa24(sum_wire[24], cout_wire, in1[24], in2[24], cout_wire);
  full_adder fa25(sum_wire[25], cout_wire, in1[25], in2[25], cout_wire);
  full_adder fa26(sum_wire[26], cout_wire, in1[26], in2[26], cout_wire);
  full_adder fa27(sum_wire[27], cout_wire, in1[27], in2[27], cout_wire);
  full_adder fa28(sum_wire[28], cout_wire, in1[28], in2[28], cout_wire);
  full_adder fa29(sum_wire[29], cout_wire, in1[29], in2[29], cout_wire);
  full_adder fa30(sum_wire[30], cout_wire, in1[30], in2[30], cout_wire);
  full_adder fa31(sum_wire[31], cout_wire, in1[31], in2[31], cout_wire);
  full_adder fa32(sum_wire[32], cout_wire, in1[32], in2[32], cout_wire);
  full_adder fa33(sum_wire[33], cout_wire, in1[33], in2[33], cout_wire);
  full_adder fa34(sum_wire[34], cout_wire, in1[34], in2[34], cout_wire);
  full_adder fa35(sum_wire[35], cout_wire, in1[35], in2[35], cout_wire);
  full_adder fa36(sum_wire[36], cout_wire, in1[36], in2[36], cout_wire);
  full_adder fa37(sum_wire[37], cout_wire, in1[37], in2[37], cout_wire);
  full_adder fa38(sum_wire[38], cout_wire, in1[38], in2[38], cout_wire);
  full_adder fa39(sum_wire[39], cout_wire, in1[39], in2[39], cout_wire);
  full_adder fa40(sum_wire[40], cout_wire, in1[40], in2[40], cout_wire);
  full_adder fa41(sum_wire[41], cout_wire, in1[41], in2[41], cout_wire);
  full_adder fa42(sum_wire[42], cout_wire, in1[42], in2[42], cout_wire);
  full_adder fa43(sum_wire[43], cout_wire, in1[43], in2[43], cout_wire);
  full_adder fa44(sum_wire[44], cout_wire, in1[44], in2[44], cout_wire);
  full_adder fa45(sum_wire[45], cout_wire, in1[45], in2[45], cout_wire);
  full_adder fa46(sum_wire[46], cout_wire, in1[46], in2[46], cout_wire);
  full_adder fa47(sum_wire[47], cout_wire, in1[47], in2[47], cout_wire);
  full_adder fa48(sum_wire[48], cout_wire, in1[48], in2[48], cout_wire);
  full_adder fa49(sum_wire[49], cout_wire, in1[49], in2[49], cout_wire);
  full_adder fa50(sum_wire[50], cout_wire, in1[50], in2[50], cout_wire);
  full_adder fa51(sum_wire[51], cout_wire, in1[51], in2[51], cout_wire);
  full_adder fa52(sum_wire[52], cout_wire, in1[52], in2[52], cout_wire);
  full_adder fa53(sum_wire[53], cout_wire, in1[53], in2[53], cout_wire);
  full_adder fa54(sum_wire[54], cout_wire, in1[54], in2[54], cout_wire);
  full_adder fa55(sum