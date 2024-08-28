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
 
    wire [3:0] h_out, m_out, s_out;
 
    bcd_to_7seg bcd_to_7seg_h(.in(h_out),.out(hh));
    bcd_to_7seg bcd_to_7seg_m(.in(m_out),.out(mm));
    bcd_to_7seg bcd_to_7seg_s(.in(s_out),.out(ss));
 
    wire [3:0] h_in, m_in, s_in;
    wire [3:0] h_next, m_next, s_next;
 
    assign h_in = h_out;
    assign m_in = m_out;
    assign s_in = s_out;
 
    always @(posedge clk) begin
        if (reset) begin
            h_out <= 4'd0;
            m_out <= 4'd0;
            s_out <= 4'd0;
        end
        else begin
            if (ena) begin
                h_out <= h_next;
                m_out <= m_next;
                s_out <= s_next;
            end
        end
    end
 
    assign h_next = (h_in == 4'd9)? 4'd0 : h_in + 4'd1;
    assign m_next = (m_in == 4'd9)? (h_in == 4'd0? 4'd0 : 4'd5) : m_in + 4'd1;
    assign s_next = (s_in == 4'd9)? (m_in == 4'd0? 4'd0 : 4'd5) : s_in + 4'd1;
 
    assign pm = (h_in == 4'd0) && (m_in == 4'd0)? 1'b0 : 1'b1;
 
endmodule