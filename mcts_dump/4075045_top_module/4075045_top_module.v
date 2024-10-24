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

verilog
    // State encoding
    typedef enum reg [2:0] {
        IDLE = 3'b000,
        START = 3'b001,
        RECEIVE = 3'b010,
        PARITY_CHECK = 3'b011,
        STOP = 3'b100
    } state_t;

    state_t state, next_state;
    reg [7:0] data_shift;
    reg [3:0] bit_count;
    wire parity_odd;
    reg parity_reset;
    reg done_reg;

    // Instantiate the parity module
    parity parity_inst (
        .clk(clk),
        .reset(parity_reset),
        .in(in),
        .odd(parity_odd)
    );

    // State transition logic
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            done_reg <= 0;
            parity_reset <= 1;
        end else begin
            state <= next_state;
            if (state == RECEIVE) bit_count <= bit_count + 1'b1;
            if (state == STOP) done_reg <= 0;
            if (state == PARITY_CHECK && parity_odd) done_reg <= 1;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        parity_reset = 0;
        case (state)
            IDLE: begin
                if (!in) next_state = START;  // Detect start bit
            end
            START: begin
                next_state = RECEIVE;
                bit_count = 0;
                parity_reset = 1;
            end
            RECEIVE: begin
                if (bit_count == 8) next_state = PARITY_CHECK;
            end
            PARITY_CHECK: begin
                if (parity_odd) next_state = STOP;
                else next_state = IDLE;  // Parity error, go back to idle
            end
            STOP: begin
                if (in) next_state = IDLE;  // Stop bit detected
                else next_state = START;  // If no stop bit, assume it's a new start bit
            end
        endcase
    end

    // Output logic
    always @(posedge clk) begin
        if (state == RECEIVE) begin
            data_shift <= {in, data_shift[7:1]};
        end
    end

    assign out_byte = data_shift;
    assign done = done_reg;

endmodule