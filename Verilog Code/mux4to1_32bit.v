module mux4to1_32bit (in1,in2,in3,in4,sel,out);

parameter DWIDTH=32;

input [DWIDTH-1:0] in1,in2,in3,in4;

input [1:0] sel;

output [DWIDTH-1:0] out;

assign out = sel[1] ? ( sel[0] ? in4 : in3 ) : ( sel[0] ? in2 : in1 );

endmodule