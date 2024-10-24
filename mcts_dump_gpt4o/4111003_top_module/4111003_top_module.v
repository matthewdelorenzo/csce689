// Build a 32-bit Galois LFSR with taps at bit positions 32, 22, 2, and 1.

// Hint: This is long enough that you'd want to use vectors, not 32 instantiations of DFFs.

module top_module(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
);
````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````verilog
    reg [31:0] lfsr;

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= 32'h1;
        end else begin
            lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        end
    end

    assign q = lfsr;

endmodule