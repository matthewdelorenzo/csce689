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

``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````// State encoding
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        START = 3'b001,
        DATA = 3'b010,
        STOP = 3'b011,
        DONE = 3'b100
    } state_t;

    state_t state, next_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    // State transition logic
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: begin
                if (in == 0) // Detect start bit
                    next_state = START;
                else
                    next_state = IDLE;
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                if (bit_count == 3'd7)
                    next_state = STOP;
                else
                    next_state = DATA;
            end
            STOP: begin
                if (in == 1) // Detect stop bit
                    next_state = DONE;
                else
                    next_state = IDLE; // Wait for stop bit
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic and datapath
    always_ff @(posedge clk) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_count <= 3'b0;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 3'b0;
                end
                START: begin
                    // No action needed, just transition
                end
                DATA: begin
                    shift_reg <= {in, shift_reg[7:1]}; // Shift in the new bit
                    bit_count <= bit_count + 1;
                end
                STOP: begin
                    // No action needed, just transition
                end
                DONE: begin
                    // No action needed, just transition
                end
            endcase
        end
    end

    assign out_byte = (state == DONE) ? shift_reg : 8'bx;
    assign done = (state == DONE);

endmodule