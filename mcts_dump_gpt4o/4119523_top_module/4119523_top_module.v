// You are provided a module with the following declaration:

module dut ( input clk ) ;
// Write a testbench top_modules that creates one instance of module dut (with any instance name), and create a clock signal to drive the module's clk input. The clock has a period of 10 ps. The clock should be initialized to zero with its first transition being 0 to 1.

module top_module ( );

``````````````````````````````````````````````````````module```````````````````````````````````````````````````````````````````````````verilog
    // Declare a wire for the clock signal
    reg clk;

    // Instantiate the dut module
    dut uut (
        .clk(clk)
    );

    // Initial block to set up the clock signal
    initial begin
        // Initialize clock to 0
        clk = 0;
        
        // Generate clock with a period of 10 ps
        forever begin
            #5 clk = ~clk; // Toggle clock every 5 ps to create a 10 ps period
        end
    end

endmodule