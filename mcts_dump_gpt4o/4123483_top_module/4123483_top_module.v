// You are given a T flip-flop module with the following declaration:

module tff (
    input clk,
    input reset,   // active-high synchronous reset
    input t,       // toggle
    output q
);

// Write a testbench that instantiates one tff and will reset the T flip-flop then toggle it to the "1" state.

module top_module ();



`````````````````````````````````````````````module`````````````````````modulemoduleverilog
    reg clk;
    reg reset;
    reg t;
    wire q;

    // Instantiate the T flip-flop
    tff uut (
        .clk(clk),
        .reset(reset),
        .t(t),
        .q(q)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 0;
        t = 0;

        // Apply reset
        #10 reset = 1;
        #10 reset = 0;

        // Toggle to "1" state
        #10 t = 1;
        #10 t = 0;

        // Finish simulation
        #50 $finish;
    end

endmodule