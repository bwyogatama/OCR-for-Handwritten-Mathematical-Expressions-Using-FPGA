////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Multiplexer selecting input for list of neurons
// Module Name   : mux2
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		2to1 mux to select input for list of neurons: input neuron or output of activation function 
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module mux2 (in1,in2,sel,out);

parameter DWIDTH=32;

input signed [DWIDTH-1:0] in1,in2;
input sel;
output signed [DWIDTH-1:0] out;

assign out = (sel) ? in2 : in1; 

endmodule