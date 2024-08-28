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
 
    assign temp_sum = in1 + in2 + cin;
    assign temp_cout = (temp_sum[32] == 1'b1);
 
    assign sum = temp_sum[31:0];
    assign cout = temp_cout;
 
endmodule