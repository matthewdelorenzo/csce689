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

// New: Datapath to latch input bits.

// Define states

`define START 0
`define DATA 1
`define STOP 2
`define IDLE 3

reg [2:0] state, next_state;
reg [7:0] data;
reg out;

always @(*) begin
    case (state)
        `START: begin
            next_state = `DATA;
            out = 1'b0;
        end
        `DATA: begin
            if(in)
                next_state = `STOP;
            else
                next_state = `DATA;
        end
        `STOP: begin
            if(in)
                next_state = `IDLE;
            else
                next_state = `START;
        end
        `IDLE: begin
            if(in)
                next_state = `START;
            else
                next_state = `IDLE;
        end
        default: next_state = `IDLE;
    endcase
end

always @(posedge clk) begin
    if(reset)
        state <= `IDLE;
    else
        state <= next_state;
end

always @(posedge clk) begin
    if(state == `DATA)
        data <= {data[6:0], in};
end

assign done = (state == `STOP);

assign out_byte = data;

endmodule