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

   //non-blocking<=
    reg [7:0] hours;
    reg [7:0] minutes;
    reg [7:0] seconds;
    reg pm_reg;

    assign hh = hours;
    assign mm = minutes;
    assign ss = seconds;
    assign pm = pm_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hours <= 8'b0001_0010; // 12 in BCD
            minutes <= 8'b0000_0000; // 00 in BCD
            seconds <= 8'b0000_0000; // 00 in BCD
            pm_reg <= 0; // AM
        end else if (ena) begin
            if (seconds == 8'b0101_1001) begin // 59 in BCD
                seconds <= 8'b0000_0000; // Reset to 00
                if (minutes == 8'b0101_1001) begin // 59 in BCD
                    minutes <= 8'b0000_0000; // Reset to 00
                    if (hours == 8'b0001_0010) begin // 12 in BCD
                        hours <= 8'b0000_0001; // Reset to 01
                        pm_reg <= ~pm_reg; // Toggle AM/PM
                    end else if (hours == 8'b0001_0001) begin // 11 in BCD
                        hours <= 8'b0001_0010; // Advance to 12
                    end else begin
                        hours <= hours + 1;
                    end
                end else begin
                    minutes <= minutes + 1;
                end
            end else begin
                seconds <= seconds + 1;
            end
        end
    end
endmodule