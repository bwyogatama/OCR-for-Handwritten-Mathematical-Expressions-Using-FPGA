module mux16to1_32bit (in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16,sel,out);

parameter DWIDTH=32;

input [DWIDTH-1:0] in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16;
input [3:0] sel;
output [DWIDTH-1:0] out;

wire [DWIDTH-1:0] temp [3:0];

mux4to1_32bit mux_1 (.in1(in1),.in2(in2),.in3(in3),.in4(in4),.sel(sel[1:0]),.out(temp[0]));
mux4to1_32bit mux_2 (.in1(in5),.in2(in6),.in3(in7),.in4(in8),.sel(sel[1:0]),.out(temp[1]));
mux4to1_32bit mux_3 (.in1(in9),.in2(in10),.in3(in11),.in4(in12),.sel(sel[1:0]),.out(temp[2]));
mux4to1_32bit mux_4 (.in1(in13),.in2(in14),.in3(in15),.in4(in16),.sel(sel[1:0]),.out(temp[3]));
mux4to1_32bit mux_out (.in1(temp[0]),.in2(temp[1]),.in3(temp[2]),.in4(temp[3]),.sel(sel[3:2]),.out(out));

endmodule