// Build a 32-bit Galois LFSR with taps at bit positions 32, 22, 2, and 1.

// Hint: This is long enough that you'd want to use vectors, not 32 instantiations of DFFs.

module top_module(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
); 

    wire [31:0] q_next, q_reg;
    
    assign q_next = q_reg + 1;
    
    always @(posedge clk)
        if(reset)
            q_reg <= 32'h1;
        else
            q_reg <= q_next;
    
    assign q = q_reg;

endmodule