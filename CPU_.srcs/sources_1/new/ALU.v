module ALU(
    input clk,
    input rst,
    input [15:0] pc,
    input [31:0] inst,
    input [31:0] rs1,
    input [31:0] rs2,
    input [5:0] ALUOp,
    input ALUSrc,
    output reg [31:0] ALUResult = 32'b0,
    output reg [31:0] imm = 32'b0,
    output zero
);  
    assign zero = (inst[6:0] == 7'b1101111 || inst[6:0] == 7'b1100111)? 1'b1: ( ALUResult == 32'b0 ? 1'b1: 1'b0); 
    wire [31:0] par2 = ALUSrc? imm: rs2;
    always @(*) begin
        case (inst[6:0])
            7'b0110011: imm <= 32'b0;
            7'b0010011, 7'b0000011, 7'b1100111: imm <= {{20{inst[31]}},inst[31:20]};
            7'b0100011: imm <= {{20{inst[31]}},inst[31:25], inst[11:7]};
            7'b1100011: imm <= {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            7'b0110111: imm <= {inst[31:12], 12'b0};
            7'b1101111: imm <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default : imm <= 32'b0;
        endcase
    end
     always @(*) begin
        case(ALUOp)
            6'b000000: ALUResult <= rs1 + par2;//add, addi, l, s
            6'b000001: ALUResult <= rs1 << par2;//sll, slli
            6'b000010: ALUResult <= ($signed(rs1) < $signed(par2))? 1'b1: 1'b0;//slt, slti
            6'b000011:  ALUResult <= (rs1 < par2)? 1'b1: 1'b0;//sltu, sltiu
            6'b000100: ALUResult <= rs1 ^ par2;//xor, xori
            6'b000101: ALUResult <= rs1 >> par2;//srl, srli
            6'b000110: ALUResult <= rs1 | par2;//or, ori
            6'b000111: ALUResult <= rs1 & par2;//and, andi
            6'b001000: ALUResult <= rs1 - par2;//sub, beq
            //6'b001001
            6'b001010: ALUResult <= (rs1 - par2 == 32'b0)? 1'b1: 1'b0;
            6'b001011: ALUResult <= ($signed(rs1) >= $signed(par2))? 1'b1: 1'b0;//blt
            6'b001100: ALUResult <= (rs1 >= par2)? 1'b1: 1'b0;
            6'b001101: ALUResult <= pc + 32'd4;
            //6'b001110
            6'b001111: ALUResult <= par2 << 32'd12;
        endcase
    end
endmodule