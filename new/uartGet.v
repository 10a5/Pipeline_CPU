module uartGet (
    input clk,
    input rst,
    input rx,
    output reg [7:0] data_out = 8'b0, 
    output reg write = 1'b0
); 
    reg state = 1'b0;
    reg [3:0] count = 4'b0;
    reg [26:0] temp = 27'b0;
    always @(posedge clk) begin
        if(~rst) begin
            state <= 1'b0;
            count <= 4'b0;
            temp <= 27'd340;
            write <= 1'b0;
        end
        else begin
            if(state == 1'b0 && rx == 1'b0) begin
                state <= 1;
            end
            else if(state == 1'b1 && count < 4'd10) begin
                if(write == 1'b1) begin
                    write <= 1'b0;
                    temp <= temp + 1;
                end
                if(temp >= 780) begin
                    temp <= 27'b0;
                    count <= count + 1;
                    case(count)
                        4'd1: data_out[0] <= rx;
                        4'd2: data_out[1] <= rx;
                        4'd3: data_out[2] <= rx;
                        4'd4: data_out[3] <= rx;
                        4'd5: data_out[4] <= rx;
                        4'd6: data_out[5] <= rx;
                        4'd7: data_out[6] <= rx;
                        4'd8: data_out[7] <= rx;
                        4'd9: write <= 1'b1;
                    endcase
                end
                else temp <= temp + 1;
            end
            else begin
                state <= 1'b0;
                count <= 4'b0;
                temp <= 27'd340;
                write <= 1'b0;
            end
        end
    end
endmodule
