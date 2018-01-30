module mux2 (in1,in2,sel,out);

parameter DWIDTH=32;

input signed [DWIDTH-1:0] in1,in2;
input sel;
output signed [DWIDTH-1:0] out;

assign out = (sel) ? in2 : in1; 

endmodule