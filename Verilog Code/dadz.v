module dadz (in, out);
parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input signed [DWIDTH-1:0] in;
output signed [DWIDTH-1:0] out;
wire signed [DWIDTH-1:0] temp;

substract substract(.a(in),.b(32'b00000001000000000000000000000000),.c(temp));
multiplier mult(.a(in),.b(temp),.c(out));

endmodule