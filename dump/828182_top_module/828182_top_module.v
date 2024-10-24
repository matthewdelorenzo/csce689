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

// State encoding
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    // State and next-state logic
    state_t state, next_state;

    // Bit counter for data bits
    logic [2:0] bit_counter;

    // Shift register for assembling the data byte
    logic [7:0] shift_reg;

    // Combinational logic to update next state
    always_comb begin
        case (state)
            IDLE: next_state = in ? IDLE : START; // Wait for start bit (0)
            START: next_state = DATA;             // Start bit detected, shift to DATA
            DATA: next_state = (bit_counter == 3'b111) ? STOP : DATA; // Receive 8 data bits
            STOP: next_state = in ? IDLE : STOP;  // Verify stop bit (1)
            default: next_state = IDLE;
        endcase
    end

    // Sequential logic for state transitions
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 3'b0;
            shift_reg <= 8'b0;
        end else begin
            state <= next_state;

            // State-specific behavior
            if (state == DATA) begin
                shift_reg <= {in, shift_reg[7:1]}; // Shift in LSB first
                bit_counter <= bit_counter + 1;
            end

            if (state == STOP && next_state == IDLE) begin
                shift_reg <= 8'b0;
                bit_counter <= 3'b0;
            end
        end
    end

    // Output assignments
    assign out_byte = shift_reg;
    assign done = (state == STOP) && (next_state == IDLE) && in;
endmodule