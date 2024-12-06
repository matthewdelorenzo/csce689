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
    logic [3:0] bit_count; // Counter for bits
    logic [7:0] shift_reg; // Shift register for data bits
    logic prev_in;

    // FSM logic
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            prev_in <= 1'b1;
        end else begin
            state <= next_state;
            if (state == DATA) 
                bit_count <= bit_count + 1;
            
            prev_in <= in;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: 
                if (!in)
                    next_state = START;
            START: 
                if (prev_in && !in) // Detect start bit
                    next_state = DATA;
            DATA: 
                if (bit_count == 8)
                    next_state = STOP;
            STOP: 
                if (in)
                    next_state = IDLE;
        endcase
    end

    // Output and shift register logic
    always_ff @(posedge clk) begin
        if (reset) begin
            shift_reg <= 8'd0;
        end else if (state == DATA) begin
            shift_reg <= {in, shift_reg[7:1]}; // Shift in the incoming bit
        end
    end

    assign out_byte = (state == STOP && in) ? shift_reg : 8'bx;
    assign done = (state == STOP && in);

endmodule