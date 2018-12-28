////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Z calculation 
// Module Name   : z
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Conducting z value calculation before going into activation function
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module z(clk,reset,k,sel,enable_out,enable_prev,in_BRAM,out);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input clk;
input reset;
input enable_out,enable_prev;
input sel;
input signed [DWIDTH-1:0] k;
input signed [DWIDTH-1:0] in_BRAM;
output signed [DWIDTH-1:0] out;

wire signed [DWIDTH-1:0] value;
wire signed [DWIDTH-1:0] temp;
wire signed [DWIDTH-1:0] in1, in2;


Dflipflop Dflip_out(.clk(clk),.reset(reset),.in(value),.enable(enable_out),.out(out));
Dflipflop Dflip_prev(.clk(clk),.reset(reset),.in(temp),.enable(enable_prev),.out(in2));
multiplier mult(.a(in_BRAM),.b(k),.c(in1));
adder2 adder2(.a(in1),.b(in2),.c(value)); 

assign temp=sel?in_BRAM:out;

endmodule
