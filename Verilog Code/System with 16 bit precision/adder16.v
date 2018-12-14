////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 11/14/2017 
// Module Name   : adder16
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : Vivado 2016.4
//
// Description: 
// 		Performing addition between for 16 input values
// 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Addtion using operator +
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module adder16(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16,out);

parameter DWIDTH=16;
parameter AWIDTH=10;
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
//parameter learningrate = 32'b00000000000000000000011010001101;

input [DWIDTH-1:0] in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,in14,in15,in16;
output [DWIDTH-1:0] out;

assign out=in1+in2+in3+in4+in5+in6+in7+in8+in9+in10+in11+in12+in13+in14+in15+in16;

endmodule