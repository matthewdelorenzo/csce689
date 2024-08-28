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
    
    // Use the clk_divider module to generate a slow clk, then use a clocked always block to generate the pm and hh/mm/ss outputs.
    
    clk_divider slow_clk_divider(clk, reset, clk_out);
    
    always @(posedge clk_out) begin
        if(reset) begin
            pm <= 0;
            hh <= 0;
            mm <= 0;
            ss <= 0;
        end
        else begin
            if(ena) begin
                pm <= ~pm;
                hh <= hh + 1;
                if(hh == 12) begin
                    hh <= 0;
                    mm <= mm + 1;
                    if(mm == 60) begin
                        mm <= 0;
                        ss <= ss + 1;
                    end
                end
            end
        end
    end
endmodule