`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/22 17:32:48
// Design Name: 
// Module Name: MEM
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


module MEM(
    input clk,
    input reset,
    input [31:0] Address,
    input [31:0] WriteData,
    input mRead,
    input mWrite,
    input MemtoReg,
    input [31:0] Memld,
    output reg [31:0] Memsw = 32'b0,
    input [2:0] MEMop,
    output reg [31:0] ReadData = 32'b0
    );
    reg [31:0] addr=32'd0;
    reg mRead1 = 0 , mWrite1 = 0, MemtoReg1 = 0;
    reg mRead2 = 0 , MemtoReg2 = 0;
    wire [31:0] dout;
    reg [31:0] dout1 = 32'b0, Address1 = 32'b0;
    wire [31:0] dout2;
    
   parameter a_store = 32'h00000000;
    parameter b_store=  32'h00000004;
    parameter Dis_store=32'h00000008;
//    assign writedata = (mRead &&( Address == a_store || Address == b_store))?Meminpu:WriteData;
   // assign Memsw =(mWrite1 && (Address1 == Dis_store))?WriteData:32'b0;//sw t0 Dis_store
    always @(negedge clk) begin
        dout1 <= dout;
        Address1 <= Address;
        mRead1 <= mRead;
        mWrite1 <= mWrite;
        MemtoReg1 <= MemtoReg;
        mRead2 <= mRead1;
        MemtoReg2 <= MemtoReg1;
    end
   DMem data_mem(
     .clk(clk), 
     .rst_n(~reset),
     .MemRead(mRead),
     .MemWrite(mWrite),
     .addr(Address), 
     .din(WriteData),
     .dout(dout)
     );
     
    assign dout2 = (MEMop == 3'b000) ? dout1 :( 
                   (MEMop == 3'b001) ? {{24{dout1[7]}}, dout1[7:0]} :(
                   (MEMop == 3'b010) ? {{16{dout1[15]}}, dout1[15:0]} :(
                   (MEMop == 3'b011) ? {24'b0, dout1[7:0]} :(
                   (MEMop == 3'b100) ? {16'b0, dout1[15:0]} : dout1))));
    //Decide if memory is used
    always @(posedge clk)begin
        if(mWrite1 && (Address1 == Dis_store))begin
            Memsw <= WriteData;
        end 
//        else Memsw <= 32'b0;
    end
    always @(*) begin
        if(MemtoReg2 && mRead2) begin
            if(Address1 == a_store || Address1 == b_store) ReadData <= Memld;//ld t0 a/b_store
            else ReadData <= dout1;
       end else ReadData <= Address1;
    end
    
endmodule
