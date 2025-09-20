module Top(
    input clk,
    input rst,
    input confirm,
    input [7:0] inp,
    input [2:0] select,
    output [7:0] led
    
);
reg [31:0] regs [31:0];
always @(*) begin
    case(select)
        3'b000: regs[22] <= 32'd0;
        3'b001: regs[22] <= 32'd1;
        3'b010: regs[22] <= 32'd2;
        3'b011: regs[22] <= 32'd3;
        3'b100: regs[22] <= 32'd4;
        3'b101: regs[22] <= 32'd5;
        3'b110: regs[22] <= 32'd6;
        3'b111: regs[22] <= 32'd7;
    endcase
end
//wire clk;
//cpu_clk cpuc(
//    .clk_in1(clk_main),
//    .clk_out1(clk)
//);
integer i;
always @(posedge clk) begin
    if (~rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] <= 32'h0;
        end
    end
end
wire [31:0] inst;
wire [15:0] pc;
wire Branch,MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
wire [5:0] ALUOp;
wire [31:0] imm;
wire[31:0] ALUResult;
wire[31:0] MemResult;
wire [4:0] rs1 = inst[19:15], rs2 = inst[24:20];
wire [31:0] rs1v = regs[rs1], rs2v = regs[rs2];
//always @(negedge clk) begin
//    if(RegWrite) begin
//        if(MemtoReg) regs[inst[11:7]] <= MemResult;
//        else regs[inst[11:7]] <= ALUResult;
//    end
//end
Controller cont(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);
reg forward = 1'b0;
reg [5:0] done = 6'b0;
reg [26:0]  count = 27'b0;
always @(negedge clk) begin
    if(~rst) begin
        forward <= 1'b0;
        count <= 27'b0;
        done <= 6'b0;
    end
    else begin
        if(count <= 27'd5) begin
            if(RegWrite && done == 2) begin
                if(MemtoReg) regs[inst[11:7]] <= MemResult;
                else regs[inst[11:7]] <= ALUResult;
                done <= 6'd3;
            end
            else done <= done + 3'b1;
            count <= count + 1;
            forward <= 1'b0;
        end
        else begin
            done <= 6'b0;
            forward <= 1'b1;
            count <= 27'b0;
        end
    end
end
wire zero;
Ifetch ift(
    .clk(clk),
    .rst(rst),
    .Branch(Branch),
    .zero(zero),
    .forward(forward),
    .imm(imm),
    .inst(inst),
    .pc(pc)
);
ALU alu(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .inst(inst),
    .rs1(rs1v),
    .rs2(rs2v),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .ALUResult(ALUResult),
    .imm(imm),
    .zero(zero)
);
DMem dmem(
    .clk(clk),
    .rst(rst),
    .MemWrite(MemWrite),
    .Address(ALUResult),
    .WriteData(regs[inst[24:20]]),
    .MemResult(MemResult)
);
endmodule