// Create a set of counters suitable for use as a 12-hour clock (with am/pm indicator). Your counters are clocked by a fast-running clk, with a pulse on ena whenever your clock should increment (i.e., once per second).

// reset resets the clock to 12:00 AM. pm is 0 for AM and 1 for PM. hh, mm, and ss are two BCD (Binary-Coded Decimal) digits each for hours (01-12), minutes (00-59), and seconds (00-59). Reset has higher priority than enable, and can occur even when not enabled.

// Hint: Note that 11:59:59 PM advances to 12:00:00 AM, and 12:59:59 PM advances to 01:00:00 PM. There is no 00:00:00.

module top_module(
    input clk,
    input reset,
    input ena,
    output pm,
    output [7:0] hh,
    output [7:0] mm,
    output [7:0] ss);
    
    // You may use these parameters to access the individual LEDs
    parameter n = 8;
    
    // The mod-n counter
    reg [n-1:0] q_reg = 0;
    wire [n-1:0] q_next;
    
    // The output display
    reg [3:0] hh_reg = 0;
    reg [3:0] mm_reg = 0;
    reg [3:0] ss_reg = 0;
    
    // The state machine
    reg [1:0] state = 0;
    
    // State machine definition
    parameter [1:0] s_reset = 0;
    parameter [1:0] s_idle = 1;
    parameter [1:0] s_pm = 2;
    
    // Output display format
    parameter [3:0] hh_ampm = 4'b1101;
    
    // Next state logic and output display logic
    always @(*) begin
        case (state)
            s_reset: begin
                state <= 0;
                q_reg <= 0;
                ss_reg <= 0;
                mm_reg <= 0;
                hh_reg <= 0;
            end
            s_idle: begin
                state <= 0;
                q_reg <= 0;
                ss_reg <= 0;
                mm_reg <= 0;
                hh_reg <= hh_ampm;
            end
            s_pm: begin
                state <= 0;
                q_reg <= 0;
                ss_reg <= 0;
                mm_reg <= 0;
                hh_reg <= hh_ampm;
            end
        endcase
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            s_reset: begin
                q_next = 0;
                ss_next = 0;
                mm_next = 0;
                hh_next = 0;
                if (reset) begin
                    state <= s_reset;
                end
            end
            s_idle: begin
                if (ena) begin
                    state <= s_pm;
                end
            end
            s_pm: begin
                if (ena) begin
                    state <= s_idle;
                end
            end
        endcase
    end
    
    // Output logic
    assign pm = (state == s_pm)? 1'b1 : 1'b0;
    assign hh = hh_reg;
    assign mm = mm_reg;
    assign ss = ss_reg;
    
endmodule