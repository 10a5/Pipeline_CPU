`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 20:26:22
// Design Name: 
// Module Name: displayer
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

module displayer(
    input clk,  
    input rst_n,
    input [39:0] data,
    output reg [7:0] select,
    output reg [7:0] segment1,
    output reg [7:0] segment2
    );
    reg clk_rev;
    reg [4:0] number;
    reg [7:0] segment;
    reg [31:0] cnt;
    reg [2:0] selection;
    parameter period = 100000;
    always @(posedge clk) begin
        if(!rst_n) begin
            cnt<=0;
            clk_rev<=0;
        end
        else begin 
            if(cnt == (period>>1) - 1) begin
                clk_rev = ~clk_rev;
                cnt<=0;
            end
            else
                cnt<=cnt+1;
        end
    end
    always @(posedge clk_rev) begin
        if(~rst_n)
            selection<=0;
        else 
            if(selection==3'd7)
                selection <=0;
            else
                selection <= selection + 1;
    end
    always @(selection) begin
        case(selection)
            3'b000 : begin
                select = 8'h01;
                number = data[4:0];
            end
            3'b001 : begin
                select = 8'h02;
                number = data[9:5];
            end
            3'b010 : begin
                select = 8'h04;
                number = data[14:10];
            end
            3'b011 : begin
                select = 8'h08;
                number = data[19:15];
            end
            3'b100 : begin
                select = 8'h10;
                number = data[24:20];
            end
            3'b101 : begin
                select = 8'h20;
                number = data[29:25];
            end
            3'b110 : begin
                select = 8'h40;
                number = data[34:30];
            end
            3'b111 : begin
                select = 8'h80;
                number = data[39:35];
            end
        endcase
        case(number[3:0])
            4'b0000: begin
                segment = 8'b11111100;
            end
            4'b0001:
            segment = 8'b01100000;
            4'b0010: segment = 8'b11011010;
            4'b0011: segment = 8'b11110010;
            4'b0100: segment = 8'b01100110;
            4'b0101: segment = 8'b10110110;
            4'b0110: segment = 8'b10111110;
            4'b0111: segment = 8'b11100000;
            4'b1000: segment = 8'b11111110;
            4'b1001: segment = 8'b11110110;
            4'b1010: segment = 8'b11101110;//A
            4'b1011: segment = 8'b00111110;//b
            4'b1100: segment = 8'b10011100;//C
            4'b1101: segment = 8'b01111010;//d
            4'b1110: segment = 8'b10011110;//E
            4'b1111: segment = 8'b10001110;//F
        endcase
        segment[0]= number[4];
        segment1 = segment;
        segment2 = segment;
    end
endmodule
