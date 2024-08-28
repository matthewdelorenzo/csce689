// Build a 32-bit Galois LFSR with taps at bit positions 32, 22, 2, and 1.

// Hint: This is long enough that you'd want to use vectors, not 32 instantiations of DFFs.

module top_module(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
); 

    reg [31:0] q_next;
    
    always @(*) begin
        q_next = q[31] ^ q[0] ^ q[1] ^ q[2] ^ q[3];
        q_next[31] = q[0][31] ^ q[0][0] ^ q[0][1] ^ q[0][2] ^ q[0][3];
        q_next[30:0] = q[31:0];
    end
    
    always @(posedge clk) begin
        if(reset)
            q <= 32'h1;
        else
            q <= q_next;
    end
    
endmodule