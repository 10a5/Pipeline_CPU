`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 23:48:53
// Design Name: 
// Module Name: Top_tb
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


module Top_tb();
reg clk;
reg rst;
Top top(
    .clk(clk),
    .rst(rst)
);
always begin
#100
clk = ~clk;
end
initial begin
    clk = 0;
    rst = 1;
    #1000
    rst = 0;
    #1000
    rst = 1;
    #300000
    $finish;
end
endmodule
