////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : DFlipFlop with reset port
// Module Name   : Dflipflop
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		DFlipFlop with reset functionality
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module Dflipflop (clk,reset,in,enable,out);

parameter DWIDTH=32;

input wire clk;
input wire reset;
input wire signed [DWIDTH-1:0] in;
output reg signed [DWIDTH-1:0] out;
input wire enable;

always @(posedge clk)
begin
	if (reset)
	  begin
		out <= 32'b00000000000000000000000000000000;
	  end
	else 
	  begin
		if (enable==1)
		  begin
			out <= in;
		  end
		else
		  begin
			out <= out;
		  end
	  end
end

endmodule