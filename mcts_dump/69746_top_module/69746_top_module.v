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

// State encoding
    typedef enum reg [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP
    } state_t;

    // State registers
    reg [2:0] state, next_state;
    reg [3:0] bit_count; // To count the number of bits received
    reg [7:0] data;      // To store the received data byte
    wire odd_parity;     // Parity check output

    // Instantiate the parity module
    parity parity_checker (
        .clk(clk),
        .reset(reset | (state == IDLE)), // Reset on reset signal or when returning to IDLE
        .in(in),
        .odd(odd_parity)
    );

    // State transitions
    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state; // Default to hold state
        case (state)
            IDLE: begin
                if (in == 0) // Start bit detected
                    next_state = START;
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                if (bit_count == 8)
                    next_state = PARITY;
            end
            PARITY: begin
                next_state = STOP;
            end
            STOP: begin
                if (in == 1) // Stop bit detected
                    next_state = IDLE;
            end
        endcase
    end

    // Bit counting and data capturing
    always @(posedge clk) begin
        if (reset || state == IDLE) begin
            bit_count <= 0;
            data <= 8'b0;
        end else if (state == DATA) begin
            data <= {in, data[7:1]}; // Shift in the data bits
            bit_count <= bit_count + 1;
        end else if (state == PARITY) begin
            bit_count <= 0; // Reset bit count after data bits
        end
    end

    // Output logic
    assign out_byte = data;
    assign done = (state == STOP && in == 1 && odd_parity); // Assert done if stop bit is correct and parity is odd

endmodule