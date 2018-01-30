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

/*
Dflipflop_1bit DFF_0(.clk(clk), .in(in[0]), .enable(enable), .out(out[0]));
Dflipflop_1bit DFF_1(.clk(clk), .in(in[1]), .enable(enable), .out(out[1]));
Dflipflop_1bit DFF_2(.clk(clk), .in(in[2]), .enable(enable), .out(out[2]));
Dflipflop_1bit DFF_3(.clk(clk), .in(in[3]), .enable(enable), .out(out[3]));
Dflipflop_1bit DFF_4(.clk(clk), .in(in[4]), .enable(enable), .out(out[4]));
Dflipflop_1bit DFF_5(.clk(clk), .in(in[5]), .enable(enable), .out(out[5]));
Dflipflop_1bit DFF_6(.clk(clk), .in(in[6]), .enable(enable), .out(out[6]));
Dflipflop_1bit DFF_7(.clk(clk), .in(in[7]), .enable(enable), .out(out[7]));
Dflipflop_1bit DFF_8(.clk(clk), .in(in[8]), .enable(enable), .out(out[8]));
Dflipflop_1bit DFF_9(.clk(clk), .in(in[9]), .enable(enable), .out(out[9]));
Dflipflop_1bit DFF_10(.clk(clk), .in(in[10]), .enable(enable), .out(out[10]));
Dflipflop_1bit DFF_11(.clk(clk), .in(in[11]), .enable(enable), .out(out[11]));
Dflipflop_1bit DFF_12(.clk(clk), .in(in[12]), .enable(enable), .out(out[12]));
Dflipflop_1bit DFF_13(.clk(clk), .in(in[13]), .enable(enable), .out(out[13]));
Dflipflop_1bit DFF_14(.clk(clk), .in(in[14]), .enable(enable), .out(out[14]));
Dflipflop_1bit DFF_15(.clk(clk), .in(in[15]), .enable(enable), .out(out[15]));
*/

endmodule