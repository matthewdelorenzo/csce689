//Please finish designing the 64 bit multiplier module (multiplier_64) below.
//There are two 64 bit inputs (A and B) and a 128 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_64(output [127:0] product, input [63:0] A, B);
    assign pp0 = A[0]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp1 = A[1]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp2 = A[2]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp3 = A[3]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp4 = A[4]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp5 = A[5]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp6 = A[6]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp7 = A[7]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp8 = A[8]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp9 = A[9]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp10 = A[10]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp11 = A[11]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp12 = A[12]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp13 = A[13]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp14 = A[14]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp15 = A[15]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp16 = A[16]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp17 = A[17]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp18 = A[18]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp19 = A[19]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp20 = A[20]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp21 = A[21]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp22 = A[22]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp23 = A[23]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp24 = A[24]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp25 = A[25]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp26 = A[26]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp27 = A[27]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp28 = A[28]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp29 = A[29]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp30 = A[30]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp31 = A[31]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp32 = A[32]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp33 = A[33]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp34 = A[34]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp35 = A[35]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp36 = A[36]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp37 = A[37]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp38 = A[38]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp39 = A[39]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp40 = A[40]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp41 = A[41]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp42 = A[42]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp43 = A[43]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp44 = A[44]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp45 = A[45]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp46 = A[46]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp47 = A[47]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp48 = A[48]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp49 = A[49]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp50 = A[50]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp51 = A[51]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp52 = A[52]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp53 = A[53]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp54 = A[54]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp55 = A[55]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp56 = A[56]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp57 = A[57]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp58 = A[58]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp59 = A[59]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp60 = A[60]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp61 = A[61]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp62 = A[62]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
    assign pp63 = A[63]? B: 64'b0000000000000000000000000000000000000000000000000000000000000000;
	
	wire [127:0] product;
	
	assign product[0] = pp0[0];
	
	genvar i;
	generate
		for (i=1; i<=127; i=i+1)
			assign product[i] = pp0[i] ^ pp1[i-1];
	endgenerate
	
	assign product[128] = pp1[127];

endmodule