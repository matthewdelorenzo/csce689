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

```
reg [7:``0`reg [7:0] shift_reg;
reg [3:0] bit_count;
reg [1:0] state, next_state;

// State encoding
localparam IDLE = 2'b00,
           START = 2'b01,
           DATA = 2'b10,
           STOP = 2'b11;

// FSM state transition
always @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// FSM next state logic
always @(*) begin
    case (state)
        IDLE: begin
            if (in == 0) // Start bit detected
                next_state = START;
            else
                next_state = IDLE;
        end
        START: begin
            next_state = DATA;
        end
        DATA: begin
            if (bit_count == 8)
                next_state = STOP;
            else
                next_state = DATA;
        end
        STOP: begin
            if (in == 1) // Stop bit detected
                next_state = IDLE;
            else
                next_state = STOP;
        end
        default: next_state = IDLE;
    endcase
end

// Datapath to shift in bits and count them
always @(posedge clk) begin
    if (reset) begin
        shift_reg <= 8'b0;
        bit_count <= 4'b0;
    end else if (state == DATA) begin
        shift_reg <= {in, shift_reg[7:1]};
        bit_count <= bit_count + 1;
    end else if (state == STOP) begin
        bit_count <= 4'b0;
    end
end

// Output logic
assign out_byte = shift_reg;
assign done = (state == STOP) && (in == 1);

endmodule