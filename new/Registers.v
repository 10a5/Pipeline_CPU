`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 15:51:30
// Design Name: 
// Module Name: Decoder
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


module Registers(
    input clk,
    input rst,
    input regWrite,
    input [31:0] inst,
    input [31:0] writeData,
    input [31:0] ecallData,
    input ecallWrite,
    input [31:0] regmod,
    output reg [31:0] imm32 = 32'b0,
    output reg [31:0] rs1Data = 32'b0,
    output reg [31:0] rs2Data = 32'b0,
    output [31:0] regOut,
    output [31:0] a7
    );
    reg [31:0] regs [31:0];
    wire [4:0] rs1, rs2;
    reg [4:0] rd = 5'b0, rd1 = 5'b0, rd2 = 5'b0;
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    always @(negedge clk) begin
        if(~rst) begin
            rd <= 5'b0;
            rd1 <= 5'b0;
            rd2 <= 5'b0;
        end else begin
            rd <= inst[11:7];
            rd1 <= rd;
            rd2 <= rd1;
        end
    end
    wire [6:0] opcode;
    wire [31:0] imm;
    assign opcode = inst[6:0]; 
    assign regOut = regs[10];
    assign a7 = regs[17];
    
    //Reform the imm32
    assign imm = 
        (opcode == 7'b0110011)? 32'b0:  
        (opcode == 7'b0010011 || opcode == 7'b0000011 ||  opcode == 7'b1110011)? {{20{inst[31]}}, inst[31:20]}:
        (opcode == 7'b1100111)? {{20{inst[31]}}, inst[31:20]} + regs[rs1]:
        (opcode == 7'b0100011)? {{20{inst[31]}}, inst[31:25], inst[11:7]}:
        (opcode == 7'b1100011)? {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}:
        (opcode == 7'b0110111 || opcode == 7'b0010111)? {inst[31:12], {12'b0}}:
        (opcode == 7'b1101111)? {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}:
        32'b0;
    always @(posedge clk) begin
        if (~rst) begin
            imm32 <= 32'b0;
        end else begin
            imm32 <= imm;
        end
    end
    
        always @(*)begin
        if(~rst)begin
            
        end else begin
    //        regs[30] <= regIn;
//            regs[29] <= regmod;
        end
    end
    
    
    integer i;
    always @(posedge clk) begin
        if (~rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'h0;
            end
        end else begin
            regs[29] <= regmod;
             if (regWrite) begin
                if (rd2 != 5'b0) regs[rd2] <= writeData;
            end
            else if(ecallWrite) begin
                regs[10] <= ecallData;
            end
        end
    end
    always @(negedge clk) begin
        if (~rst) begin
            rs1Data <= 32'b0;
            rs2Data <= 32'b0;
        end else begin
            rs1Data <= regs[rs1];
            rs2Data <= regs[rs2];
        end
    end
endmodule