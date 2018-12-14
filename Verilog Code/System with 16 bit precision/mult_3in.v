////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee
//
// Create Date   : 11/14/2017 
// Design Name   : Multiplier with 3 input 
// Module Name   : mult_3in
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : FPGA
//
// Description: 
// 		Multiplying three input values
// 
// Input:
//  	A : 16 bit signed : First Value
//  	B : 16 bit signed : Second Value 
//  	C : 16 bit signed : Third Value 
//
// Output:
//  	out : 16 bit signed : Result 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Multiplication using operator *
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module mult_3in (A, B, C, Out);

input signed [15:0] A, B, C;
output signed [15:0] Out;

wire signed [63:0] temp;

assign temp = A*B*C;
assign Out = temp[35:20];

endmodule