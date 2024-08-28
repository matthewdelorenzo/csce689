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
    
    wire clk_out;
    wire [7:0] hh_out;
    wire [7:0] mm_out;
    wire [7:0] ss_out;
    
    clk_wiz_0 my_clk_wiz_0(
      .clk_out1(clk_out),
      .clk_in1(clk),
      .reset1(reset),
      .ena1(ena));
        
    clk_wiz_0_to_7_segment_decoder_0 my_clk_wiz_0_to_7_segment_decoder_0(
      .clk_out1(clk_out),
      .clk_in1(clk),
      .reset1(reset),
      .ena1(ena),
      .digit1(ss_out),
      .digit2(mm_out),
      .digit3(hh_out),
      .digit4(mm_out),
      .digit5(hh_out),
      .digit6(mm_out),
      .digit7(ss_out));
        
    assign pm = 0;
    assign hh = hh_out;
    assign mm = mm_out;
    assign ss = ss_out;
    
endmodule