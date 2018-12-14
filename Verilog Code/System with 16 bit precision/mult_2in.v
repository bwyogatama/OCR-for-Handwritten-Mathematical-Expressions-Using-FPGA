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

input signed [15:0] A, B;
output signed [15:0] Out;

wire signed [31:0] temp;

assign temp = A*B;
assign Out = temp[25:10];

endmodule