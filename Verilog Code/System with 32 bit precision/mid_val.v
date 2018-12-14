////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee
//
// Create Date   : 11/14/2017 
// Design Name   : Mid Value for MacClaurin Series
// Module Name   : mid_val
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : FPGA
//
// Description: 
// 		Determining mid value for MacClaurin Series
// 
// Input:
//  	in : 3 bits unsigned : control signal from module selector
//
// Output:
//  	out: 16 bits 00_0000.0000_0000_00 signed : mid value for MacClaurin Series Calculation
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module mid_val(in, out);

parameter DWIDTH = 32;

input [2:0] in;
output reg signed [DWIDTH-1:0] out;

always@(in)
begin
  case(in)
    0 : out = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	1 : out = 32'b0000_0001_1000_0000_0000_0000_0000_0000;
	2 : out = 32'b0000_0010_1000_0000_0000_0000_0000_0000;
	3 : out = 32'b0000_0011_1000_0000_0000_0000_0000_0000;
	4 : out = 32'b0000_0101_0000_0000_0000_0000_0000_0000;
	5 : out = 32'b0000_0101_0000_0000_0000_0000_0000_0000;
	default : out = 0;
  
  endcase

end

endmodule