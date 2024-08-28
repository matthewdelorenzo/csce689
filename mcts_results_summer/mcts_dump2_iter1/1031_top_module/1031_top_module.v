// Assume you have a finite state machine that will identify when bytes have been correctly received when given a stream of bits. It needs to identify the start bit, wait for all 8 data bits, then verify that the stop bit was correct. If the stop bit does not appear when expected, the FSM must wait until it finds a stop bit before attempting to receive the next byte.
// Now that you have a finite state machine that can identify when bytes are correctly received in a serial bitstream, add a datapath that will output the correctly-received data byte. out_byte needs to be valid when done is 1, and is don't-care otherwise.

// Note that the serial protocol sends the least significant bit first.

// Hint: The serial bitstream needs to be shifted in one bit at a time, then read out in parallel. 
// Use FSM from Fsm_serial
// New: Datapath to latch input bits.

module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
);
    
    // Modify FSM and datapath from Fsm_serial
    
    parameter idle = 0, rec_data = 1, stop_bit = 2, overflow = 3;
    reg [1:0] state, next_state;
    reg [3:0] counter;
    reg [7:0] rec_data_byte;
    
    always @(posedge clk) begin
        if(reset)
            state <= idle;
        else
            state <= next_state;
    end
    
    always @(*) begin
        case(state)
            idle:
                begin
                    if(~in)
                        next_state = rec_data;
                    else
                        next_state = idle;
                end
            rec_data:
                begin
                    if(counter == 7)
                        next_state = stop_bit;
                    else
                        next_state = rec_data;
                end
            stop_bit:
                begin
                    if(in)
                        next_state = overflow;
                    else
                        next_state = idle;
                end
            overflow:
                begin
                    next_state = idle;
                end
            default:
                next_state = idle;
        endcase
    end
    
    always @(posedge clk) begin
        if(state == rec_data && counter < 7)
            rec_data_byte[7-counter] <= in;
    end
    
    assign done = (state == overflow)? 1:0;
    assign out_byte = rec_data_byte;
    
    always @(posedge clk) begin
        if(state == stop_bit)
            counter <= counter + 1;
        else
            counter <= 0;
    end
    
endmodule