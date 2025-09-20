`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 21:01:43
// Design Name: 
// Module Name: Ifetch
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


module Ifetch(
    input clk,
    input rst,
    input forward,
    input Branch,
    input zero,
    input [31:0] imm,
    output [31:0] inst,
    output reg [15:0] pc = 16'b0
    );
    Instructions ins(
        .clka(clk),
        .addra(pc[15:2]),
        .douta(inst)
    );
    always @(negedge clk) begin
        if(~rst) begin
            pc <= 32'b0;
        end
        else begin
            if(forward == 1'b1) begin
                if(Branch && zero) begin
                    pc <= pc + imm;
                end
                else begin
                    pc <= pc + 32'h4;
                end
            end
        end
    end
endmodule
