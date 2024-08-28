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
 
    assign sum_temp[0] = in1[0] ^ in2[0] ^ cin;
    assign sum_temp[1] = in1[1] ^ in2[1] ^ cin;
    assign sum_temp[2] = in1[2] ^ in2[2] ^ cin;
    assign sum_temp[3] = in1[3] ^ in2[3] ^ cin;
    assign sum_temp[4] = in1[4] ^ in2[4] ^ cin;
    assign sum_temp[5] = in1[5] ^ in2[5] ^ cin;
    assign sum_temp[6] = in1[6] ^ in2[6] ^ cin;
    assign sum_temp[7] = in1[7] ^ in2[7] ^ cin;
    assign sum_temp[8] = in1[8] ^ in2[8] ^ cin;
    assign sum_temp[9] = in1[9] ^ in2[9] ^ cin;
    assign sum_temp[10] = in1[10] ^ in2[10] ^ cin;
    assign sum_temp[11] = in1[11] ^ in2[11] ^ cin;
    assign sum_temp[12] = in1[12] ^ in2[12] ^ cin;
    assign sum_temp[13] = in1[13] ^ in2[13] ^ cin;
    assign sum_temp[14] = in1[14] ^ in2[14] ^ cin;
    assign sum_temp[15] = in1[15] ^ in2[15] ^ cin;
    assign sum_temp[16] = in1[16] ^ in2[16] ^ cin;
    assign sum_temp[17] = in1[17] ^ in2[17] ^ cin;
    assign sum_temp[18] = in1[18] ^ in2[18] ^ cin;
    assign sum_temp[19] = in1[19] ^ in2[19] ^ cin;
    assign sum_temp[20] = in1[20] ^ in2[20] ^ cin;
    assign sum_temp[21] = in1[21] ^ in2[21] ^ cin;
    assign sum_temp[22] = in1[22] ^ in2[22] ^ cin;
    assign sum_temp[23] = in1[23] ^ in2[23] ^ cin;
    assign sum_temp[24] = in1[24] ^ in2[24] ^ cin;
    assign sum_temp[25] = in1[25] ^ in2[25] ^ cin;
    assign sum_temp[26] = in1[26] ^ in2[26] ^ cin;
    assign sum_temp[27] = in1[27] ^ in2[27] ^ cin;
    assign sum_temp[28] = in1[28] ^ in2[28] ^ cin;
    assign sum_temp[29] = in1[29] ^ in2[29] ^ cin;
    assign sum_temp[30] = in1[30] ^ in2[30] ^ cin;
    assign sum_temp[31] = in1[31] ^ in2[31] ^ cin;
    assign sum_temp[32] = in1[32] ^ in2[32] ^ cin;
    assign sum_temp[33] = in1[33] ^ in2[33] ^ cin;
    assign sum_temp[34] = in1[34] ^ in2[34] ^ cin;
    assign sum_temp[35] = in1[35] ^ in2[35] ^ cin;
    assign sum_temp[36] = in1[36] ^ in2[36] ^ cin;
    assign sum_temp[37] = in1[37] ^ in2[37] ^ cin;
    assign sum_temp[38] = in1[38] ^ in2[38] ^ cin;
    assign sum_temp[39] = in1[39] ^ in2[39] ^ cin;
    assign sum_temp[40] = in1[40] ^ in2[40] ^ cin;
    assign sum_temp[41] = in1[41] ^ in2[41] ^ cin;
    assign sum_temp[42] = in1[42] ^ in2[42] ^ cin;
    assign sum_temp[43] = in1[43] ^ in2[43] ^ cin;
    assign sum_temp[44] = in1[44] ^ in2[44] ^ cin;
    assign sum_temp[45] = in1[45] ^ in2[45] ^ cin;
    assign sum_temp[46] = in1[46] ^ in2[46] ^ cin;
    assign sum_temp[47] = in1[47] ^ in2[47] ^ cin;
    assign sum_temp[48] = in1[48] ^ in2[48] ^ cin;
    assign sum_temp[49] = in1[49] ^ in2[49] ^ cin;
    assign sum_temp[50] = in1[50] ^ in2[50] ^ cin;
    assign sum_temp[51] = in1[51] ^ in2[51] ^ cin;
    assign sum_temp[52] = in1[52] ^ in2[52] ^ cin;
    assign sum_temp[53] = in1[53] ^ in2[53] ^ cin;
    assign sum_temp[54] = in1[54] ^ in2[54] ^ cin;
    assign sum_temp[55] = in1[55] ^ in2[55] ^ cin;
    assign sum_temp[56] = in1[56] ^ in2[56] ^ cin;
    assign sum_temp[57] = in1[57] ^ in2[57] ^ cin;
    assign sum_temp[58] = in1[58] ^ in2[58] ^ cin;
    assign sum_temp[59] = in1[59] ^ in2[59] ^ cin;
    assign sum_temp[60] = in1[60] ^ in2[60] ^ cin;
    assign sum_temp[61] = in1[61] ^ in2[61] ^ cin;
    assign sum_temp[62] = in1[62] ^ in2[62] ^ cin;
    assign sum_temp[63] = in1[63] ^ in2[63] ^ cin;
 
    assign cout_temp = (in1[63] & in2[63]) | (in1[63] & cin) | (in2[63] & cin);
 
    assign sum = sum_temp;
    assign cout = cout_temp;
 
endmodule