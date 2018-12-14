module mux4to1_1bit (in1,in2,in3,in4,sel,out);

input [0:0] in1,in2,in3,in4;

input [1:0] sel;

output [0:0] out;

assign out = sel[1] ? ( sel[0] ? in4 : in3 ) : ( sel[0] ? in2 : in1 );

endmodule