//Please finish designing the 32 bit multiplier module (multiplier_32) below.
//There are two 32 bit inputs (A and B) and a 64 bit output (product).
//The module should utilize the inputs (A and B) to determine the output product correctly in its implementation.
module multiplier_32(output [63:0] product, input [31:0] A, B);
	wire [63:0] product;
	wire [31:0] A;
	wire [31:0] B;
	
	assign product = A * B;
	
endmodule