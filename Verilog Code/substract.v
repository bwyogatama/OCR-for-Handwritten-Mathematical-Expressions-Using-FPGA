module substract (a,b,c);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input signed [DWIDTH-1:0] a;
input signed [DWIDTH-1:0] b;
output signed [DWIDTH-1:0] c;

assign c=a-b;

endmodule

