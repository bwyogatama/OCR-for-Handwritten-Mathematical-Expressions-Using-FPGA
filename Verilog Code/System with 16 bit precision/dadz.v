////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Invers of sigmoid function
// Module Name   : dadz
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Performing computation for invers log sigmoid function
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module dadz (in, out);
parameter DWIDTH=16;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input signed [DWIDTH-1:0] in;
output signed [DWIDTH-1:0] out;
wire signed [DWIDTH-1:0] temp;

substract substract(.a(in),.b(16'b0000010000000000),.c(temp));
multiplier mult(.a(in),.b(temp),.c(out));

endmodule