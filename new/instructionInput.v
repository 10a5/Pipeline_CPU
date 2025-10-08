`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/23 11:39:55
// Design Name: 
// Module Name: instructionInput
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instructionInput(
    input clk,
    input rst,
    input rx,
    // output[7:0] data_out,
    output reg [31:0] inst = 32'b0,
    output reg writeIns = 1'b0
    );
    wire write;
    // reg[31:0] inst = 32'b0;
    // assign debug = inst == 32'h12345678;
    reg [1:0] stage = 2'b00;
    wire [7:0] data;
    uartGet uart(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data),
        .write(write)
    );
//    assign data_out = inst[23:16];
    always @(posedge clk) begin
        if(!rst) begin
            stage <= 2'b00;
            inst <= 32'b0;
        end
        else begin
            if(write) begin
                case(stage)
                    2'b11: begin
                        inst[7:0] <= data;
                        stage <= 2'b00;
                        writeIns <= 1'b0;
                    end
                    2'b10: begin
                        inst[15:8] <= data;
                        stage <= 2'b11;
                        writeIns <= 1'b0;
                    end
                    2'b01: begin
                        inst[23:16] <= data;
                        stage <= 2'b10;
                        writeIns <= 1'b0;
                    end
                    2'b00: begin
                        inst[31:24] <= data;
                        stage <= 2'b01;
                        writeIns <= 1'b1;
                    end
                endcase
            end
            else begin
                stage <= stage;
                writeIns <= 1'b0;
            end
        end
    end
    
endmodule
