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
    
    // Use a clocked always block
    //   copy the ena signal to a clocked always block
    //   copy the pm signal to a clocked always block
    //   copy the hh, mm, and ss signals to a clocked always block
    
    wire clk_ena;
    wire [7:0] clk_hh, clk_mm, clk_ss;
    
    clocked_clock_divider #(12500000) clk_div (clk, reset, clk_ena);
    
    always @(posedge clk_ena) begin
        if (reset) begin
            // reset
            pm <= 0;
        end
        else if (ena) begin
            // normal mode
            pm <= pm;
        end
        else begin
            // paused mode
            pm <= 0;
        end
    end
    
    always @(posedge clk_ena) begin
        if (reset) begin
            // reset
            hh <= 0;
            mm <= 0;
            ss <= 0;
        end
        else if (ena) begin
            // normal mode
            hh <= clk_hh;
            mm <= clk_mm;
            ss <= clk_ss;
        end
        else begin
            // paused mode
            hh <= 0;
            mm <= 0;
            ss <= 0;
        end
    end
    
endmodule