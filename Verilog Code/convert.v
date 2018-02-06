////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 11/14/2017 
// Module Name   : convert
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : Vivado 2016.4
//
// Description: 
// 		Converting 1-bit input to 32 bit computable data
// 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Addtion using operator +
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module convert (in,k);
parameter DWIDTH=32;
parameter IWIDTH=64;

input [0:0] in;
output [DWIDTH-1:0] k;

assign k=in?32'b00000001000000000000000000000000:32'b00000000000000000000000000000000;

endmodule