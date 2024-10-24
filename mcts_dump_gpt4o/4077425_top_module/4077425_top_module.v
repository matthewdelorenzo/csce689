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

`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````verilog
    reg [7:0] hours;
    reg [7:0] minutes;
    reg [7:0] seconds;
    reg am_pm;

    assign hh = hours;
    assign mm = minutes;
    assign ss = seconds;
    assign pm = am_pm;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset to 12:00:00 AM
            hours <= 8'h12;
            minutes <= 8'h00;
            seconds <= 8'h00;
            am_pm <= 1'b0; // AM
        end else if (ena) begin
            // Increment seconds
            if (seconds == 8'h59) begin
                seconds <= 8'h00;
                // Increment minutes
                if (minutes == 8'h59) begin
                    minutes <= 8'h00;
                    // Increment hours
                    if (hours == 8'h12) begin
                        hours <= 8'h01;
                        am_pm <= ~am_pm; // Toggle AM/PM
                    end else if (hours == 8'h11) begin
                        hours <= 8'h12;
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