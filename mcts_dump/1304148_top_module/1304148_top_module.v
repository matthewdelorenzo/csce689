// Build a 32-bit Galois LFSR with taps at bit positions 32, 22, 2, and 1.

// Hint: This is long enough that you'd want to use vectors, not 32 instantiations of DFFs.

module top_module(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
);
   reg [31:1] q;;0;   
always @(posedge clk) begin
        if (reset) begin
            q <= 32'h1;
        end else begin
            q <= {q[30:0], q[31] ^ q[21] ^ q[1] ^ q[0]};
        end
    end
endmodule