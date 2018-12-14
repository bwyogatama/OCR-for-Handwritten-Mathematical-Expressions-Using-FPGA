////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 11/14/2017 
// Module Name   : Subtraction between two input values
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado 2016.4
//
// Description: 
// 		Subtracts two input values
// 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Addtion using operator +
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

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

