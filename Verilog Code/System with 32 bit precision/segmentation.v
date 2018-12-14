module segmentation(in, ctrl);

parameter DWIDTH = 32;

input [DWIDTH-1:0] in;
output [2:0] ctrl;

wire [15:0] t;
wire [DWIDTH-1:0] temp;

assign temp = (~in+1);

assign t = in[DWIDTH-1] ? temp[29:14] : in[29:14] ;

assign ctrl[2] = t[13] || (~t[13]&&t[12]) || (t[14]&&~t[13]&&~t[12]);
assign ctrl[1] = t[11] || (t[13]&&~t[11]) || (t[14]&&~t[13]&&~t[11]);
assign ctrl[0] = (~t[14]&&~t[13]&&~t[12]&&t[10]);

endmodule
