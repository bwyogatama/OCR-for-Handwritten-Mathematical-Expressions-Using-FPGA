module convert_k (in,k);
parameter DWIDTH=32;
parameter IWIDTH=64;

input [0:0] in;
output [DWIDTH-1:0] k;

assign k=in?32'b00000000100000000000000000000000:32'b00000000000000000000000000000000;

endmodule