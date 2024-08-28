//Design a 64-bit adder.
//There are two 64 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 64 bit value, [63:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_64(output [63:0] sum,
                      output cout,
                      input [63:0] in1, in2,
                      input cin);
  //internal variables
  wire [63:0] sum_temp;
  wire [63:0] in1_shifted;
  wire [63:0] in2_shifted;
  wire [63:0] sum_shifted;
  wire [63:0] temp_sum;
  wire [63:0] add_temp;
  wire [63:0] add_sum;
  wire [63:0] sub_temp;
  wire [63:0] sub_sum;
  wire [63:0] not_in2;
  wire [63:0] or_temp;
  wire [63:0] and_temp;
  wire [63:0] and_sum;
  wire [63:0] temp_and;
  wire [63:0] temp_or;
  wire [63:0] temp_not;
  wire [63:0] temp_xor;
  wire [63:0] temp_nor;
  wire [63:0] temp_nand;
  wire [63:0] not_in1;
  wire [63:0] xor_temp;
  wire [63:0] xor_sum;
  wire [63:0] nor_temp;
  wire [63:0] nor_sum;
  wire [63:0] nand_temp;
  wire [63:0] nand_sum;
  wire [63:0] add_or;
  wire [63:0] add_or_sum;
  wire [63:0] add_and;
  wire [63:0] add_and_sum;
  wire [63:0] sub_or;
  wire [63:0] sub_or_sum;
  wire [63:0] sub_and;
  wire [63:0] sub_and_sum;
  wire [63:0] temp_add;
  wire [63:0] temp_sub;
  wire [63:0] not_in2_temp;
  wire [63:0] not_in1_temp;
  wire [63:0] xor_temp_temp;
  wire [63:0] xor_temp_sum;
  wire [63:0] nor_temp_temp;
  wire [63:0] nor_temp_sum;
  wire [63:0] nand_temp_temp;
  wire [63:0] nand_temp_sum;
  wire [63:0] or_temp_temp;
  wire [63:0] and_temp_temp;
  wire [63:0] and_temp_sum;
  wire [63:0] temp_and_temp;
  wire [63:0] temp_or_temp;
  wire [63:0] temp_xor_temp;
  wire [63:0] temp_nor_temp;
  wire [63:0] temp_nand_temp;
  wire [63:0] not_in2_temp_temp;
  wire [63:0] not_in1_temp_temp;
  wire [63:0] xor_temp_temp_temp;
  wire [63:0] xor_temp_temp_sum;
  wire [63:0] nor_temp_temp_temp;
  wire [63:0] nor_temp_temp_sum;
  wire [63:0] nand_temp_temp_temp;
  wire [63:0] nand_temp_temp_sum;
  wire [63:0] or_temp_temp_temp;
  wire [63:0] and_temp_temp_temp;
  wire [63:0] and_temp_temp_sum;
  wire [63:0] add_temp_sum;
  wire [63:0] sub_temp_sum;
  wire [63:0] not_in2_temp_sum;
  wire [63:0] not_in1_temp_sum;
  wire [63:0] xor_temp_temp_sum;
  wire [63:0] nor_temp_temp_sum;
  wire [63:0] nand_temp_temp_sum;
  wire [63:0] or_temp_temp_sum;
  wire [63:0] and_temp_temp_sum;
  wire [63:0]