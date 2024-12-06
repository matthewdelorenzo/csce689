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

// FSM states
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;
    
    state_t state, next_state;
    logic [2:0] bit_counter;

    // Register to hold the data byte
    logic [7:0] data_reg;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 3'd0;
            data_reg <= 8'd0;
        end else begin
            state <= next_state;

            if (state == DATA)
                bit_counter <= bit_counter + 3'd1;
            else
                bit_counter <= 3'd0;

            if (state == DATA)
                data_reg <= {in, data_reg[7:1]};
        end
    end
    
    always_comb begin
        case (state)
            IDLE: next_state = in ? IDLE : START;   // Wait for a falling edge (start bit)
            START: next_state = in ? IDLE : DATA;  // Verify start bit and move to DATA state
            DATA: next_state = (bit_counter == 3'd7) ? STOP : DATA;  // Collect 8 data bits
            STOP: next_state = in ? IDLE : START;  // Validate stop bit and go to IDLE. Else look for start bit
            default: next_state = IDLE;
        endcase
    end
    
    assign done = (state == STOP) && in;
    assign out_byte = data_reg;
    
endmodule