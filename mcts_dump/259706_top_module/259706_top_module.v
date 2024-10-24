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
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        START = 3'b001,
        DATA = 3'b010,
        PARITY = 3'b011,
        STOP = 3'b100,
        ERROR = 3'b101
    } state_t;

    state_t state, next_state;
    reg [3:0] bit_count;
    reg [7:0] data_reg;
    reg parity_bit;
    wire odd_parity;

    // Instantiate the parity module
    parity parity_checker (
        .clk(clk),
        .reset(reset | (state == IDLE)),
        .in(in),
        .odd(odd_parity)
    );

    // State transition logic
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            data_reg <= 8'b0;
            parity_bit <= 0;
        end else begin
            state <= next_state;
            if (state == DATA) begin
                data_reg <= {in, data_reg[7:1]};
                bit_count <= bit_count + 1;
            end else if (state == PARITY) begin
                parity_bit <= in;
            end else if (state == STOP) begin
                bit_count <= 0;
            end
        end
    end

    // Next state logic
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
                    next_state = PARITY;
                else
                    next_state = DATA;
            end
            PARITY: begin
                next_state = STOP;
            end
            STOP: begin
                if (in == 1) begin // Stop bit detected
                    if (odd_parity && parity_bit) // Check for odd parity
                        next_state = IDLE;
                    else
                        next_state = ERROR;
                end else
                    next_state = STOP;
            end
            ERROR: begin
                if (in == 1) // Wait for stop bit
                    next_state = IDLE;
                else
                    next_state = ERROR;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    assign out_byte = data_reg;
    assign done = (state == STOP) && (in == 1) && (odd_parity && parity_bit);

endmodule