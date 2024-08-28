// Parity checking is often used as a simple method of detecting errors when 
// transmitting data through an imperfect channel. Create a circuit that will 
// compute a parity bit for a 8-bit byte (which will add a 9th bit to the byte). 
// We will use "even" parity, where the parity bit is just the XOR of all 8 data bits.

module top_module (
    input [7:0] in,
    output parity);

    assign parity = ^in;

    // The circuit below is a reduced version of the Verilog code above.
    // The following code implements a single-bit full adder.
    // It uses the following truth table:
    //
    //     a   b   sum   carry
    //    ---------------------
    //     0   0   0     0
    //     0   1   1     0
    //     1   0   1     0
    //     1   1   0     1
    //
    // Verilog assumes that the output is only generated when the inputs are 
    // asserted, so the final carry output is not necessary. The code below
    // removes the final carry output.
    //
    // Note that the output is XORed with a parity bit, which is itself a 
    // XOR with a one bit. This is done to eliminate any potential problems 
    // related to the Verilog "simulation" of a full adder.
    //
    // Also note that the sum bit is XORed with a one bit. This is done to 
    // eliminate any potential problems related to the Verilog "simulation" 
    // of a full adder.
    //
    // The following code assumes that the input and output are both 
    // one-bit wide.
    //
    assign parity = ^(^in);
endmodule