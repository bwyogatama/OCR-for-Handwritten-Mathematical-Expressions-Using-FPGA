module mux16to1_1bit (in,sel,out);

parameter DWIDTH=16;
parameter IWIDTH=16;

input [IWIDTH-1:0] in;
input [3:0] sel;
output [0:0] out;

wire [3:0] temp;

mux4to1_1bit mux_1 (.in1(in[0]),.in2(in[1]),.in3(in[2]),.in4(in[3]),.sel(sel[1:0]),.out(temp[0]));
mux4to1_1bit mux_2 (.in1(in[4]),.in2(in[5]),.in3(in[6]),.in4(in[7]),.sel(sel[1:0]),.out(temp[1]));
mux4to1_1bit mux_3 (.in1(in[8]),.in2(in[9]),.in3(in[10]),.in4(in[11]),.sel(sel[1:0]),.out(temp[2]));
mux4to1_1bit mux_4 (.in1(in[12]),.in2(in[13]),.in3(in[14]),.in4(in[15]),.sel(sel[1:0]),.out(temp[3]));
mux4to1_1bit mux_out (.in1(temp[0]),.in2(temp[1]),.in3(temp[2]),.in4(temp[3]),.sel(sel[3:2]),.out(out));

endmodule