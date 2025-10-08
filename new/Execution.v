`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/06 10:56:49
// Design Name: 
// Module Name: Execution
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


module Execution(
    input clk,
    input rst,
    input EEforward1,
    input EEforward2,
    input ESEforward1,
    input ESEforward2,
    input MEforward1,
    input MEforward2,
    input [31:0] MEData,
    input [31:0] readData1,
    input [31:0] readData2,
    input [31:0] imm32,
    input ALUSrc,
    input [4:0] ALUOp,
    input [31:0] pc,
    output [31:0] aLUResult,
    output [31:0] ReadData1,
    output [31:0] ReadData2,
    output zero
    );
    reg [31:0] ALUResult = 32'b0, ALUResult1 = 32'b0;
    assign zero = (ALUOp == 5'h10 || ALUOp == 5'h13)? 1'b1 :(ALUResult == 32'b0);
    assign aLUResult = ALUResult;
    assign ReadData1 = (~MEforward1)?((~EEforward1)? (~ESEforward1? readData1: ALUResult1): ALUResult): MEData;
    assign ReadData2 = (~MEforward2)?((~EEforward2)? (~ESEforward2? readData2: ALUResult1): ALUResult): MEData;

    //For signed operation
    wire sign;
    reg [31:0] mask = 32'b0;
    assign sign = ReadData1[31];
    //The operation of ALUSrc
    reg [31:0] addee;
    always @(*) begin
        if(ALUSrc) addee <= imm32;
        else addee<= ReadData2;
    end
    
    //ALU main
    always @(negedge clk) begin
        if(~rst) begin
            ALUResult <= 32'b0;
            ALUResult1 <= 32'b0;
        end
        else begin
        ALUResult1 <= ALUResult;
        case(ALUOp)
            5'h00: ALUResult <= ReadData1 + addee;//add, addi, lw, sw
            5'h01: ALUResult <= ReadData1 - addee;//sub, subi, beq
            5'h02: ALUResult <= ReadData1 ^ addee;//xor, xori
            5'h03: ALUResult <= ReadData1 | addee;//or, ori
            5'h04: ALUResult <= ReadData1 & addee;//and, andi
            5'h05: ALUResult <= ReadData1 << addee;//sll, slli
            5'h06: ALUResult <= ReadData1 >> addee;//srl, srli
            5'h07: begin//sra, srai
                mask = ~((32'b1 << (32 - addee)) - 1);
                ALUResult <= ({32{sign}} & mask) | (ReadData1 >> addee);
            end
            5'h08: begin//slt, slti, bge
                if(ReadData1[31] == 0 && addee[31] == 0) ALUResult <=(ReadData1 < addee)?1:0;
                else if(ReadData1[31] == 0 && addee[31] == 1) ALUResult <= 0;
                else if(ReadData1[31] == 1 && addee[31] == 0) ALUResult <= 1;
                else if(ReadData1[31] == 1 && addee[31] == 1) ALUResult <=(ReadData1 >= addee)?1:0;
            end 
            5'h09: ALUResult <=(ReadData1 < addee)?1:0;//sltu, sltiu, bgeu
            // 5'h0a: ALUResult <= {{24{ReadData1[7]}}, ReadData1[7:0]} + {{24{addee[7]}}, addee[7:0]};//lb
            // 5'h0b: ALUResult <= {{16{ReadData1[15]}}, ReadData1[15:0]} + {{16{addee[15]}}, addee[15:0]};//lh
            5'h0c: ALUResult <= {24'b0, ReadData1[7:0]} + {24'b0, addee[7:0]};//sb
            5'h0d: ALUResult <= {16'b0, ReadData1[15:0]} + {16'b0, addee[15:0]};//sh
            5'h0e: begin//blt
                if(ReadData1[31] == 0 && addee[31] == 0) ALUResult <=(ReadData1 < addee)?0:1;
                else if(ReadData1[31] == 0 && addee[31] == 1) ALUResult <= 1;
                else if(ReadData1[31] == 1 && addee[31] == 0) ALUResult <= 0;
                else if(ReadData1[31] == 1 && addee[31] == 1) ALUResult <=(ReadData1 >= addee)?0:1;
            end 
            5'h0f: ALUResult <=(ReadData1 < addee)?0:1;//bltu
            5'h10: ALUResult <= pc + 4'd4;//jal
            5'h11: ALUResult <= addee;//lui
            5'h12: ALUResult <= pc + addee<<12; //auipc
            5'h13: ALUResult <= ReadData1 + addee;
            // 5'h13: ALUResult <= {{24'b0}, ReadData1[7:0]} + {{24{addee[7]}}, addee[7:0]};//lbu
            // 5'h14: ALUResult <= {{16'b0}, ReadData1[15:0]} + {{16{addee[15]}}, addee[15:0]};//lhu
        endcase
        end
    end
endmodule
