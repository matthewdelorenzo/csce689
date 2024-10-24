// You are provided a module with the following declaration:

module dut ( input clk ) ;
// Write a testbench top_modules that creates one instance of module dut (with any instance name), and create a clock signal to drive the module's clk input. The clock has a period of 10 ps. The clock should be initialized to zero with its first transition being 0 to 1.

module top_module ( );

// Declare a wire for the clock signal
    reg clk;

    // Instantiate the dut module
    dut my_dut (
        .clk(clk)
    );

    // Initial block to initialize and toggle the clock
    initial begin
        // Initialize clock to zero
        clk = 0;
        
        // Generate clock signal with a period of 10 ps
        forever #5 clk = ~clk;
    end

endmodule