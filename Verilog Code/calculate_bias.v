module calculate_bias(clk,delta,BRAM_out,en_b_back,new_bias);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
parameter learningrate = 32'b00000000000000000000011010001101;

input clk,en_b_back;
input signed [DWIDTH-1:0] delta;
input signed [DWIDTH-1:0] BRAM_out;
output signed [DWIDTH-1:0] new_bias;

wire signed [DWIDTH-1:0] b,temp,pre_new_bias;

//Dflipflopbp Dflip1(.clk(clk),.in(BRAM_out),.enable(en_b_back_read),.out(b));
multiplier mult(.a(learningrate),.b(delta),.c(temp));
adder2 add(.a(temp),.b(BRAM_out),.c(pre_new_bias));
Dflipflopbp Dflip2(.clk(clk),.in(pre_new_bias),.enable(en_b_back),.out(new_bias));

endmodule

