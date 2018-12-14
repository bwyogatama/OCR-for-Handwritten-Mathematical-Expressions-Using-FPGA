////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : DFlipFlop without reset port
// Module Name   : Dflipflopbp
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Specialized DFlipFlop without reset functionality
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module Dflipflopbp (clk,in,enable,out);
parameter DWIDTH=32;


input clk;
input signed [DWIDTH-1:0] in;
output reg signed [DWIDTH-1:0] out;
input enable;

always @(posedge clk)
begin
	if (enable==1)
	begin
		out<=in;
	end
end

endmodule