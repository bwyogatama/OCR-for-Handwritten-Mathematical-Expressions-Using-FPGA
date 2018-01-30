module calculate_delta3 (clk,a3,t,en_delta3,en_cost,delta3,cost);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input clk;
input signed [DWIDTH-1:0] a3;
input [DWIDTH-1:0] t;
output signed [DWIDTH-1:0] delta3;
output signed [DWIDTH-1:0] cost;
input en_delta3,en_cost;

wire signed [DWIDTH-1:0] a3mint,da3,predelta,precost;

/*Dflipflopbp Dflip1(.clk(clk),.in(BRAM_out),.enable(en_t),.out(t));*/
substract sub(.a(a3),.b(t),.c(a3mint));
dadz dadz(.in(a3),.out(da3));
multiplier mult1(.a(da3),.b(a3mint),.c(predelta));
Dflipflopbp Dflip2(.clk(clk),.in(predelta),.enable(en_delta3),.out(delta3));
multiplier mult2(.a(a3mint),.b(a3mint),.c(precost));
Dflipflopbp Dflip3(.clk(clk),.in(precost),.enable(en_cost),.out(cost));


endmodule

