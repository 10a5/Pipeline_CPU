`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 21:49:32
// Design Name: 
// Module Name: Top
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


module Top(
    input clk_sys,
    input rst,
    input stop1,
    input rx,
    input insIn,
    input clkMode,
    input confirm,
    input [7:0] inpu,
    input [4:0] inpu2,
    
    output [7:0] select,
    output [7:0] segment1,
    output [7:0] segment2,
    output reg[7:0] out = 8'b0
    );
    //Use this when running simulations
    //wire clk = clk_sys;

    //Use this when running on the board
    reg clk = 0;
    reg [26:0] count;
    always @(posedge clk_sys) begin
        if(clkMode == 0) begin
            clk <= ~clk;
        end
        else begin
            count <= count + 1;
            if(count == 27'd10000000) begin
                clk <= ~clk;
                count <= 27'b0;
            end
        end
    end
    
    //Data from Control
    wire RegWrite, ALUSrc, Branch, MemRead, MemtoReg, MemWrite;
    wire [2:0] MEMop;
    reg regWrite = 0 , aLUSrc = 0 , branch = 0 , memRead = 0 , memtoReg = 0 , memWrite = 0;
    wire [4:0] ALUOp;
    reg [4:0] aLUOp = 5'b0;
    wire EEforward1, EEforward2, ESEforward1, ESEforward2, MEforward1, MEforward2;
    
    //Data for Registers
    wire [31:0] inst;
    wire [31:0] imm32;
    wire [31:0] rs1Data, rs2Data;
    reg [31:0] inst_in = 32'b0, imm = 32'b0, immPC1 = 32'b0, immPC2 = 32'b0, immPC3 = 32'b0, r1Data = 32'b0, r2Data = 32'b0, r2Data2 = 32'b0;
    wire [31:0] R1Data, R2Data;
    wire [31:0] regOut;
    
    
    //Data for Execution
    wire [31:0] pc;
    wire [31:0] ALUResult;
    wire zero;
    reg Zero = 0, zero1 = 0;
    
    //Data for ImmWrite
    wire [31:0] writeData;
    reg [31:0] wData = 32'b0;

    //Data for Data Memory
    reg [31:0] Address = 32'b0;
    wire [31:0] DatatoMem = immPC1;
    wire rev;
    wire[39:0] dataDisplay;
    reg revVal = 0;
    reg [39:0] DataDisplay = 40'b0;

    
    //The signal to stop the program for ecall
    wire stop2;
    wire stop = stop1 || stop2;
    wire ecallWrite, renew;
    wire [31:0] ecallData ;
    reg [31:0] DatatoDisplay = 32'b0;
    wire [31:0] a7;

    wire [31:0] debug;
    
    reg [31:0]Memld = 32'b0;
    wire[31:0]Memsw;
    
    wire [31:0]regDis;
    reg [31:0]regin = 32'b0;
    reg[31:0]regmod = 32'b0;
    reg [3:0]mode = 4'b0;
    wire yes;   
//    reg [7:0]out;
//    reg [7:0]select;
//    reg [7:0]segment1;
//    reg [7:0]segment2;
    assign yes = inpu2[4];
    // reg [31:0]regmod;

    //The ecall module
    ecallUse ecall(
        .clk(clk),
        .rst(rst),
        .confirm(confirm),
        .numIn(inpu),
        .inst(inst),
        .a7(a7),
        .out(ecallData),
        .write(ecallWrite),
        .stop2(stop2),
        .renew(renew)
    );
    always @(posedge clk) begin
        if(~rst) begin
            DatatoDisplay <= 32'b0;
        end
        else if(renew) begin
            DatatoDisplay <= regOut;
        end
        else begin
            DatatoDisplay <= DatatoDisplay;
        end
    end

    //The program goes forward
    always @(*) begin
        if(~rst) begin
            inst_in <= 32'b0;
            regWrite <= 0;
            aLUSrc <= 0;
            branch <= 0;
            memRead <= 0;
            memtoReg <= 0;
            memWrite <= 0;
            aLUOp <= 5'b0;
            r1Data <= 32'b0;
            r2Data <= 32'b0;
            revVal <= 0;
            DataDisplay <= 40'b0;
            Address <= 32'b0;
            wData <= 32'b0;
        end
        else begin
            inst_in <= inst;
            regWrite <= RegWrite;
            aLUSrc <= ALUSrc;
            branch <= Branch;
            memRead <= MemRead;
            memtoReg <= MemtoReg;
            memWrite <= MemWrite;
            aLUOp <= ALUOp;
            r1Data <= rs1Data;
            r2Data <= rs2Data;
            Address <= ALUResult;
            wData <= writeData;
            revVal <= rev;
            DataDisplay <= {1'b0, {DatatoDisplay[31:28]}, 1'b0, {DatatoDisplay[27:24]}, 1'b0, {DatatoDisplay[23:20]}, 1'b0, {DatatoDisplay[19:16]}, 1'b0, {DatatoDisplay[15:12]}, 1'b0, {DatatoDisplay[11:8]}, 1'b0, {DatatoDisplay[7:4]}, 1'b0, {DatatoDisplay[3:0]}};
        end
    end
    
    always @(*)begin
                if(~rst||~yes)begin
                    regin <= 31'b0;
                    out <= 8'b0;
                 //   DataDisplay  <= 40'b0;
                end else begin
                    mode = inpu2[3:0];
                    case (mode)
                       4'b0000: begin
                        regmod <= 32'b0;
                        Memld <= {24'b0,inpu};
                        out <= inpu;
                       // DataDisplay  <= 40'b0;
                       end
                       4'b0001:begin
                        regmod <= 8'h00000001;
                        Memld <= {{24{inpu[7]}},inpu};
                        out <= 8'b0;
                        //DataDisplay <= {1'b0, {Memsw[31:28]}, 1'b0, {Memsw[27:24]}, 1'b0, {Memsw[23:20]}, 1'b0, {Memsw[19:16]}, 1'b0, {Memsw[15:12]}, 1'b0, {Memsw[11:8]}, 1'b0, {Memsw[7:4]}, 1'b0, {Memsw[3:0]}};
                        end
                        4'b0010:begin
                         regmod <= 8'h00000002;
                         Memld <= {24'b0,inpu};
                          out <= 8'b0;
                       //  DataDisplay <= {1'b0, {Memsw[31:28]}, 1'b0, {Memsw[27:24]}, 1'b0, {Memsw[23:20]}, 1'b0, {Memsw[19:16]}, 1'b0, {Memsw[15:12]}, 1'b0, {Memsw[11:8]}, 1'b0, {Memsw[7:4]}, 1'b0, {Memsw[3:0]}};
                         end
                        4'b0011:begin
                          regmod <= 32'h00000003; 
                          Memld <= 32'b0;
                          out <= (Memsw == 32'b1)?8'b11111111:8'b0;
                       //   DataDisplay  <= 40'b0;
                        end
                       4'b0100:begin
                        regmod <= 32'h00000004; 
                         Memld <= 32'b0;
                        out <= (Memsw == 32'b1)?8'b11111111:8'b0;
                        //DataDisplay  <= 40'b0;
                         end
                       4'b0101:begin
                        regmod <= 32'h00000005; 
                        Memld <= 32'b0;
                        out <= (Memsw == 32'b1)?8'b11111111:8'b0;
                       // DataDisplay  <= 40'b0;
                         end
                       4'b0110:begin
                        regmod <= 32'h0000006; 
                        Memld = 32'b0;
                        out <= Memsw[7:0];
                      //  DataDisplay  <= 40'b0;
                       end   
                       4'b0111:begin
                        regmod <= 32'h00000007; 
                        Memld = 32'b0;
                        out <= Memsw[7:0];
                      //  DataDisplay  <= 40'b0;
                       end         
                       4'b1000:begin
                        regmod <= 32'h00000008;
                        Memld <={24'b0,inpu};
                        out <= Memsw[7:0];
                       // DataDisplay  <= 40'b0;
                       end
                      
                      4'b1001:begin
                        regmod <= 32'h00000009;
                        Memld <={24'b0,inpu};
                        out <= Memsw[7:0];
                        //DataDisplay  <= 40'b0;
                       end           
                       4'b1010:begin
                          regmod <= 32'h0000000a;
                          Memld <= {24'b0,inpu};
                          out <=Memsw[7:0];
                       end  
                       4'b1011:begin
                          regmod <= 32'h0000000b;
                          Memld <= {24'b0,inpu};
                          out <=Memsw[7:0];
                       end
                       4'b1100:begin
                          regmod <= 32'h0000000c;
                          Memld <= {24'b0,inpu};
                          out <=Memsw[7:0];
                       end                               
                       4'b1101:begin
                          regmod <= 32'h0000000d;
                          Memld <= {24'b0,inpu};
                          out <=Memsw[7:0];
                       end        
                        4'b1110:begin
                          regmod <= 32'h0000000e;
                          Memld <= {24'b0,inpu};
                          out <=8'b0;
                       end       
                        4'b1111:begin
                         regmod <= 32'h0000000f;
                         Memld <= {24'b0,inpu};
                         out <=8'b0;
                      end                                                                               
                       default:begin
                           regmod <= 32'h00000000;
                           Memld <= 32'b0;
                           out <= 8'b0;
                        //   DataDisplay  <= 40'b0;
                       end
                   endcase
                
                    end
            end

    always @(posedge clk) begin
        if(~rst) begin
            imm <= 32'b0;
            immPC1 <= 32'b0;
            immPC2 <= 32'b0;
            Zero <= 32'b0;
            zero1 <= 32'b0;
        end
        else begin
            imm <= imm32;
            immPC1 <= imm;
            immPC2 <= immPC1;
            Zero <= zero1;
            zero1 <= zero;
        end
    end
    always @(negedge clk) begin
        if(~rst) begin
            r2Data2 <= 32'b0;
        end
        else begin
            r2Data2 <= R2Data;
        end
    end
    
    //The connection with Control
    Control ctrl(
    .clk(clk),
    .rst(rst),
    .inst(inst_in),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .Branch(Branch),  
    .ALUOp(ALUOp),
    .MEMop2(MEMop),
    .EEforward1(EEforward1),
    .EEforward2(EEforward2),
    .ESEforward1(ESEforward1),
    .ESEforward2(ESEforward2),
    .MEforward1(MEforward1),
    .MEforward2(MEforward2)
    );

    //The connection with IFetch
    IFetch ifet(
    .clk_sys(clk_sys),
    .clk(clk),
    .rst(rst),
    .stop(stop),
    .insIn(insIn),
    .rx(rx),
    .imm32(immPC2),
    .branch(branch),
    .zero(Zero),
    .inst(inst),
    .pc(pc)
//    .debug(debug)
    );
    
    //The connection with Registers
    //The operations include the ID and the WB
    Registers regi(
    .clk(clk),
    .rst(rst),
    .regWrite(regWrite),
    .inst(inst_in), 
    .writeData(wData),
    .ecallData(ecallData),
    .ecallWrite(ecallWrite),
    .regmod(regmod),
    .imm32(imm32),
    .rs1Data(rs1Data),
    .rs2Data(rs2Data),
    .regOut(regOut),
    .a7(a7)
    );
    
    //The connection with Execution part including ALU
    Execution exec(
    .clk(clk),
    .rst(rst),
    .EEforward1(EEforward1),
    .EEforward2(EEforward2),
    .ESEforward1(ESEforward1),
    .ESEforward2(ESEforward2),
    .MEforward1(MEforward1),
    .MEforward2(MEforward2),
    .MEData(wData),
    .readData1(r1Data),
    .readData2(r2Data),
    .imm32(imm),
    .ALUSrc(aLUSrc),
    .ALUOp(aLUOp),
    .pc(pc),
    .aLUResult(ALUResult),
    .ReadData1(R1Data),
    .ReadData2(R2Data),
    .zero(zero)
    );
    
    //The Data Memory, including the test cases
    MEM mem(
    .clk(clk),
    .reset(rst),
    .Address(Address),
    .WriteData(r2Data2),
    .mRead(memRead),
    .mWrite(memWrite),
    .MemtoReg(memtoReg),
    .MEMop(MEMop),
    .Memld(Memld),
    .Memsw(Memsw),
    .ReadData(writeData)
    );

    //Displayer module
    displayer main_displayer(
        .clk(clk_sys),
        .rst_n(rst),
        .data(DataDisplay),
        .select(select),
        .segment1(segment1),
        .segment2(segment2)
    );
    
endmodule
