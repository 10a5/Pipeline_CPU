`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 13:43:48
// Design Name: 
// Module Name: IFetch
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


module IFetch(
    input clk_sys,
    input clk,
    input rst,
    input stop,
    input rx,
    input insIn,
    input [31:0] imm32,
    input branch,
    input zero,
    output reg [31:0] inst = 32'b0,
    output reg [31:0] pc = 32'b0
//    output [31:0] debug
    );
    reg [4:0] NOP = 5'b0, count = 5'b0;
    reg possiblyNOP = 1'b0;
    reg [5:0] rd = 32'b0, rd1 = 32'b0;
    wire tag = (inst[6:0] == 7'b1100011 || inst[6:0] == 7'b1101111 || inst[6:0] == 7'b1100111)? 1'b1 : 1'b0;
    // wire tag = (inst[6:0] != 7'b0000000)? 1'b1 : 1'b0;
    wire writeIns;
    wire [31:0] instGet;
    reg [3:0] wea = 4'b0;
    reg [13:0] writeLocation = 14'b0;
    wire [13:0] pcAddr = (insIn)? writeLocation : pc[15:2];
//    assign debug = instWrite;
    wire [31:0] instWrite;
    prgrom urom( .clka(clk_sys), .addra(pcAddr), .dina(instWrite), .douta(instGet), .wea(wea));
    instructionInput uinput(
        .clk(clk_sys),
        .rst(rst),
        .rx(rx),
        .inst(instWrite),
        .writeIns(writeIns)
    );
    wire stall = (possiblyNOP && (
        (instGet[6:0] == 7'b0110011 && (instGet[19:15] == rd || instGet[24:20] == rd))
        || (instGet[6:0] == 7'b0010011 && (instGet[19:15] == rd))
        || (instGet[6:0] == 7'b0100011 && (instGet[19:15] == rd))
        || (instGet[6:0] == 7'b0000011 && (instGet[19:15] == rd || instGet[24:20] == rd))
        || (instGet[6:0] == 7'b0100011 && (instGet[19:15] == rd))
        || (instGet[6:0] == 7'b1100011 && (instGet[19:15] == rd || instGet[24:20] == rd))
        )) || stop || inst[6:0] == 7'b1110011;
    always @(negedge clk_sys) begin
        if(!rst) begin
            writeLocation <= 14'b0;
        end
        else begin
            if(insIn) begin
                wea <= 4'b1111;
                if(writeIns) begin
                    writeLocation <= writeLocation + 14'b1;
                end
            end
            else begin
                wea <= 4'b0;
            end
        end
    end
    //A special tag for jalr
    reg jalrTag = 1'b0, jalrTag1 = 1'b0, jalrTag2 = 1'b0;
    always @(negedge clk) begin
        if(~rst) begin
            jalrTag <= 1'b0;
            jalrTag1 <= 1'b0;
            jalrTag2 <= 1'b0;
        end 
        else begin
            if(inst[6:0] == 7'b1100111) begin
                jalrTag <= 1'b1;
            end
            else jalrTag <= 1'b0;
            jalrTag1 <= jalrTag;
            jalrTag2 <= jalrTag1;
        end
    end
    always @(negedge clk) begin
        if(!rst) begin
            pc <= 32'b0;
            NOP <= 5'b0;
            inst <= 32'b0;
            count <= 5'b0;
            // writeLocation <= 14'b0;
        end
        else begin
            // debug <= instWrite;
            // if(insIn) begin
            //     wea <= 4'b1111;
            //     if(writeIns) begin
            //         writeLocation <= writeLocation + 14'b1;
            //     end
            // end
            if(stall) begin
                inst <= 32'b0;
                possiblyNOP <= 1'b0;
            end
            else if(tag == 1) begin
                NOP <= 5'd2;
                inst <= 32'b0;
                possiblyNOP <= 1'b0;
            end
            else if(NOP > 0) begin
                inst <= 32'b0;  
                NOP <= NOP - 1;
                possiblyNOP <= 1'b0;
            end
            else if(zero && branch) begin
                count <= 0;
                if(jalrTag2 == 1'b1) pc <= imm32;
                else pc <= pc + imm32 - 32'd4;
                // inst <= instGet;
                if(instGet[6:0] == 7'b0000011) begin
                    possiblyNOP <= 1'b1;
                    rd <= instGet[11:7];
                end
                else possiblyNOP <= 1'b0;
            end
            else if(instGet[6:0] == 7'b1110011 && count <= 3) begin
                inst <= 32'b0;
                count <= count + 1; 
            end
            else begin
                count <= 0;
                pc <= pc + 32'd4;
                inst <= instGet;
                if(instGet[6:0] == 7'b0000011) begin
                    possiblyNOP <= 1'b1;
                    rd <= instGet[11:7];
                end
                else possiblyNOP <= 1'b0;
            end
            rd1 <= rd;
        end
    end
endmodule
