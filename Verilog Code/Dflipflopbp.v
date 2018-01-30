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