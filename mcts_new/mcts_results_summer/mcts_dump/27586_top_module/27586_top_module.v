// A "population count" circuit counts the number of '1's in an input vector. 
// Build a population count circuit for a 255-bit input vector.

// Hint: So many things to add... How about a for loop?

module top_module( 
    input [254:0] in,
    output [7:0] out );
    
    // Use a for loop to generate a 8-bit output.
    
    integer i;
    
    always @(*) begin
        for(i=0; i<8; i=i+1) begin
            out[i] = in[8*i+7] + in[8*i+6] + in[8*i+5] + in[8*i+4] +
                     in[8*i+3] + in[8*i+2] + in[8*i+1] + in[8*i];
        end
    end
    
endmodule