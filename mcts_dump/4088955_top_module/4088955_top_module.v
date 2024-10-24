// A "population count" circuit counts the number of '1's in an input vector. 
// Build a population count circuit for a 255-bit input vector.

// Hint: So many things to add... How about a for loop?

module top_module( 
    input [254:0] in,
    output [7:0] out );
verilog
    integer i;
    reg [7:0] count;

    always @(*) begin
        count = 8'd0;
        for (i = 0; i < 255; i = i + 1) begin
            if (in[i] == 1'b1) begin
                count = count + 1;
            end
        end
    end

    assign out = count;

endmodule