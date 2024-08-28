// A "population count" circuit counts the number of '1's in an input vector. 
// Build a population count circuit for a 255-bit input vector.

// Hint: So many things to add... How about a for loop?

module top_module( 
    input [254:0] in,
    output [7:0] out );

    assign out = in[7:0] + in[15:8] + in[23:16] + in[31:24] + in[39:32] + in[47:40] + in[55:48] + in[63:56] + in[71:64] + in[79:72] + in[87:80] + in[95:88] + in[103:96] + in[111:104] + in[119:112] + in[127:120] + in[135:128] + in[143:136] + in[151:144] + in[159:152] + in[167:160] + in[175:168] + in[183:176] + in[191:184] + in[199:192] + in[207:200] + in[215:208] + in[223:216] + in[231:224] + in[239:232] + in[247:240] + in[255:248];

endmodule