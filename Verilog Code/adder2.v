module adder2(a,b,c);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter Layer=15;

input signed [DWIDTH-1:0] a,b;
output signed [DWIDTH-1:0] c;
assign c=a+b;
endmodule