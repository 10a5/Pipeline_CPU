`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/22 17:32:48
// Design Name: 
// Module Name: control_1
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


module control_1(
    input clk,
    input reset,
    input on,
    input switch,
    input [7:0] in,
    input [2:0] mod,
    output reg out_huiwen,
    output out_slt,
    output out_sltu,
    output reg out_CRC,
    output [7:0] select,
    output [7:0] segment1,
    output [7:0] segment2,
    output reg [7:0] out
    );
    reg [39:0] data,data0;
    wire [39:0] data1,data2,hex,hex_u,fdata;
    reg [31:0] addr=32'd0,din,a,b,addr_a,addr_b,addr_fa,addr_fb;
    reg [11:0] fa, fb;
    wire [31:0] dout;
    wire [7:0] CRC_light;
    wire huiwen,branch_state,CRC;
    reg altered,last_btn,state,rev;
    
    reg MemRead, MemWrite;
    c1_1 c1_1(
        .on(on),
        .mod(mod),
        .in(in),
        .huiwen(huiwen),// if the binary is huiwen
        .CRC(CRC),
        .CRC_light(CRC_light),
        .data1(data1),// the sequential order of the binary
        .data2(data2),// the reverse order of the binary
        .hex(hex),// the hexdecimal form of the binary
        .hex_u(hex_u)// the half hexdecimal form of the binary
        );
     
   DMem data_mem(
     .clk(clk), 
     .rst_n(~reset),
     .MemRead(MemRead),
     .MemWrite(MemWrite),
     .addr(addr), 
     .din(din),
     .dout(dout)
     );
     
     branch branches(
           .mod(mod),
           .a(a),
           .b(b),
           .state(branch_state),
           .out_slt(out_slt),
           .out_sltu(out_sltu)
         );
     float_numbers float_numbers(
           .mod(mod),
           .on(on),
           .in(in),
           .fa(fa),
           .fb(fb),
           .data(fdata)
     );
     always @(posedge clk) begin
       altered <= (~last_btn && on);
       last_btn <= on;
       if(!switch) begin
          out_huiwen = 1'b0;
          if(branch_state && altered)
             out[7:0] <= 8'b1111_1111;
             case(mod)
                 3'b000 :if(altered) begin
                     rev=1'b0;
                     MemRead = 1'b0;
                     MemWrite = 1'b0;
                     data <= data1;
                     out <= {data1[35],data1[30],data1[25],data1[20],data1[15],data1[10],data1[5],data1[0]};
                 end
                 3'b001 :if(altered) begin
                     MemRead = 1'b0;
                     MemWrite = 1'b1;
                     addr = addr + 1;
                     addr_a = addr;
                     din[31:0] <= hex[31:0];
                     data[39:0] <= hex[39:0];
                     out[7:0] <= 8'd0;
                     rev=1'b0;
                 end
                 3'b010 :if(altered) begin
                     MemRead = 1'b0;
                     MemWrite = 1'b1;
                     addr = addr + 1;
                     addr_b = addr;
                     din[31:0] <= hex_u[31:0];
                     data[39:0] <= hex_u[39:0];
                     out[7:0] <= 8'd0;
                     rev = 1'b0;
                 end
                 default :begin
                 if(altered) rev = ~rev;
                 if(rev) begin
                 if(state) begin
                     MemRead = 1'b1;
                     MemWrite = 1'b0;
                     addr = addr_a;
                     data[39:20] =  dout[19:0];
                     a[31:0] = dout[31:0];
                     state <= 1'b0;
                     out[7:0] <= 8'd0;
                 end else begin
                     MemRead = 1'b1;
                     MemWrite = 1'b0;
                     addr = addr_b;
                     data[19:0] =  dout[19:0];
                     b[31:0] = dout[31:0];
                     state <= 1'b1;
                     out[7:0] <= 8'd0;
                 end
                 end
                 end
             endcase
       end else begin
           case(mod)
           3'b000 :if(altered) begin
               rev=1'b0;
               MemRead = 1'b0;
               MemWrite = 1'b0;
               data <= data2;
               out_huiwen = 1'b0;
               out <= {data2[35],data2[30],data2[25],data2[20],data2[15],data2[10],data2[5],data2[0]};
           end
           3'b001 :if(altered) begin//huiwen
               rev=1'b0;
               data <= data1;
               out_huiwen = huiwen;
               out <= {data1[35],data1[30],data1[25],data1[20],data1[15],data1[10],data1[5],data1[0]};
               out_CRC <= 1'b0;
           end
           3'b010 :begin
           if(altered) begin
                MemRead = 1'b0;
                MemWrite = 1'b1;
                addr = addr + 1;
                addr_fb = addr_fa;
                addr_fa = addr;
                din <= {20'b0,in[7:0], 4'b0000};
                data <= fdata;
           end
              out <= 8'b0;
              out_CRC <= 1'b0;
              out_huiwen = 1'b0;
           end
           3'b011 :begin
              if(altered) 
                rev = ~rev;
              if(rev) begin
              if(state) begin
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    addr = addr_fa;
                    fa[11:0] = dout[11:0];
                    state <= 1'b0;
              end else begin
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    addr = addr_fb;
                    fb[11:0] = dout[11:0];
                    state <= 1'b1;
              end
              end else data<=40'b0;
              data <= fdata;
              out <= 8'b0;
              out_CRC <= 1'b0;
           end
           3'b100:if(altered) begin
              rev = 1'b0;
              out <= CRC_light;
              data <= {4'b0, CRC_light[7], 4'b0, CRC_light[6], 4'b0, CRC_light[5], 4'b0, CRC_light[4], 4'b0, CRC_light[3], 4'b0, CRC_light[2], 4'b0, CRC_light[1], 4'b0, CRC_light[0]}; 
              out_CRC <= 1'b0;
           end
           3'b101:if(altered) begin
              data <= data1;
              rev=1'b0;
              out <= 8'b0;
              out_CRC <= CRC;
           end
           default :if(altered) begin
              out <= 8'b0;
              out_CRC <= 1'b0;
           end
           endcase
       end
    end
      
    displayer main_displayer(
            .clk(clk),
            .rst_n(~reset),
            .mod(mod),
            .switch(switch),
            .rev(rev),
            .data(data),
            .select(select),
            .segment1(segment1),
            .segment2(segment2)
        );
endmodule
