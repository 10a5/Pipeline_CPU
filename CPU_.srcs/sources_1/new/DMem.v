module DMem(
    input clk,
    input rst,
    input MemWrite,
    input[31:0] Address,
    input [31:0] WriteData,
    output [31:0] MemResult
);
wire [3:0] wea = MemWrite ? 4'b1111: 4'b0;
Memory mem(
    .clka(clk),
    .addra(Address),
    .dina(WriteData),
    .douta(MemResult),
    .wea(wea)
);
endmodule