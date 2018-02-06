////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Rounding
// Module Name   : rounding
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Shrinking identification result into binary 
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module rounding (in,reset,en,out);
parameter DWIDTH =32;
parameter frac = 24;

input [DWIDTH-1:0] in;
input en;
input reset;
output reg out;

always @(*)
begin
	if (reset)
	  begin 
		out <= 0;
	  end
	else if (en)
	  begin
		if (in[DWIDTH-1:0] >= 32'b00000000100000000000000000000000)
		  begin
			out <= 1;
		  end
		else
		  begin
			out <= 0;
		  end
	  end
end

endmodule