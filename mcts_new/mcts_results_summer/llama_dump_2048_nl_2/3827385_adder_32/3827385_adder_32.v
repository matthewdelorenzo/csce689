//Design a 32-bit adder.
//There are two 32 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 32 bit value, [31:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module adder_32(output [31:0] sum,
                      output cout,
                      input [31:0] in1, in2,
                      input cin); 

  wire [31:0] temp_sum;
  wire temp_cout;

  //The first adder
  adder_16 adder_16_1(temp_sum[15:0], temp_cout, in1[15:0], in2[15:0], cin);

  //The second adder
  adder_16 adder_16_2(temp_sum[31:16], cout, in1[31:16], in2[31:16], temp_cout);

  //Assign the sum to the output
  assign sum = temp_sum;

endmodule 

  wire [31:0] temp_sum;
  wire temp_cout;

  //The first adder
  adder_16 adder_16_1(temp_sum[15:0], temp_cout, in1[15:0], in2[15:0], cin);

  //The second adder
  adder_16 adder_16_2(temp_sum[31:16], cout, in1[31:16], in2[31:16], temp_cout);

  //Assign the sum to the output
  assign sum = temp_sum;

endmodule