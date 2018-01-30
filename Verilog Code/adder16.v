module adder16(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16,out);

parameter DWIDTH=32;
parameter AWIDTH=10;
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
parameter learningrate = 32'b00000000000000000000011010001101;

input [DWIDTH-1:0] in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16;
output [DWIDTH-1:0] out;

assign out=in1+in2+in3+in4+in5+in6+in7+in8+in9+in10+in11+in12+in13+in14+in15+in16;

endmodule