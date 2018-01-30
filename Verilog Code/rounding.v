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