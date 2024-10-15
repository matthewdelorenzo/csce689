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

//////// Declare internal registers
reg [3:0] hours, minutes, seconds;
reg am_pm;

// Reset and clock logic
always @(posedge clk)
begin
    if (reset)
    begin
        hours <= 4'b0001; // 12:00 AM
        minutes <= 4'b0000;
        seconds <= 4'b0000;
        am_pm <= 1'b0; // AM
    end
    else if (ena)
    begin
        if (seconds == 4'b1001) // 59 seconds
        begin
            seconds <= 4'b0000; // reset to 0
            if (minutes == 4'b1001) // 59 minutes
            begin
                minutes <= 4'b0000; // reset to 0
                if (hours == 4'b1100) // 12 hours
                begin
                    hours <= 4'b0001; // reset to 1
                    am_pm <= ~am_pm; // toggle AM/PM
                end
                else if (hours == 4'b1011) // 11 hours
                    hours <= 4'b1100; // advance to 12
                else
                    hours <= hours + 1'b1; // advance hour
            end
            else if (minutes[3:0] == 4'b1001) // 9 minutes
                minutes <= minutes + 4'b0001; // advance to next 10 minutes
            else
                minutes <= minutes + 1'b1; // advance minute
        end
        else if (seconds[3:0] == 4'b1001) // 9 seconds
            seconds <= seconds + 4'b0001; // advance to next 10 seconds
        else
            seconds <= seconds + 1'b1; // advance second
    end
end

// Assign outputs
assign pm = am_pm;
assign hh = {4'b0000, hours};
assign mm = {4'b0000, minutes};
assign ss = {4'b0000, seconds};

endmodule