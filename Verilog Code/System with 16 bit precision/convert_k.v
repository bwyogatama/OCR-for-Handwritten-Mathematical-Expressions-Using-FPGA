////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 11/14/2017 
// Module Name   : convert_k
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

module convert_k (in,k);
parameter DWIDTH=16;
parameter IWIDTH=64;

input [0:0] in;
output [DWIDTH-1:0] k;

assign k = in ? 16'b0000001000000000 : 16'b0000000000000000;

endmodule