////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Multiplexer for selecting input pixels
// Module Name   : mux64
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		64to1 mux to select a pixel to be processed in one cycle 
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module mux64 (in,sel,out);

parameter DWIDTH=16;
parameter IWIDTH=64;

input [IWIDTH-1:0] in;
input [5:0] sel;
output [0:0] out;

wire [3:0] temp;

mux16to1_1bit mux_1 (.in(in[15:0]),.sel(sel[3:0]),.out(temp[0]));
mux16to1_1bit mux_2 (.in(in[31:16]),.sel(sel[3:0]),.out(temp[1]));
mux16to1_1bit mux_3 (.in(in[47:32]),.sel(sel[3:0]),.out(temp[2]));
mux16to1_1bit mux_4 (.in(in[63:48]),.sel(sel[3:0]),.out(temp[3]));
mux4to1_1bit mux_out (.in1(temp[0]),.in2(temp[1]),.in3(temp[2]),.in4(temp[3]),.sel(sel[5:4]),.out(out));

endmodule