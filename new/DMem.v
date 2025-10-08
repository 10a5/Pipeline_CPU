module DMem(
 input clk, 
 input rst_n,
input MemRead,MemWrite,
 input [31:0] addr, 
input [31:0] din,
 output [31:0] dout
 );
 blk_mem_gen_0 udram(.clka(clk), .wea(MemWrite), .addra(addr[15:2]), .dina(din), .douta(dout));
endmodule