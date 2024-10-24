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

`
``reg [3:0] state, next_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    reg done_reg;

    localparam IDLE = 4'd0,
               START = 4'd1,
               DATA = 4'd2,
               STOP = 4'd3,
               DONE = 4'd4;

    // State transition logic
    always @(*) begin
        case (state)
            IDLE: next_state = in ? IDLE : START;
            START: next_state = DATA;
            DATA: next_state = (bit_count == 3'd7) ? STOP : DATA;
            STOP: next_state = in ? DONE : IDLE;
            DONE: next_state = in ? IDLE : START;
            default: next_state = IDLE;
        endcase
    end

    // State flip-flops
    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output logic
    always @(posedge clk) begin
        if (reset) begin
            shift_reg <= 8'd0;
            bit_count <= 3'd0;
            done_reg <= 1'b0;
        end
        else begin
            case (state)
                START: begin
                    shift_reg <= 8'd0;
                    bit_count <= 3'd0;
                    done_reg <= 1'b0;
                end
                DATA: begin
                    shift_reg <= {in, shift_reg[7:1]};
                    bit_count <= bit_count + 1;
                end
                STOP: begin
                    done_reg <= 1'b1;
                end
                DONE: begin
                    done_reg <= 1'b0;
                end
            endcase
        end
    end

    assign out_byte = shift_reg;
    assign done = done_reg;

endmodule