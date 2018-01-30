module mux2to1_64bit(in1,in2,sel,out);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter CLASS=16;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
parameter t=4'b0000;
parameter k=64'h0FFC19C3E7E7C01FF;
parameter learningrate = 32'b00000000000000000000011010001101;

input [IWIDTH-1:0] in1,in2;
input sel;
output [IWIDTH-1:0] out;

assign out=sel?in2:in1;

endmodule 