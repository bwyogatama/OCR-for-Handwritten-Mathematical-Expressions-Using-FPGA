////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Weight and delta calculation
// Module Name   : calculate_weight_and_delta
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Calculates new weight and delta in backpropagation process
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module calculate_weight_and_delta(clk,enable_write_w,enable_delta,enable_calc_delta,save_a,
delta1,delta2,delta3,delta4,delta5,delta6,delta7,delta8,delta9,delta10,delta11,delta12,delta13,delta14,delta15,delta16,
BRAM_out1,BRAM_out2,BRAM_out3,BRAM_out4,BRAM_out5,BRAM_out6,BRAM_out7,BRAM_out8,BRAM_out9,BRAM_out10,BRAM_out11,BRAM_out12,BRAM_out13,BRAM_out14,BRAM_out15,BRAM_out16,
write_weight1,write_weight2,write_weight3,write_weight4,write_weight5,write_weight6,write_weight7,write_weight8,write_weight9,write_weight10,write_weight11,write_weight12,write_weight13,write_weight14,write_weight15,write_weight16,
next_delta1,next_delta2,next_delta3,next_delta4,next_delta5,next_delta6,next_delta7,next_delta8,next_delta9,next_delta10,next_delta11,next_delta12,next_delta13,next_delta14,next_delta15,next_delta16);

parameter DWIDTH=32;							
parameter AWIDTH=10;			 					
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
parameter learningrate = 32'b00000000000000000000011010001101;

input clk,enable_write_w,enable_delta;
input [15:0] enable_calc_delta;
input signed [DWIDTH-1:0] save_a;
input signed  [DWIDTH-1:0] delta1,delta2,delta3,delta4,delta5,delta6,delta7,delta8,delta9,delta10,delta11,delta12,delta13,delta14,delta15,delta16;
input signed [DWIDTH-1:0] BRAM_out1,BRAM_out2,BRAM_out3,BRAM_out4,BRAM_out5,BRAM_out6,BRAM_out7,BRAM_out8,BRAM_out9,BRAM_out10,BRAM_out11,BRAM_out12,BRAM_out13,BRAM_out14,BRAM_out15,BRAM_out16;
output signed [DWIDTH-1:0] next_delta1,next_delta2,next_delta3,next_delta4,next_delta5,next_delta6,next_delta7,next_delta8,next_delta9,next_delta10,next_delta11,next_delta12,next_delta13,next_delta14,next_delta15,next_delta16;
output signed [DWIDTH-1:0] write_weight1,write_weight2,write_weight3,write_weight4,write_weight5,write_weight6,write_weight7,write_weight8,write_weight9,write_weight10,write_weight11,write_weight12,write_weight13,write_weight14,write_weight15,write_weight16;

wire signed [DWIDTH-1:0] dxw1,dxw2,dxw3,dxw4,dxw5,dxw6,dxw7,dxw8,dxw9,dxw10,dxw11,dxw12,dxw13,dxw14,dxw15,dxw16;
/*wire signed [DWIDTH-1:0] save_weight1,save_weight2,save_weight3,save_weight4,save_weight5,save_weight6,save_weight7,save_weight8,save_weight9,save_weight10,save_weight11,save_weight12,save_weight13,save_weight14,save_weight15,save_weight16;
*/
wire signed [DWIDTH-1:0] dxa1,dxa2,dxa3,dxa4,dxa5,dxa6,dxa7,dxa8,dxa9,dxa10,dxa11,dxa12,dxa13,dxa14,dxa15,dxa16;
wire signed [DWIDTH-1:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp9,temp10,temp11,temp12,temp13,temp14,temp15,temp16;
wire signed [DWIDTH-1:0] res,net,da;

wire signed [DWIDTH-1:0] new_weight1,new_weight2,new_weight3,new_weight4,new_weight5,new_weight6,new_weight7,new_weight8,new_weight9,new_weight10,new_weight11,new_weight12,new_weight13,new_weight14,new_weight15,new_weight16;
wire signed [DWIDTH-1:0] next_delta;
/*Dflipflopbp Dflip1(.clk(clk),.in(BRAM_out1),.enable(enable_read_weight),.out(save_weight1));
Dflipflopbp Dflip2(.clk(clk),.in(BRAM_out2),.enable(enable_read_weight),.out(save_weight2));
Dflipflopbp Dflip3(.clk(clk),.in(BRAM_out3),.enable(enable_read_weight),.out(save_weight3));
Dflipflopbp Dflip4(.clk(clk),.in(BRAM_out4),.enable(enable_read_weight),.out(save_weight4));
Dflipflopbp Dflip5(.clk(clk),.in(BRAM_out5),.enable(enable_read_weight),.out(save_weight5));
Dflipflopbp Dflip6(.clk(clk),.in(BRAM_out6),.enable(enable_read_weight),.out(save_weight6));
Dflipflopbp Dflip7(.clk(clk),.in(BRAM_out7),.enable(enable_read_weight),.out(save_weight7));
Dflipflopbp Dflip8(.clk(clk),.in(BRAM_out8),.enable(enable_read_weight),.out(save_weight8));
Dflipflopbp Dflip9(.clk(clk),.in(BRAM_out9),.enable(enable_read_weight),.out(save_weight9));
Dflipflopbp Dflip10(.clk(clk),.in(BRAM_out10),.enable(enable_read_weight),.out(save_weight10));
Dflipflopbp Dflip11(.clk(clk),.in(BRAM_out11),.enable(enable_read_weight),.out(save_weight11));
Dflipflopbp Dflip12(.clk(clk),.in(BRAM_out12),.enable(enable_read_weight),.out(save_weight12));
Dflipflopbp Dflip13(.clk(clk),.in(BRAM_out13),.enable(enable_read_weight),.out(save_weight13));
Dflipflopbp Dflip14(.clk(clk),.in(BRAM_out14),.enable(enable_read_weight),.out(save_weight14));
Dflipflopbp Dflip15(.clk(clk),.in(BRAM_out15),.enable(enable_read_weight),.out(save_weight15));
Dflipflopbp Dflip16(.clk(clk),.in(BRAM_out16),.enable(enable_read_weight),.out(save_weight16));*/


multiplier mult1(.a(delta1),.b(BRAM_out1),.c(dxw1));
multiplier mult2(.a(delta2),.b(BRAM_out2),.c(dxw2));
multiplier mult3(.a(delta3),.b(BRAM_out3),.c(dxw3));
multiplier mult4(.a(delta4),.b(BRAM_out4),.c(dxw4));
multiplier mult5(.a(delta5),.b(BRAM_out5),.c(dxw5));
multiplier mult6(.a(delta6),.b(BRAM_out6),.c(dxw6));
multiplier mult7(.a(delta7),.b(BRAM_out7),.c(dxw7));
multiplier mult8(.a(delta8),.b(BRAM_out8),.c(dxw8));
multiplier mult9(.a(delta9),.b(BRAM_out9),.c(dxw9));
multiplier mult10(.a(delta10),.b(BRAM_out10),.c(dxw10));
multiplier mult11(.a(delta11),.b(BRAM_out11),.c(dxw11));
multiplier mult12(.a(delta12),.b(BRAM_out12),.c(dxw12));
multiplier mult13(.a(delta13),.b(BRAM_out13),.c(dxw13));
multiplier mult14(.a(delta14),.b(BRAM_out14),.c(dxw14));
multiplier mult15(.a(delta15),.b(BRAM_out15),.c(dxw15));
multiplier mult16(.a(delta16),.b(BRAM_out16),.c(dxw16));


multiplier mult17(.a(delta1),.b(save_a),.c(dxa1));
multiplier mult18(.a(delta2),.b(save_a),.c(dxa2));
multiplier mult19(.a(delta3),.b(save_a),.c(dxa3));
multiplier mult20(.a(delta4),.b(save_a),.c(dxa4));
multiplier mult21(.a(delta5),.b(save_a),.c(dxa5));
multiplier mult22(.a(delta6),.b(save_a),.c(dxa6));
multiplier mult23(.a(delta7),.b(save_a),.c(dxa7));
multiplier mult24(.a(delta8),.b(save_a),.c(dxa8));
multiplier mult25(.a(delta9),.b(save_a),.c(dxa9));
multiplier mult26(.a(delta10),.b(save_a),.c(dxa10));
multiplier mult27(.a(delta11),.b(save_a),.c(dxa11));
multiplier mult28(.a(delta12),.b(save_a),.c(dxa12));
multiplier mult29(.a(delta13),.b(save_a),.c(dxa13));
multiplier mult30(.a(delta14),.b(save_a),.c(dxa14));
multiplier mult31(.a(delta15),.b(save_a),.c(dxa15));
multiplier mult32(.a(delta16),.b(save_a),.c(dxa16));


multiplier mult33(.a(dxa1),.b(learningrate),.c(temp1));
multiplier mult34(.a(dxa2),.b(learningrate),.c(temp2));
multiplier mult35(.a(dxa3),.b(learningrate),.c(temp3));
multiplier mult36(.a(dxa4),.b(learningrate),.c(temp4));
multiplier mult37(.a(dxa5),.b(learningrate),.c(temp5));
multiplier mult38(.a(dxa6),.b(learningrate),.c(temp6));
multiplier mult39(.a(dxa7),.b(learningrate),.c(temp7));
multiplier mult40(.a(dxa8),.b(learningrate),.c(temp8));
multiplier mult41(.a(dxa9),.b(learningrate),.c(temp9));
multiplier mult42(.a(dxa10),.b(learningrate),.c(temp10));
multiplier mult43(.a(dxa11),.b(learningrate),.c(temp11));
multiplier mult44(.a(dxa12),.b(learningrate),.c(temp12));
multiplier mult45(.a(dxa13),.b(learningrate),.c(temp13));
multiplier mult46(.a(dxa14),.b(learningrate),.c(temp14));
multiplier mult47(.a(dxa15),.b(learningrate),.c(temp15));
multiplier mult48(.a(dxa16),.b(learningrate),.c(temp16));



adder2 add1(.a(temp1),.b(BRAM_out1),.c(new_weight1));
adder2 add2(.a(temp2),.b(BRAM_out2),.c(new_weight2));
adder2 add3(.a(temp3),.b(BRAM_out3),.c(new_weight3));
adder2 add4(.a(temp4),.b(BRAM_out4),.c(new_weight4));
adder2 add5(.a(temp5),.b(BRAM_out5),.c(new_weight5));
adder2 add6(.a(temp6),.b(BRAM_out6),.c(new_weight6));
adder2 add7(.a(temp7),.b(BRAM_out7),.c(new_weight7));
adder2 add8(.a(temp8),.b(BRAM_out8),.c(new_weight8));
adder2 add9(.a(temp9),.b(BRAM_out9),.c(new_weight9));
adder2 add10(.a(temp10),.b(BRAM_out10),.c(new_weight10));
adder2 add11(.a(temp11),.b(BRAM_out11),.c(new_weight11));
adder2 add12(.a(temp12),.b(BRAM_out12),.c(new_weight12));
adder2 add13(.a(temp13),.b(BRAM_out13),.c(new_weight13));
adder2 add14(.a(temp14),.b(BRAM_out14),.c(new_weight14));
adder2 add15(.a(temp15),.b(BRAM_out15),.c(new_weight15));
adder2 add16(.a(temp16),.b(BRAM_out16),.c(new_weight16));


Dflipflopbp Dflip33(.clk(clk),.in(new_weight1),.enable(enable_write_w),.out(write_weight1));
Dflipflopbp Dflip34(.clk(clk),.in(new_weight2),.enable(enable_write_w),.out(write_weight2));
Dflipflopbp Dflip35(.clk(clk),.in(new_weight3),.enable(enable_write_w),.out(write_weight3));
Dflipflopbp Dflip36(.clk(clk),.in(new_weight4),.enable(enable_write_w),.out(write_weight4));
Dflipflopbp Dflip37(.clk(clk),.in(new_weight5),.enable(enable_write_w),.out(write_weight5));
Dflipflopbp Dflip38(.clk(clk),.in(new_weight6),.enable(enable_write_w),.out(write_weight6));
Dflipflopbp Dflip39(.clk(clk),.in(new_weight7),.enable(enable_write_w),.out(write_weight7));
Dflipflopbp Dflip40(.clk(clk),.in(new_weight8),.enable(enable_write_w),.out(write_weight8));
Dflipflopbp Dflip41(.clk(clk),.in(new_weight9),.enable(enable_write_w),.out(write_weight9));
Dflipflopbp Dflip42(.clk(clk),.in(new_weight10),.enable(enable_write_w),.out(write_weight10));
Dflipflopbp Dflip43(.clk(clk),.in(new_weight11),.enable(enable_write_w),.out(write_weight11));
Dflipflopbp Dflip44(.clk(clk),.in(new_weight12),.enable(enable_write_w),.out(write_weight12));
Dflipflopbp Dflip45(.clk(clk),.in(new_weight13),.enable(enable_write_w),.out(write_weight13));
Dflipflopbp Dflip46(.clk(clk),.in(new_weight14),.enable(enable_write_w),.out(write_weight14));
Dflipflopbp Dflip47(.clk(clk),.in(new_weight15),.enable(enable_write_w),.out(write_weight15));
Dflipflopbp Dflip48(.clk(clk),.in(new_weight16),.enable(enable_write_w),.out(write_weight16));


adder16 add_16(.in1(dxw1),.in2(dxw2),.in3(dxw3),.in4(dxw4),.in5(dxw5),.in6(dxw6),.in7(dxw7),.in8(dxw8),.in9(dxw9),.in10(dxw10),.in11(dxw11),.in12(dxw12),.in13(dxw13),.in14(dxw14),.in15(dxw15),.in16(dxw16),.out(net));

dadz dadz(.in(save_a),.out(da));

multiplier mult49(.a(da),.b(net),.c(res));

Dflipflopbp Dflip65(.clk(clk),.in(res),.enable(enable_delta),.out(next_delta));

Dflipflopbp Dflip49(.clk(clk),.in(next_delta),.enable(enable_calc_delta[0]),.out(next_delta1));
Dflipflopbp Dflip50(.clk(clk),.in(next_delta),.enable(enable_calc_delta[1]),.out(next_delta2));
Dflipflopbp Dflip51(.clk(clk),.in(next_delta),.enable(enable_calc_delta[2]),.out(next_delta3));
Dflipflopbp Dflip52(.clk(clk),.in(next_delta),.enable(enable_calc_delta[3]),.out(next_delta4));
Dflipflopbp Dflip53(.clk(clk),.in(next_delta),.enable(enable_calc_delta[4]),.out(next_delta5));
Dflipflopbp Dflip54(.clk(clk),.in(next_delta),.enable(enable_calc_delta[5]),.out(next_delta6));
Dflipflopbp Dflip55(.clk(clk),.in(next_delta),.enable(enable_calc_delta[6]),.out(next_delta7));
Dflipflopbp Dflip56(.clk(clk),.in(next_delta),.enable(enable_calc_delta[7]),.out(next_delta8));
Dflipflopbp Dflip57(.clk(clk),.in(next_delta),.enable(enable_calc_delta[8]),.out(next_delta9));
Dflipflopbp Dflip58(.clk(clk),.in(next_delta),.enable(enable_calc_delta[9]),.out(next_delta10));
Dflipflopbp Dflip59(.clk(clk),.in(next_delta),.enable(enable_calc_delta[10]),.out(next_delta11));
Dflipflopbp Dflip60(.clk(clk),.in(next_delta),.enable(enable_calc_delta[11]),.out(next_delta12));
Dflipflopbp Dflip61(.clk(clk),.in(next_delta),.enable(enable_calc_delta[12]),.out(next_delta13));
Dflipflopbp Dflip62(.clk(clk),.in(next_delta),.enable(enable_calc_delta[13]),.out(next_delta14));
Dflipflopbp Dflip63(.clk(clk),.in(next_delta),.enable(enable_calc_delta[14]),.out(next_delta15));
Dflipflopbp Dflip64(.clk(clk),.in(next_delta),.enable(enable_calc_delta[15]),.out(next_delta16));

endmodule