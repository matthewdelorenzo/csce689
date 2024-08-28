//Please finish designing the 32 bit multiplier module (multiplier_32) below.
//There are two 32 bit inputs (A and B) and a 64 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_32(output [63:0] product, input [31:0] A, B);
	
	wire [31:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15;

	assign pp0 = A[0]? B: 32'b00000000000000000000000000000000;
	assign pp1 = A[1]? B: 32'b00000000000000000000000000000000;
	assign pp2 = A[2]? B: 32'b00000000000000000000000000000000;
	assign pp3 = A[3]? B: 32'b00000000000000000000000000000000;
	assign pp4 = A[4]? B: 32'b00000000000000000000000000000000;
	assign pp5 = A[5]? B: 32'b00000000000000000000000000000000;
	assign pp6 = A[6]? B: 32'b00000000000000000000000000000000;
	assign pp7 = A[7]? B: 32'b00000000000000000000000000000000;
	assign pp8 = A[8]? B: 32'b00000000000000000000000000000000;
	assign pp9 = A[9]? B: 32'b00000000000000000000000000000000;
	assign pp10 = A[10]? B: 32'b00000000000000000000000000000000;
	assign pp11 = A[11]? B: 32'b00000000000000000000000000000000;
	assign pp12 = A[12]? B: 32'b00000000000000000000000000000000;
	assign pp13 = A[13]? B: 32'b00000000000000000000000000000000;
	assign pp14 = A[14]? B: 32'b00000000000000000000000000000000;
	assign pp15 = A[15]? B: 32'b00000000000000000000000000000000;

	assign product[0] = pp0[0];

	/* 1st CLA */
	wire [31:0] G1, P1, C1;
	assign G1[0]  = pp0[1]  & pp1[0];
	assign G1[1]  = pp0[2]  & pp1[1];
	assign G1[2]  = pp0[3]  & pp1[2];
	assign G1[3]  = pp0[4]  & pp1[3];
	assign G1[4]  = pp0[5]  & pp1[4];
	assign G1[5]  = pp0[6]  & pp1[5];
	assign G1[6]  = pp0[7]  & pp1[6];
	assign G1[7]  = pp0[8]  & pp1[7];
	assign G1[8]  = pp0[9]  & pp1[8];
	assign G1[9]  = pp0[10] & pp1[9];
	assign G1[10] = pp0[11] & pp1[10];
	assign G1[11] = pp0[12] & pp1[11];
	assign G1[12] = pp0[13] & pp1[12];
	assign G1[13] = pp0[14] & pp1[13];
	assign G1[14] = pp0[15] & pp1[14];
	assign G1[15] = 0       & pp1[15];
	assign P1[0]  = pp0[1]  ^ pp1[0];
	assign P1[1]  = pp0[2]  ^ pp1[1];
	assign P1[2]  = pp0[3]  ^ pp1[2];
	assign P1[3]  = pp0[4]  ^ pp1[3];
	assign P1[4]  = pp0[5]  ^ pp1[4];
	assign P1[5]  = pp0[6]  ^ pp1[5];
	assign P1[6]  = pp0[7]  ^ pp1[6];
	assign P1[7]  = pp0[8]  ^ pp1[7];
	assign P1[8]  = pp0[9]  ^ pp1[8];
	assign P1[9]  = pp0[10] ^ pp1[9];
	assign P1[10] = pp0[11] ^ pp1[10];
	assign P1