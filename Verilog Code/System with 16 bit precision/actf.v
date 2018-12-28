////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee
//
// Create Date   : 11/14/2017 
// Design Name   : Activation Function using Sigmoid 
// Module Name   : actf
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Sigmoid Function
// Tool versions : FPGA
//
// Description: 
// 		Performing addition for 4 input values
// 
// Input:
//  	clk : 1 bit  : clock signal
//  	en  : 1 bit  : enable signal
//  	in  : 16 bit signed : input Value 
//
// Output:
//  	out : 16 bit signed : Result 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Addtion using operator +
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module actf(clk, reset, en, in, out);

input clk, en, reset;
input signed [15:0] in;
output signed [15:0] out;

wire signed [15:0] temp;


sigmf sigmoid_function(in, temp);
Dflipflop Dflop(.clk(clk),.reset(reset),.in(temp),.enable(en),.out(out));

//always@(posedge clk)
//begin
//  if (en) out <= temp; else out <= 16'bz;
//end

endmodule