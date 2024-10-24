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

verilog
    // State encoding
    localparam IDLE = 2'd0;
    localparam START = 2'd1;
    localparam DATA = 2'd2;
    localparam STOP = 2'd3;

    reg [1:0] state, next_state;
    reg [2:0] bit_count;  // Counter for data bits
    reg [7:0] shift_reg;  // Shift register for data bits

    // State transition logic (sequential)
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic (combinational)
    always @(*) begin
        case (state)
            IDLE: begin
                if (in == 0) begin  // Detect start bit (active low)
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                if (bit_count == 3'd7) begin
                    next_state = STOP;
                end else begin
                    next_state = DATA;
                end
            end
            STOP: begin
                if (in == 1) begin  // Detect stop bit (active high)
                    next_state = IDLE;
                end else begin
                    next_state = STOP;  // Wait for stop bit to be high
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic and datapath operations
    always @(posedge clk) begin
        if (reset) begin
            bit_count <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 3'd0;
                end
                START: begin
                    // No operation needed, just transition to DATA
                end
                DATA: begin
                    shift_reg <= {in, shift_reg[7:1]};  // Shift in the LSB first
                    bit_count <= bit_count + 1;
                end
                STOP: begin
                    // No operation needed, just check stop bit
                end
            endcase
        end
    end

    // Assign outputs
    assign out_byte = shift_reg;
    assign done = (state == STOP) && (in == 1);  // Done is valid when stop bit is correctly detected

endmodule