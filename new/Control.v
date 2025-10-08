`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 22:30:31
// Design Name: 
// Module Name: Control
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


module Control(
    input clk,
    input rst,
    input [31:0] inst,
    output reg RegWrite = 0,
    output reg ALUSrc,
    output reg MemRead = 0,
    output reg MemWrite = 0,
    output reg MemtoReg = 0,
    output reg Branch = 0,
    output reg [4:0] ALUOp = 0,
    output reg EEforward1 = 0,
    output reg EEforward2 = 0,
    output reg ESEforward1 = 0,
    output reg ESEforward2 = 0,
    output reg MEforward1 = 0,
    output reg MEforward2 = 0,
    output reg [2:0] MEMop2 = 3'b0
    );
    reg [2:0] MEMop = 3'b0, MEMop1 = 3'b0;
    reg EEf1 = 0, EEf2 = 0, ESEf1 = 0, ESEf2 = 0, M2E = 0, M2E1 = 0, MEf1 = 0, MEf2 = 0;
    reg regWrite, aLUSrc, branch, memRead, memtoReg, memWrite;
    reg [4:0] aLUOp = 0, aLUOp1 = 0;
    reg branch1, memWrite1, memRead1, memtoReg1, regWrite1, aLUSrc1, regWrite2;
    reg branch2, branch3;
    reg [4:0] rd, rd1;
    reg noRegchange1 = 0, noRegchange2 = 0;

    //Control signals going forward
    always @(posedge clk) begin
            ALUSrc <= aLUSrc1;
            MemRead <= memRead1;
            MemWrite <= memWrite1;
            MemtoReg <= memtoReg1;
            Branch <= branch3;
            branch3 <= branch2;
            branch2 <= branch1;
            RegWrite <= regWrite2;
            aLUSrc1 <= aLUSrc;
            regWrite1 <= regWrite;
            regWrite2 <= regWrite1;
            memRead1 <= memRead; 
            memWrite1 <= memWrite;
            memtoReg1 <= memtoReg;
            branch1 <= branch;
            ALUOp <= aLUOp1;
            aLUOp1 <= aLUOp;
            MEMop2 <= MEMop1;
            MEMop1 <= MEMop;
            // Forwarding forward signals
            ESEforward1 <= ESEf1;
            ESEforward2 <= ESEf2;
            EEforward1 <= EEf1;
            EEforward2 <= EEf2;
            MEforward1 <= MEf1;
            MEforward2 <= MEf2;
            if(rd == inst[19:15] && inst[6:0] != 7'b1101111 && ~noRegchange1 && rd != 5'b0) begin
                EEf1 <= 1;
            end
            else begin
                EEf1 <= 0;
            end
            if(rd == inst[24:20] && (inst[6:0] == 7'b0110011 || inst[6:0] == 7'b0100011 || inst[6:0] == 7'b1100011) && ~noRegchange1 && rd != 5'b0) begin
                EEf2 <= 1;
            end 
            else begin
                EEf2 <= 0;
            end
            if(~M2E1 && (rd1 == inst[19:15] && inst[6:0] != 7'b1101111) && ~noRegchange2 && rd1 != 5'b0) begin
                ESEf1 <= 1;
            end
            else begin
                ESEf1 <= 0;
            end
            if(~M2E1 && (rd1 == inst[24:20] && (inst[6:0] == 7'b0110011 || inst[6:0] == 7'b0100011 || inst[6:0] == 7'b1100011)) && ~noRegchange2 && rd1 != 5'b0) begin
                ESEf2 <= 1;
            end 
            else begin
                ESEf2 <= 0;
            end
            if(M2E1 && (rd1 == inst[19:15] && inst[6:0] != 7'b1101111) && ~noRegchange2 && rd1 != 5'b0) begin
                MEf1 <= 1;
            end
            else begin
                MEf1 <= 0;
            end
            if(M2E1 && (rd1 == inst[24:20] && (inst[6:0] == 7'b0110011 || inst[6:0] == 7'b0100011 || inst[6:0] == 7'b1100011)) && ~noRegchange2 && rd1 != 5'b0) begin
                MEf2 <= 1;
            end 
            else begin
                MEf2 <= 0;
            end
            if(inst[6:0] == 7'b0000011) begin
                M2E <= 1;
            end
            else begin
                M2E <= 0;
            end
            M2E1 <= M2E;
            rd <= (inst[6:0] == 7'b0100011 || inst[6:0] == 7'b1100011)? 5'b0: inst[11:7];
            rd1 <= rd;
            noRegchange1 <= (inst[6:0] == 7'b1100011 || inst[6:0] == 7'b1101111)? 1'b1: 1'b0;
            noRegchange2 <= noRegchange1;
        end
    // Control signals
    always @(*) begin
        if (~rst) begin
            regWrite <= 0;
            aLUSrc <= 0;
            memRead <= 0;
            memWrite <= 0;
            memtoReg <= 0;
            branch <= 0;
            aLUOp <= 5'b00000;
        end else begin
            case(inst[6:0])
                7'b0110011: begin // R-type
                    regWrite <= 1;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    if(inst[31:25] == 7'b0) begin
                        case(inst[14:12])
                            3'b000: aLUOp <= 5'b00000; // add
                            3'b001: aLUOp <= 5'b00101; // sll
                            3'b010: aLUOp <= 5'b01000; // slt
                            3'b011: aLUOp <= 5'b01001; // sltu
                            3'b100: aLUOp <= 5'b00010; // xor
                            3'b101: aLUOp <= 5'b00110; // srl
                            3'b110: aLUOp <= 5'b00011; // or
                            3'b111: aLUOp <= 5'b00100; // and
                            default: aLUOp <= 5'b00000;
                        endcase
                    end 
                    else if(inst[31:25] == 7'b0100000) begin
                        case(inst[14:12])
                            3'b000: aLUOp <= 5'b00001; // sub
                            3'b101: aLUOp <= 5'b00111; // sra
                            default: aLUOp <= 5'b00000;
                        endcase
                    end
                end
                7'b0010011: begin // I-type immediate
                    regWrite <= 1;
                    aLUSrc <= 1;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    case(inst[14:12])
                        3'b000: aLUOp <= 5'b00000; // addi
                        3'b001: aLUOp <= 5'b00101; // slli
                        3'b010: aLUOp <= 5'b01000; // slti
                        3'b011: aLUOp <= 5'b01001; // sltiu
                        3'b100: aLUOp <= 5'b00010; // xori
                        3'b101: aLUOp <= 5'b00110; // srli
                        3'b110: aLUOp <= 5'b00011; // ori
                        3'b111: aLUOp <= 5'b00100; // andi
                        default: aLUOp <= 5'b00000;
                    endcase
                end
                7'b0000011: begin // I-type load
                    regWrite <= 1;
                    aLUSrc <= 1;
                    memRead <= 1;
                    memWrite <= 0;
                    memtoReg <= 1;
                    branch <= 0;
                    case(inst[14:12])
                        3'b000: MEMop <= 3'b01; // lb
                        3'b001: MEMop <= 3'b10; // lh
                        3'b010: MEMop <= 3'b00; // lw
                        3'b100: MEMop <= 3'b11; // lbu
                        3'b101: MEMop <= 3'b100; // lhu
                        default: MEMop <= 3'b00;
                    endcase
                    aLUOp <= 5'b00000; // lw
                end
                7'b0100011: begin // S-type store
                    regWrite <= 0;
                    aLUSrc <= 1;
                    memRead <= 0;
                    memWrite <= 1;
                    memtoReg <= 0;
                    branch <= 0;
                    aLUOp <= 5'b00000; // add
                end
                7'b1100011: begin // B-type branch
                    regWrite <= 0;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 1;
                    MEMop <= 2'b00;
                    case(inst[14:12])
                        3'b000: aLUOp <= 5'b00001; // beq
                        3'b001: aLUOp <= 5'b00001; // bne
                        3'b100: aLUOp <= 5'b01110; // blt
                        3'b101: aLUOp <= 5'b01000; // bge
                        3'b110: aLUOp <= 5'b01111; // bltu
                        3'b111: aLUOp <= 5'b01001; // bgeu
                        default: aLUOp <= 5'b00000;
                    endcase
                end
                7'b1101111: begin // J-type jal
                    regWrite <= 1;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 1;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b10000; // jal
                end
                7'b1100111: begin // I-type jalr
                    regWrite <= 1;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 1;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b10011;
                end
                7'b0010111: begin // auipc
                    regWrite <= 1;
                    aLUSrc <= 1;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b10010; 
                end
                7'b0110111: begin // lui
                    regWrite <= 1;
                    aLUSrc <= 1;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b10001; 
                end
                7'b1110011: begin // ecall
                    regWrite <= 0;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b00000; 
                end
                default: begin
                    regWrite <= 0;
                    aLUSrc <= 0;
                    memRead <= 0;
                    memWrite <= 0;
                    memtoReg <= 0;
                    branch <= 0;
                    MEMop <= 2'b00;
                    aLUOp <= 5'b00000;
                end
            endcase
        end
    end
endmodule
