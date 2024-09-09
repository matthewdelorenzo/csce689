Create a 2-1 multiplexer. When sel=0, choose a. When sel=1, choose b.
module top_module (
	input [99:0] a,
	input [99:0] b,
	input sel,
	output [99:0] out
);

	mux2to1 #(100) mux0 (a[0:99], b[0:99], sel, out[0:99]);

endmodule