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
  wire [32:0] temp_sum;
  wire cout_temp;
  //add
  assign sum_temp = in1 + in2;
  //check if the carry-in is equal to the carry-out from the previous adder
  assign temp_sum = {sum_temp, cin};
  assign cout_temp = temp_sum[32];
  //assign outputs
  assign sum = sum_temp[31:0];
  assign cout = cout_temp;
endmodule