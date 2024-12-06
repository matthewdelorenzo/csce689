//Design a 16-bit adder.
//There are two 16 bit inputs (in1 and in2) and a single carry-in input bit, cin.
//The outputs are a 16 bit value, [15:0] sum, and a single carry-out output bit, cout.
//The module should utilize the inputs (in1 and in2) and the cin bit to obtain the output sum and cout values.
module top_module(output [15:0] sum,
                      output cout,
                      input [15:0] in1, in2,
                      input cin);
n   wire [15:0 sum;n]    wire[15:0] carry;

    // Use a generate block to create a 16-bit adder
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: adder_bit
            if (i == 0) begin
                // First bit addition with carry-in
                assign {carry[i], sum[i]} = in1[i] + in2[i] + cin;
            end else begin
                // Subsequent bit additions with carry from previous bit
                assign {carry[i], sum[i]} = in1[i] + in2[i] + carry[i-1];
            end
        end
    endgenerate

    // Assign the final carry-out
    assign cout = carry[15];

endmodule