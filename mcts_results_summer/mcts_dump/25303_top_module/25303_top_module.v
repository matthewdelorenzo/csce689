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
    
    // Use FSM from Fsm_serial
    // New: Latch input bits.
    
    reg [2:0] state, next_state;
    reg [7:0] out;
    reg done_reg;
    
    always @(*) begin
        state <= next_state;
    end
    
    always @(posedge clk) begin
        if(reset) begin
            out <= 0;
            done_reg <= 0;
        end
        else begin
            if(next_state == 3)
                out <= {out[6:0], in};
            else if(next_state == 2)
                out <= out >> 1;
            else if(next_state == 1)
                out <= out >> 2;
            else if(next_state == 0)
                out <= out >> 4;
            if(next_state == 3)
                done_reg <= 1;
            else
                done_reg <= 0;
        end
    end
    
    always @(*) begin
        next_state = state;
        case(state)
            0: begin
                if(in)
                    next_state = 1;
                else
                    next_state = 0;
            end
            1: begin
                if(in)
                    next_state = 2;
                else
                    next_state = 0;
            end
            2: begin
                if(in)
                    next_state = 3;
                else
                    next_state = 0;
            end
            3: begin
                if(~in)
                    next_state = 3;
                else
                    next_state = 0;
            end
            default: next_state = 0;
        endcase
    end
    
    assign done = done_reg;
    assign out_byte = out;
    
endmodule