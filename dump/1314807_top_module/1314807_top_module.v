// Build a 32-bit Galois LFSR with taps at bit positions 32, 22, 2, and 1.

// Hint: This is long enough that you'd want to use vectors, not 32 instantiations of DFFs.

module top_module(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
);
reg [31:0] r;

    always @(posedge clk) begin
        if (reset) begin
            r <= 32'h1;
        end else begin
            r <= {r[30:0], r[31] ^ r[21] ^ r[1] ^ r[0]};
        end
    end
    
    assign q = r;
endmodule