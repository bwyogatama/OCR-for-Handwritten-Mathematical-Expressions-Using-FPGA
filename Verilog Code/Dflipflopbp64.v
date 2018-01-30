module Dflipflopbp64 (clk,in,enable,out);


parameter IWIDTH=64;

input clk;
input signed [IWIDTH-1:0] in;
output reg signed [IWIDTH-1:0] out;
input enable;

always @(posedge clk)
begin
	if (enable==1)
	begin
		out<=in;
	end
end

endmodule