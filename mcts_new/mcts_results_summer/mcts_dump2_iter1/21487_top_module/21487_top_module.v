// We want to add parity checking to the serial receiver. Parity checking adds one extra bit after each data byte. We will use odd parity, where the number of 1s in the 9 bits received must be odd. For example, 101001011 satisfies odd parity (there are 5 1s), but 001001011 does not.

// Change your FSM and datapath to perform odd parity checking. Assert the done signal only if a byte is correctly received and its parity check passes. Like the serial receiver FSM, this FSM needs to identify the start bit, wait for all 9 (data and parity) bits, then verify that the stop bit was correct. If the stop bit does not appear when expected, the FSM must wait until it finds a stop bit before attempting to receive the next byte.

// You are provided with the following module that can be used to calculate the parity of the input stream (It's a TFF with reset). The intended use is that it should be given the input bit stream, and reset at appropriate times so it counts the number of 1 bits in each byte.
    // Modify FSM and datapath from Fsm_serialdata
    // New: Add parity checking.

module parity (
    input clk,
    input reset,
    input in,
    output reg odd);

    always @(posedge clk)
        if (reset) odd <= 0;
        else if (in) odd <= ~odd;

endmodule

// Note that the serial protocol sends the least significant bit first, and the parity bit after the 8 data bits.

module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
);
    // Use FSM from Fsm_serialdata
    // New: Add parity checking.
    // New: Add state to FSM.
    
    parameter idle = 0, rec_data = 1, stop_bit = 2, wait_parity = 3, done = 4;
    reg [2:0] state, next_state;
    
    // New: Add parity checking.
    parity checker(clk, reset, in, odd);
    
    always @(posedge clk)
        if (reset) state <= idle;
        else state <= next_state;
    
    always @(*)
        case (state)
            idle:
                begin
                    if (in) next_state = rec_data;
                    else next_state = idle;
                end
            rec_data:
                begin
                    if (in) next_state = rec_data;
                    else next_state = stop_bit;
                end
            stop_bit:
                begin
                    if (in) next_state = wait_parity;
                    else next_state = idle;
                end
            wait_parity:
                begin
                    if (in) next_state = done;
                    else next_state = idle;
                end
            done:
                begin
                    if (in) next_state = idle;
                    else next_state = idle;
                end
            default:
                next_state = idle;
        endcase
    
    // New: Add parity checking.
    assign odd = ~(in ^ out_byte[7]);
    
    // New: Add state to FSM.
    assign done = (state == done);
    
    // New: Add parity checking.
    assign out_byte = (state == rec_data)? {in, out_byte[7:1]} : 8'b0;
    
endmodule