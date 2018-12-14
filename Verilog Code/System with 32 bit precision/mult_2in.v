////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee
//
// Create Date   : 11/14/2017 
// Design Name   : Multiplier with 2 input 
// Module Name   : mult_2in
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : FPGA
//
// Description: 
// 		Multiplying two input value
// 
// Input:
//  	A : 16 bit signed : First Value
//  	B : 16 bit signed : Second Value 
//
// Output:
//  	out : 16 bit signed : Result 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Multiplication using operator *
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module mult_2in (A, B, Out);

parameter DWIDTH=32;
parameter frac=24;

input signed [DWIDTH-1:0] A, B;
output signed [DWIDTH-1:0] Out;

wire signed [2*DWIDTH-1:0] temp;

assign temp = A*B;
assign Out = temp[((2*DWIDTH-1)-(DWIDTH-frac)):frac];

endmodule