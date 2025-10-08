`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/21 09:29:20
// Design Name: 
// Module Name: ecallUse
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


module ecallUse(
    input clk,
    input rst,
    input confirm,
    input [7:0] numIn,
    input [31:0] inst,
    input [31:0] a7,
    output [31:0] out,
    output reg write = 0,
    output reg stop2 = 0,
    output reg renew = 0
    );
    reg lastConfirm = 1'b0;
    assign out[7:0] = numIn;
    assign out[31:8] = 24'b0;
    always @(posedge clk) begin
        lastConfirm <= confirm;
        if(inst[6:0] == 7'b1110011 && a7 == 32'd1) begin
            renew <= 1'b1;
        end
        else if(inst[6:0] == 7'b1110011 && a7 == 32'd5) begin
            renew <= 1'b0;
            stop2 <= 1'b1;
        end
        else if(confirm == 1'b0 && lastConfirm == 1'b1 && stop2 == 1'b1) begin
            renew <= 1'b0;
            stop2 <= 1'b0;
            if(a7 == 32'd5) write <= 1'b1;
        end
        else begin
            renew <= 1'b0;
            write <= 1'b0;
        end
    end
endmodule
