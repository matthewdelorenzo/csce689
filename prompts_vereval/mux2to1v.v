Create a 2-1 multiplexer. When sel=0, choose a. When sel=1, choose b.
module top_module (
	input [99:0] a,
	input [99:0] b,
	input sel,
	output [99:0] out
);