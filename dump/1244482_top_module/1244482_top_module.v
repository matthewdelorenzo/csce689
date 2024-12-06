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


    reg [7:0] hour;
    reg [7:0] minute;
    reg [7:0] second;
    reg pm_reg;

    assign hh = hour;
    assign mm = minute;
    assign ss = second;
    assign pm = pm_reg;

    always @(posedge clk) begin
        if (reset) begin
            hour <= 8'b00010010;  // 12 in BCD
            minute <= 8'b00000000; // 00 in BCD
            second <= 8'b00000000; // 00 in BCD
            pm_reg <= 0;           // AM
        end else if (ena) begin
            if (second == 8'b01011001) begin  // 59 in BCD
                second <= 8'b00000000;        // reset seconds
                if (minute == 8'b01011001) begin // 59 in BCD
                    minute <= 8'b00000000;       // reset minutes
                    if (hour == 8'b00010010) begin // 12 in BCD
                        hour <= 8'b00000001;       // rollover hour to 01
                        pm_reg <= ~pm_reg;         // toggle AM/PM
                    end else if (hour == 8'b00001001) begin // 9 in BCD
                        hour <= 8'b00010000;       // switch to 10 in BCD
                    end else if (hour == 8'b00010000) begin // 10 in BCD
                        hour <= 8'b00010001;       // switch to 11 in BCD
                    end else begin
                        hour <= hour + 1;
                    end
                end else begin
                    minute <= minute + 1;
                end
            end else begin
                second <= second + 1;
            end
        end
    end

endmodule