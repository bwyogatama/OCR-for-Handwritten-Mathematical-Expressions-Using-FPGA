module multiplier (a,b,c);

parameter N = 32;
parameter frac = 24;

input signed [N-1:0] a;
input signed [N-1:0] b;
output signed [N-1:0] c;

wire signed [2*N-1:0] temp;

assign temp = a*b;
assign c = temp[((2*N-1)-(N-frac)):frac];

endmodule