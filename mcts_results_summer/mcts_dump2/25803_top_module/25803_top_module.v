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
    parameter START = 3'd0, DATA = 3'd1, PARITY = 3'd2, STOP = 3'd3, DELAY = 3'd4;
    reg [2:0] state, next_state;
    reg [7:0] data;
    reg odd;
    reg [1:0] count;
    
    always @(posedge clk)
        if (reset) state <= START;
        else state <= next_state;
    
    always @(*)
        case (state)
            START: begin
                if (in) next_state <= DATA;
                else next_state <= START;
            end
            DATA: begin
                if (count == 7) next_state <= PARITY;
                else next_state <= DATA;
            end
            PARITY: begin
                if (count == 7) next_state <= STOP;
                else next_state <= PARITY;
            end
            STOP: begin
                if (count == 2) next_state <= DELAY;
                else next_state <= STOP;
            end
            DELAY: begin
                if (count == 2) next_state <= START;
                else next_state <= DELAY;
            end
            default: next_state <= START;
        endcase
    
    always @(posedge clk)
        if (reset) begin
            data <= 8'b0;
            count <= 2'b0;
        end
        else begin
            if (state == DATA) data[7] <= in;
            if (state == PARITY) odd <= in ^ data[7];
            if (state == STOP) begin
                if (count == 2) count <= 2'b0;
                else count <= count + 1'b1;
            end
        end
    
    assign done = (state == DELAY) && (count == 2);
    
    assign out_byte = odd? {data[6:0], 1'b0} : {data[6:0], 1'b1};
    
endmodule