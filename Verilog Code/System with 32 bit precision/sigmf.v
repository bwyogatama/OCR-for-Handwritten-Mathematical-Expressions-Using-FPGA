////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee
//
// Create Date   : 11/14/2017 
// Design Name   : Sigmoid Function
// Module Name   : sigmf
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Neural Network
// Tool versions : FPGA
//
// Description: 
// 		Calculation sigmoid function as the activation function for neural network
// 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Based on MacClaurin Series with 3 Terms.
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module sigmf(in, out);

parameter DWIDTH = 32;
parameter one = 32'b0000_0001_0000_0000_0000_0000_0000_0000; //variable for decimal value of 1

input signed [DWIDTH-1:0] in;
output signed [DWIDTH-1:0] out;

wire [2:0] ctrl;
wire signed [DWIDTH-1:0] term1, term2, term3;
wire signed [DWIDTH-1:0] c_term2, c_term3;
wire signed [DWIDTH-1:0] x, mid, result;


assign x = in[DWIDTH-1] ? (~in+1-mid) : (in-mid); 

segmentation seg(in, ctrl);
mid_val     midvalue(ctrl, mid);
coef_term1  coef1(ctrl, term1);
coef_term2  coef2(ctrl, c_term2);
coef_term3  coef3(ctrl, c_term3);
//coef_term4  coef4(ctrl, c_term4);
mult_2in    ser_term2(c_term2, x, term2);
mult_3in    ser_term3(c_term3, x, x, term3);
//mult_4in    ser_term4(c_term4, x, x, x, term4);
adder_4in   finaladd(term1, term2, term3, result);

assign out = in[DWIDTH-1] ? (one-result) : result;

endmodule