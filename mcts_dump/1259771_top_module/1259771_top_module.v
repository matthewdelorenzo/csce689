//Design a 16-bit adder.
//There are two 16 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 16 bit value, [15:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module top_module(output [15:0] sum,
                      output cout,
                      input [15:0] in1, in2,
                      input cin);
wire[16:0 sum); wire[16:0:0] carry;

assign {carry, sum} = in1 + in2 + cin;
assign cout = carry[16];

endmodule