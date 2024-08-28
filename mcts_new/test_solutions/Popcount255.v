
    always @(*) begin
        out = 0;
        for(int i = 0; i < 255; i++) begin
            if(in[i])
                out = out + 1;
            else
                out = out + 0;
        end
    end
    
endmodule
