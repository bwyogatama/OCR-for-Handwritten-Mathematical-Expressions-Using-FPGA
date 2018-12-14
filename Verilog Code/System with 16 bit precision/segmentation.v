

module segmentation(in, ctrl);

input [15:0] in;
output [2:0] ctrl;

wire [15:0] t;

assign t = in[15] ? (~in+1) : in ;

assign ctrl[2] = t[13] || (~t[13]&&t[12]) || (t[14]&&~t[13]&&~t[12]);
assign ctrl[1] = t[11] || (t[13]&&~t[11]) || (t[14]&&~t[13]&&~t[11]);
assign ctrl[0] = (~t[14]&&~t[13]&&~t[12]&&t[10]);

endmodule
