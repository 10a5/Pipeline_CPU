module Controller(
    input clk,
    input rst,
    input [31:0] inst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [5:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite
);
    reg [11:0] temp;
    assign Branch = temp[11];
    assign MemRead = temp[10];
    assign MemtoReg = temp[9];
    assign ALUOp = temp[8:3];
    assign MemWrite = temp[2];
    assign ALUSrc = temp[1];
    assign RegWrite = temp[0];
    always @(*) begin
        if(~rst) begin
            temp <= 12'b0;
        end
        else begin
            case(inst[6:0]) 
                7'b0000000: temp <= 12'b000000000000;
                7'b0110011: begin
                    case(inst[31:25]) 
                        7'b0000000: begin
                            case(inst[14:12]) 
                                3'b000: temp <= 12'b000000000001;//add000000
                                3'b001: temp <= 12'b000000001001;//sll000001
                                3'b010: temp <= 12'b000000010001;//slt000010
                                3'b011: temp <= 12'b000000011001;//sltu000011
                                3'b100: temp <= 12'b000000100001;//xor000100
                                3'b101: temp <= 12'b000000101001;//srl000101
                                3'b110: temp <= 12'b000000110001;//or000110
                                3'b111: temp <= 12'b000000111001;//and000111
                            endcase
                        end
                        7'b0100000: begin
                            temp <= 12'b000001000001;//sub001000
                        end
                    endcase
                end
                7'b0010011: begin
                    case(inst[14:12]) 
                        3'b000: temp <= 12'b000000000011;//addi000000
                        3'b001: temp <= 12'b000000001011;//slli000001
                        3'b010: temp <= 12'b000000010011;//slti000010
                        3'b011: temp <= 12'b000000011011;//sltui000011
                        3'b100: temp <= 12'b000000100011;//xori000100
                        3'b101: temp <= 12'b000000101011;//srli000101
                        3'b110: temp <= 12'b000000110011;//ori000110
                        3'b111: temp <= 12'b000000111011;//andi000111
                    endcase
                end
                7'b0000011: begin
                    temp <= 12'b011000000011;//l_shared000000
                end
                7'b0100011: begin
                    temp <= 12'b000000000110;//s_shared000000
                end
                7'b1100011: begin
                    case(inst[14:12]) 
                        3'b000: temp <= 12'b100001000000;//beq001000
                        3'b001: temp <= 12'b100001010000;//bne001010
                        3'b100: temp <= 12'b100001011000;//blt001011
                        3'b101: temp <= 12'b100000010000;//bge000010
                        3'b110: temp <= 12'b100001100000;//bltu001100
                        3'b111: temp <= 12'b100000011000;//bgeu000011
                    endcase
                end
                7'b1101111: temp <= 12'b100001101011;//jal001101
                7'b1100111: temp <= 12'b100001101011;//jalr001101
                7'b0110111: temp <= 12'b011001111011;//lui001111
                default: temp <= 12'b000000000000;
            endcase 
        end
    end
endmodule