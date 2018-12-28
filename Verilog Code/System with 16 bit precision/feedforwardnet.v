////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Feedforward Network 
// Module Name   : feedforwardnet
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		High Level Module for Forward and Backpropagation Neural Networks
// 
// %GENERAL PORTS%
// Input:
//  	clk   : 1 bit  : clock signal
//  	reset : 1 bit  : high priority reset signal
//  	image : 64 bit : Input image in form of 64-bit data
//      arm   : 1 bit  : Command signal
//      train : 1 bit  : Signal for mode of operation
//      finish: 1 bit  : Signal indicating the end of identification or training process 
//      stop  : 1 bit  : Command signal to halt training operation
//      iteration_cplt : 16 bit : Data indicating number of images in training dataset
//
// Output:
//      result: 16 bit : Identification result
//      cost  : 32 bit : Cost function value for training performance analysis
//
// %SPECIAL PORTS%
// Input: 
// 		PS_addr: 32 bit : Address input
// 		PS_clk : 1 bit  : Clock signal from processing system
// 		PS_din : 32 bit : Input data for write operation
// 		PS_en  : 1 bit  : Enable signal
// 		PS_rst : 1 bit  : High priority reset signal from processing system
// 		PS_we  : 4 bit  : Write enable signal
//
// Output:
//      PS_dout: 32 bit : Data for read operation
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module feedforwardnet
	  (clk,
	   reset,
	   image,
	   arm,
	   train,
	   finish,
	   result,
	   stop,
	   
	   iteration_cplt,
	   cost);

parameter DWIDTH=16;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter CLASS=16;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;
parameter learningrate = 16'b0000000001000000;


input clk;
input arm;
input reset;
input train;
input stop;
input [IWIDTH-1:0] image;
output finish;
output [CLASS-1:0] result;


input [15:0] iteration_cplt;
output signed [DWIDTH-1:0] cost;

/*
input [31:0] PS_addr;
input [0:0] PS_clk;
input [31:0] PS_din;
output [DWIDTH-1:0] PS_dout;
input PS_en;
input [0:0] PS_rst;
input [3:0] PS_we;*/

wire [AWIDTH-1:0] address;
wire [12:0] dataset_addr;
wire signed [DWIDTH-1:0] BRAM1_in [15:0];
wire signed [DWIDTH-1:0] BRAM1_out [15:0];
wire signed [DWIDTH-1:0] delta3 [15:0];
wire signed [DWIDTH-1:0] delta;
wire signed [DWIDTH-1:0] new_weight [15:0];
wire signed [DWIDTH-1:0] new_bias [15:0];
wire signed [DWIDTH-1:0] save_delta [15:0];
wire signed [DWIDTH-1:0] next_delta [15:0];
wire signed [DWIDTH-1:0] mux_in [15:0];
wire signed [DWIDTH-1:0] t_save [15:0];
wire signed [DWIDTH-1:0] t_conv [15:0];
wire signed [15:0] t_16bit;
wire signed [DWIDTH-1:0] save_a [15:0];
wire signed [DWIDTH-1:0] save_a_selected;
wire signed [IWIDTH-1:0] dataset_data,i_or_d;
wire [IWIDTH-1:0] k;

wire signed [DWIDTH-1:0] k_convert,k_reg;
wire signed k_selected;
wire signed [DWIDTH-1:0] a_or_k_selected;
wire signed [DWIDTH-1:0] cost_1,cost_2,cost_3,cost_4,cost_5,cost_6,cost_7,cost_8,cost_9,cost_10,cost_11,cost_12,cost_13,cost_14,cost_15,cost_16;

/*
wire [DWIDTH-1:0] PS_addr;
wire [9:0] PS_addr_in;
wire [3:0] BRAM_row_sel;
wire [0:0] PS_clk;
wire [DWIDTH-1:0] PS_din;
wire [DWIDTH-1:0] PS_dout;
wire [DWIDTH-1:0] PS_dout_in[15:0];

wire PS_en;
wire [15:0] PS_en_in;
wire [0:0] PS_rst;
wire [3:0] PS_we;*/


wire signed [DWIDTH-1:0] z [15:0];
wire signed [DWIDTH-1:0] a [15:0];
wire [CLASS-1:0] result; 
wire signed [DWIDTH-1:0] atemp;
wire signed [DWIDTH-1:0] z_in;


wire enable_read_a,enable_write_w,en_b_back,enable_delta,en_delta3,en_cost,sel_hs,en_save_delta,sel_a_or_k,en_k_reg,enable_supervisor;
wire [1:0] sel_BRAM_in;
wire [3:0] sel_a_select;
wire [5:0] select_k;
wire [15:0] enable_calc_delta;
wire [15:0] enable_BRAM1,we_BRAM1;
wire enable_BRAM2;


wire [0:0] in_conv;
wire [DWIDTH-1:0] k_conv;
wire [0:0] enable_b;
wire [1:0] enable_z; 
wire [0:0] enable_a; 
wire enable_rounding; 
wire [5:0] selector_input; 
wire [3:0] selector_a; 
wire [0:0] selector_z_in; 


wire [3:0] t;

//////////////////////////////////////////////
/////				   
/////	CONTROL UNIT
/////
//////////////////////////////////////////////

control_unit CU
	(.clk(clk),
     .reset(reset),
     .arm(arm),
	 .train(train),
	 .stop(stop),
		 
	 .selector_input(selector_input),
	 .enable_b(enable_b),
	 .enable_z(enable_z),
	 .enable_a(enable_a),
	 .selector_a(selector_a),
	 .enable_rounding(enable_rounding),
	 .finish(finish),
	 .selector_z_in(selector_z_in),
		 
	 .iteration_cplt(iteration_cplt),
	 .enable_read_a(enable_read_a),
	 .enable_write_w(enable_write_w),
	 .enable_delta(enable_delta),
	 .enable_calc_delta(enable_calc_delta),
	 .sel_a_select(sel_a_select),
	 .select_k(select_k),
	 .sel_a_or_k(sel_a_or_k),
	 .en_k_reg(en_k_reg),
	 .en_save_delta(en_save_delta),
	 .en_b_back(en_b_back),
	 .enable_supervisor(enable_supervisor),
	 .en_delta3(en_delta3),
	 .en_cost(en_cost),
	 .enable_BRAM1(enable_BRAM1),
	 .enable_BRAM2(enable_BRAM2),
	 .we_BRAM1(we_BRAM1),
	 .sel_hs(sel_hs),
	 .sel_BRAM_in(sel_BRAM_in),
	 .address_1(address),
	 .address_2(dataset_addr));


//////////////////////////////////////////////
/////				   
/////	ROM FOR DATASET IMAGES
/////
//////////////////////////////////////////////

ROM Dataset_Storage
  (.clka(clk),
   .rsta(reset),
   .ena(enable_BRAM2),
   .addra(dataset_addr),
   .douta({t,dataset_data}));

mux2to1_64bit mux_first(.in1(image),.in2(dataset_data),.sel(train),.out(i_or_d));

Dflipflopbp64 Dflip_first(.clk(clk),.in(i_or_d),.enable(en_k_reg),.out(k));

//////////////////////////////////////////////
/////				   
/////	RAM FOR NEURAL NETWORKS PARAMETERS
/////
//////////////////////////////////////////////

BRAM_0 BRAM_row0(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[0]),.BRAM_PORTA_dout(BRAM1_out[0]),.BRAM_PORTA_en(enable_BRAM1[0]),.BRAM_PORTA_we(we_BRAM1[0]),.BRAM_PORTA_rst(reset));
BRAM_1 BRAM_row1(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[1]),.BRAM_PORTA_dout(BRAM1_out[1]),.BRAM_PORTA_en(enable_BRAM1[1]),.BRAM_PORTA_we(we_BRAM1[1]),.BRAM_PORTA_rst(reset));
BRAM_2 BRAM_row2(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[2]),.BRAM_PORTA_dout(BRAM1_out[2]),.BRAM_PORTA_en(enable_BRAM1[2]),.BRAM_PORTA_we(we_BRAM1[2]),.BRAM_PORTA_rst(reset));
BRAM_3 BRAM_row3(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[3]),.BRAM_PORTA_dout(BRAM1_out[3]),.BRAM_PORTA_en(enable_BRAM1[3]),.BRAM_PORTA_we(we_BRAM1[3]),.BRAM_PORTA_rst(reset));
BRAM_4 BRAM_row4(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[4]),.BRAM_PORTA_dout(BRAM1_out[4]),.BRAM_PORTA_en(enable_BRAM1[4]),.BRAM_PORTA_we(we_BRAM1[4]),.BRAM_PORTA_rst(reset));
BRAM_5 BRAM_row5(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[5]),.BRAM_PORTA_dout(BRAM1_out[5]),.BRAM_PORTA_en(enable_BRAM1[5]),.BRAM_PORTA_we(we_BRAM1[5]),.BRAM_PORTA_rst(reset));
BRAM_6 BRAM_row6(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[6]),.BRAM_PORTA_dout(BRAM1_out[6]),.BRAM_PORTA_en(enable_BRAM1[6]),.BRAM_PORTA_we(we_BRAM1[6]),.BRAM_PORTA_rst(reset));
BRAM_7 BRAM_row7(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[7]),.BRAM_PORTA_dout(BRAM1_out[7]),.BRAM_PORTA_en(enable_BRAM1[7]),.BRAM_PORTA_we(we_BRAM1[7]),.BRAM_PORTA_rst(reset));
BRAM_8 BRAM_row8(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[8]),.BRAM_PORTA_dout(BRAM1_out[8]),.BRAM_PORTA_en(enable_BRAM1[8]),.BRAM_PORTA_we(we_BRAM1[8]),.BRAM_PORTA_rst(reset));
BRAM_9 BRAM_row9(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[9]),.BRAM_PORTA_dout(BRAM1_out[9]),.BRAM_PORTA_en(enable_BRAM1[9]),.BRAM_PORTA_we(we_BRAM1[9]),.BRAM_PORTA_rst(reset));
BRAM_10 BRAM_row10(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[10]),.BRAM_PORTA_dout(BRAM1_out[10]),.BRAM_PORTA_en(enable_BRAM1[10]),.BRAM_PORTA_we(we_BRAM1[10]),.BRAM_PORTA_rst(reset));
BRAM_11 BRAM_row11(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[11]),.BRAM_PORTA_dout(BRAM1_out[11]),.BRAM_PORTA_en(enable_BRAM1[11]),.BRAM_PORTA_we(we_BRAM1[11]),.BRAM_PORTA_rst(reset));
BRAM_12 BRAM_row12(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[12]),.BRAM_PORTA_dout(BRAM1_out[12]),.BRAM_PORTA_en(enable_BRAM1[12]),.BRAM_PORTA_we(we_BRAM1[12]),.BRAM_PORTA_rst(reset));
BRAM_13 BRAM_row13(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[13]),.BRAM_PORTA_dout(BRAM1_out[13]),.BRAM_PORTA_en(enable_BRAM1[13]),.BRAM_PORTA_we(we_BRAM1[13]),.BRAM_PORTA_rst(reset));
BRAM_14 BRAM_row14(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[14]),.BRAM_PORTA_dout(BRAM1_out[14]),.BRAM_PORTA_en(enable_BRAM1[14]),.BRAM_PORTA_we(we_BRAM1[14]),.BRAM_PORTA_rst(reset));
BRAM_15 BRAM_row15(.BRAM_PORTA_addr(address),.BRAM_PORTA_clk(clk),.BRAM_PORTA_din(BRAM1_in[15]),.BRAM_PORTA_dout(BRAM1_out[15]),.BRAM_PORTA_en(enable_BRAM1[15]),.BRAM_PORTA_we(we_BRAM1[15]),.BRAM_PORTA_rst(reset));

				   
//////////////////////////////////////////////
/////				   
/////	FORWARD
/////
//////////////////////////////////////////////				   
/*				   
assign PS_addr_in = PS_addr[9:0];
assign BRAM_row_sel = PS_addr[13:10];

mux1to16_1bit mux_en 
	(.in(PS_en),
	 .sel(BRAM_row_sel),
	 .out(PS_en_in));

mux16to1_16bit mux_PS_BRAM(
	.in1(PS_dout_in[0]),
	.in2(PS_dout_in[1]),
	.in3(PS_dout_in[2]),
	.in4(PS_dout_in[3]),
	.in5(PS_dout_in[4]),
	.in6(PS_dout_in[5]),
	.in7(PS_dout_in[6]),
	.in8(PS_dout_in[7]),
	.in9(PS_dout_in[8]),
	.in10(PS_dout_in[9]),
	.in11(PS_dout_in[10]),
	.in12(PS_dout_in[11]),
	.in13(PS_dout_in[12]),
	.in14(PS_dout_in[13]),
	.in15(PS_dout_in[14]),
	.in16(PS_dout_in[15]),
	.sel(BRAM_row_sel),
	.out(PS_dout));		*/		   
				   
//modul multiplexer buat milih 4 dari 64 input neuron
mux64 mux64_in
	  (.in(k),
	   .sel(selector_input),
	   .out(in_conv));

//modul buat ngekonversi 1 jadi 16'b0000010000000000 dan 0 jadi 16'b0000000000000000
convert_k conv
	  (.in(in_conv),
	   .k(k_conv));
				   
//modul buat ngitung z
z z_1(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[0]),.out(z[0]));
z z_2(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[1]),.out(z[1]));
z z_3(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[2]),.out(z[2]));
z z_4(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[3]),.out(z[3]));
z z_5(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[4]),.out(z[4]));
z z_6(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[5]),.out(z[5]));
z z_7(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[6]),.out(z[6]));
z z_8(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[7]),.out(z[7]));
z z_9(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[8]),.out(z[8]));
z z_10(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[9]),.out(z[9]));
z z_11(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[10]),.out(z[10]));
z z_12(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[11]),.out(z[11]));
z z_13(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[12]),.out(z[12]));
z z_14(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[13]),.out(z[13]));
z z_15(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[14]),.out(z[14]));
z z_16(.clk(clk),.reset(reset),.k(z_in),.sel(enable_b),.enable_out(enable_z[1]),.enable_prev(enable_z[0]),.in_BRAM(BRAM1_out[15]),.out(z[15]));
				   
				   
//modul buat ngitung a1
actf a_1(.clk(clk),.reset(reset),.en(enable_a),.in(z[0]),.out(a[0]));
actf a_2(.clk(clk),.reset(reset),.en(enable_a),.in(z[1]),.out(a[1]));
actf a_3(.clk(clk),.reset(reset),.en(enable_a),.in(z[2]),.out(a[2]));
actf a_4(.clk(clk),.reset(reset),.en(enable_a),.in(z[3]),.out(a[3]));
actf a_5(.clk(clk),.reset(reset),.en(enable_a),.in(z[4]),.out(a[4]));
actf a_6(.clk(clk),.reset(reset),.en(enable_a),.in(z[5]),.out(a[5]));
actf a_7(.clk(clk),.reset(reset),.en(enable_a),.in(z[6]),.out(a[6]));
actf a_8(.clk(clk),.reset(reset),.en(enable_a),.in(z[7]),.out(a[7]));
actf a_9(.clk(clk),.reset(reset),.en(enable_a),.in(z[8]),.out(a[8]));
actf a_10(.clk(clk),.reset(reset),.en(enable_a),.in(z[9]),.out(a[9]));
actf a_11(.clk(clk),.reset(reset),.en(enable_a),.in(z[10]),.out(a[10]));
actf a_12(.clk(clk),.reset(reset),.en(enable_a),.in(z[11]),.out(a[11]));
actf a_13(.clk(clk),.reset(reset),.en(enable_a),.in(z[12]),.out(a[12]));
actf a_14(.clk(clk),.reset(reset),.en(enable_a),.in(z[13]),.out(a[13]));
actf a_15(.clk(clk),.reset(reset),.en(enable_a),.in(z[14]),.out(a[14]));
actf a_16(.clk(clk),.reset(reset),.en(enable_a),.in(z[15]),.out(a[15])); 


//modul multiplexer buat milih 4 dari 16 neuron hidden layer
mux16to1_16bit mux16_a
	  (.in1(a[0]),
	   .in2(a[1]),
	   .in3(a[2]),
	   .in4(a[3]),
	   .in5(a[4]),
	   .in6(a[5]),
	   .in7(a[6]),
	   .in8(a[7]),
	   .in9(a[8]),
	   .in10(a[9]),
	   .in11(a[10]),
	   .in12(a[11]),
	   .in13(a[12]),
	   .in14(a[13]),
	   .in15(a[14]),
	   .in16(a[15]),
	   .sel(selector_a),
	   .out(atemp));

//Modul multiplexer untuk membedakan apakah input modul z adalah gambar 64 bit atau nilai a layer sebelumnya
mux2 mux2_k_or_z 
	  (.in1(k_conv),
	   .in2(atemp),
	   .sel(selector_z_in),
	   .out(z_in));
	   
//modul buat rounding hasil akhir
rounding round_1(.in(a[0]),.reset(reset),.en(enable_rounding),.out(result[0]));
rounding round_2(.in(a[1]),.reset(reset),.en(enable_rounding),.out(result[1]));
rounding round_3(.in(a[2]),.reset(reset),.en(enable_rounding),.out(result[2]));
rounding round_4(.in(a[3]),.reset(reset),.en(enable_rounding),.out(result[3]));
rounding round_5(.in(a[4]),.reset(reset),.en(enable_rounding),.out(result[4]));
rounding round_6(.in(a[5]),.reset(reset),.en(enable_rounding),.out(result[5]));
rounding round_7(.in(a[6]),.reset(reset),.en(enable_rounding),.out(result[6]));
rounding round_8(.in(a[7]),.reset(reset),.en(enable_rounding),.out(result[7]));
rounding round_9(.in(a[8]),.reset(reset),.en(enable_rounding),.out(result[8]));
rounding round_10(.in(a[9]),.reset(reset),.en(enable_rounding),.out(result[9]));
rounding round_11(.in(a[10]),.reset(reset),.en(enable_rounding),.out(result[10]));
rounding round_12(.in(a[11]),.reset(reset),.en(enable_rounding),.out(result[11]));
rounding round_13(.in(a[12]),.reset(reset),.en(enable_rounding),.out(result[12]));
rounding round_14(.in(a[13]),.reset(reset),.en(enable_rounding),.out(result[13]));
rounding round_15(.in(a[14]),.reset(reset),.en(enable_rounding),.out(result[14]));
rounding round_16(.in(a[15]),.reset(reset),.en(enable_rounding),.out(result[15]));				   
				   
				   
				   			   
//////////////////////////////////////////////
/////				   
/////	BACKPROPAGATION 
/////
//////////////////////////////////////////////
		
mux16to1_16bit mux_16_t(.in1(16'b0000000000000001),.in2(16'b0000000000000010),.in3(16'b0000000000000100),.in4(16'b0000000000001000),.in5(16'b0000000000010000),.in6(16'b0000000000100000),.in7(16'b0000000001000000),.in8(16'b0000000010000000),.in9(16'b0000000100000000),.in10(16'b0000001000000000),.in11(16'b0000010000000000),.in12(16'b0000100000000000),.in13(16'b0001000000000000),.in14(16'b0010000000000000),.in15(16'b0100000000000000),.in16(16'b1000000000000000),.sel(t),.out(t_16bit));

convert conv_t1(.in(t_16bit[0]),.k(t_conv[0]));
convert conv_t2(.in(t_16bit[1]),.k(t_conv[1]));
convert conv_t3(.in(t_16bit[2]),.k(t_conv[2]));
convert conv_t4(.in(t_16bit[3]),.k(t_conv[3]));
convert conv_t5(.in(t_16bit[4]),.k(t_conv[4]));
convert conv_t6(.in(t_16bit[5]),.k(t_conv[5]));
convert conv_t7(.in(t_16bit[6]),.k(t_conv[6]));
convert conv_t8(.in(t_16bit[7]),.k(t_conv[7]));
convert conv_t9(.in(t_16bit[8]),.k(t_conv[8]));
convert conv_t10(.in(t_16bit[9]),.k(t_conv[9]));
convert conv_t11(.in(t_16bit[10]),.k(t_conv[10]));
convert conv_t12(.in(t_16bit[11]),.k(t_conv[11]));
convert conv_t13(.in(t_16bit[12]),.k(t_conv[12]));
convert conv_t14(.in(t_16bit[13]),.k(t_conv[13]));
convert conv_t15(.in(t_16bit[14]),.k(t_conv[14]));
convert conv_t16(.in(t_16bit[15]),.k(t_conv[15]));

Dflipflopbp Dflip33(.clk(clk),.in(t_conv[0]),.enable(enable_supervisor),.out(t_save[0]));
Dflipflopbp Dflip34(.clk(clk),.in(t_conv[1]),.enable(enable_supervisor),.out(t_save[1]));
Dflipflopbp Dflip35(.clk(clk),.in(t_conv[2]),.enable(enable_supervisor),.out(t_save[2]));
Dflipflopbp Dflip36(.clk(clk),.in(t_conv[3]),.enable(enable_supervisor),.out(t_save[3]));
Dflipflopbp Dflip37(.clk(clk),.in(t_conv[4]),.enable(enable_supervisor),.out(t_save[4]));
Dflipflopbp Dflip38(.clk(clk),.in(t_conv[5]),.enable(enable_supervisor),.out(t_save[5]));
Dflipflopbp Dflip39(.clk(clk),.in(t_conv[6]),.enable(enable_supervisor),.out(t_save[6]));
Dflipflopbp Dflip40(.clk(clk),.in(t_conv[7]),.enable(enable_supervisor),.out(t_save[7]));
Dflipflopbp Dflip41(.clk(clk),.in(t_conv[8]),.enable(enable_supervisor),.out(t_save[8]));
Dflipflopbp Dflip42(.clk(clk),.in(t_conv[9]),.enable(enable_supervisor),.out(t_save[9]));
Dflipflopbp Dflip43(.clk(clk),.in(t_conv[10]),.enable(enable_supervisor),.out(t_save[10]));
Dflipflopbp Dflip44(.clk(clk),.in(t_conv[11]),.enable(enable_supervisor),.out(t_save[11]));
Dflipflopbp Dflip45(.clk(clk),.in(t_conv[12]),.enable(enable_supervisor),.out(t_save[12]));
Dflipflopbp Dflip46(.clk(clk),.in(t_conv[13]),.enable(enable_supervisor),.out(t_save[13]));
Dflipflopbp Dflip47(.clk(clk),.in(t_conv[14]),.enable(enable_supervisor),.out(t_save[14]));
Dflipflopbp Dflip48(.clk(clk),.in(t_conv[15]),.enable(enable_supervisor),.out(t_save[15]));

calculate_delta3 calc_delta3_1(.clk(clk),.a3(a[0]),.t(t_save[0]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[0]),.cost(cost_1));
calculate_delta3 calc_delta3_2(.clk(clk),.a3(a[1]),.t(t_save[1]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[1]),.cost(cost_2));
calculate_delta3 calc_delta3_3(.clk(clk),.a3(a[2]),.t(t_save[2]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[2]),.cost(cost_3));
calculate_delta3 calc_delta3_4(.clk(clk),.a3(a[3]),.t(t_save[3]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[3]),.cost(cost_4));
calculate_delta3 calc_delta3_5(.clk(clk),.a3(a[4]),.t(t_save[4]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[4]),.cost(cost_5));
calculate_delta3 calc_delta3_6(.clk(clk),.a3(a[5]),.t(t_save[5]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[5]),.cost(cost_6));
calculate_delta3 calc_delta3_7(.clk(clk),.a3(a[6]),.t(t_save[6]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[6]),.cost(cost_7));
calculate_delta3 calc_delta3_8(.clk(clk),.a3(a[7]),.t(t_save[7]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[7]),.cost(cost_8));
calculate_delta3 calc_delta3_9(.clk(clk),.a3(a[8]),.t(t_save[8]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[8]),.cost(cost_9));
calculate_delta3 calc_delta3_10(.clk(clk),.a3(a[9]),.t(t_save[9]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[9]),.cost(cost_10));
calculate_delta3 calc_delta3_11(.clk(clk),.a3(a[10]),.t(t_save[10]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[10]),.cost(cost_11));
calculate_delta3 calc_delta3_12(.clk(clk),.a3(a[11]),.t(t_save[11]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[11]),.cost(cost_12));
calculate_delta3 calc_delta3_13(.clk(clk),.a3(a[12]),.t(t_save[12]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[12]),.cost(cost_13));
calculate_delta3 calc_delta3_14(.clk(clk),.a3(a[13]),.t(t_save[13]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[13]),.cost(cost_14));
calculate_delta3 calc_delta3_15(.clk(clk),.a3(a[14]),.t(t_save[14]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[14]),.cost(cost_15));
calculate_delta3 calc_delta3_16(.clk(clk),.a3(a[15]),.t(t_save[15]),.en_delta3(en_delta3),.en_cost(en_cost),.delta3(delta3[15]),.cost(cost_16));

adder16 add16(.in1(cost_1),.in2(cost_2),.in3(cost_3),.in4(cost_4),.in5(cost_5),.in6(cost_6),.in7(cost_7),.in8(cost_8),.in9(cost_9),.in10(cost_10),.in11(cost_11),.in12(cost_12),.in13(cost_13),.in14(cost_14),.in15(cost_15),.in16(cost_16),.out(cost));

calculate_bias calc_bias_1(.clk(clk),.delta(mux_in[0]),.BRAM_out(BRAM1_out[0]),.en_b_back(en_b_back),.new_bias(new_bias[0]));
calculate_bias calc_bias_2(.clk(clk),.delta(mux_in[1]),.BRAM_out(BRAM1_out[1]),.en_b_back(en_b_back),.new_bias(new_bias[1]));
calculate_bias calc_bias_3(.clk(clk),.delta(mux_in[2]),.BRAM_out(BRAM1_out[2]),.en_b_back(en_b_back),.new_bias(new_bias[2]));
calculate_bias calc_bias_4(.clk(clk),.delta(mux_in[3]),.BRAM_out(BRAM1_out[3]),.en_b_back(en_b_back),.new_bias(new_bias[3]));
calculate_bias calc_bias_5(.clk(clk),.delta(mux_in[4]),.BRAM_out(BRAM1_out[4]),.en_b_back(en_b_back),.new_bias(new_bias[4]));
calculate_bias calc_bias_6(.clk(clk),.delta(mux_in[5]),.BRAM_out(BRAM1_out[5]),.en_b_back(en_b_back),.new_bias(new_bias[5]));
calculate_bias calc_bias_7(.clk(clk),.delta(mux_in[6]),.BRAM_out(BRAM1_out[6]),.en_b_back(en_b_back),.new_bias(new_bias[6]));
calculate_bias calc_bias_8(.clk(clk),.delta(mux_in[7]),.BRAM_out(BRAM1_out[7]),.en_b_back(en_b_back),.new_bias(new_bias[7]));
calculate_bias calc_bias_9(.clk(clk),.delta(mux_in[8]),.BRAM_out(BRAM1_out[8]),.en_b_back(en_b_back),.new_bias(new_bias[8]));
calculate_bias calc_bias_10(.clk(clk),.delta(mux_in[9]),.BRAM_out(BRAM1_out[9]),.en_b_back(en_b_back),.new_bias(new_bias[9]));
calculate_bias calc_bias_11(.clk(clk),.delta(mux_in[10]),.BRAM_out(BRAM1_out[10]),.en_b_back(en_b_back),.new_bias(new_bias[10]));
calculate_bias calc_bias_12(.clk(clk),.delta(mux_in[11]),.BRAM_out(BRAM1_out[11]),.en_b_back(en_b_back),.new_bias(new_bias[11]));
calculate_bias calc_bias_13(.clk(clk),.delta(mux_in[12]),.BRAM_out(BRAM1_out[12]),.en_b_back(en_b_back),.new_bias(new_bias[12]));
calculate_bias calc_bias_14(.clk(clk),.delta(mux_in[13]),.BRAM_out(BRAM1_out[13]),.en_b_back(en_b_back),.new_bias(new_bias[13]));
calculate_bias calc_bias_15(.clk(clk),.delta(mux_in[14]),.BRAM_out(BRAM1_out[14]),.en_b_back(en_b_back),.new_bias(new_bias[14]));
calculate_bias calc_bias_16(.clk(clk),.delta(mux_in[15]),.BRAM_out(BRAM1_out[15]),.en_b_back(en_b_back),.new_bias(new_bias[15]));

Dflipflopbp Dflip17(.clk(clk),.in(BRAM1_out[0]),.enable(enable_read_a),.out(save_a[0]));
Dflipflopbp Dflip18(.clk(clk),.in(BRAM1_out[1]),.enable(enable_read_a),.out(save_a[1]));
Dflipflopbp Dflip19(.clk(clk),.in(BRAM1_out[2]),.enable(enable_read_a),.out(save_a[2]));
Dflipflopbp Dflip20(.clk(clk),.in(BRAM1_out[3]),.enable(enable_read_a),.out(save_a[3]));
Dflipflopbp Dflip21(.clk(clk),.in(BRAM1_out[4]),.enable(enable_read_a),.out(save_a[4]));
Dflipflopbp Dflip22(.clk(clk),.in(BRAM1_out[5]),.enable(enable_read_a),.out(save_a[5]));
Dflipflopbp Dflip23(.clk(clk),.in(BRAM1_out[6]),.enable(enable_read_a),.out(save_a[6]));
Dflipflopbp Dflip24(.clk(clk),.in(BRAM1_out[7]),.enable(enable_read_a),.out(save_a[7]));
Dflipflopbp Dflip25(.clk(clk),.in(BRAM1_out[8]),.enable(enable_read_a),.out(save_a[8]));
Dflipflopbp Dflip26(.clk(clk),.in(BRAM1_out[9]),.enable(enable_read_a),.out(save_a[9]));
Dflipflopbp Dflip27(.clk(clk),.in(BRAM1_out[10]),.enable(enable_read_a),.out(save_a[10]));
Dflipflopbp Dflip28(.clk(clk),.in(BRAM1_out[11]),.enable(enable_read_a),.out(save_a[11]));
Dflipflopbp Dflip29(.clk(clk),.in(BRAM1_out[12]),.enable(enable_read_a),.out(save_a[12]));
Dflipflopbp Dflip30(.clk(clk),.in(BRAM1_out[13]),.enable(enable_read_a),.out(save_a[13]));
Dflipflopbp Dflip31(.clk(clk),.in(BRAM1_out[14]),.enable(enable_read_a),.out(save_a[14]));
Dflipflopbp Dflip32(.clk(clk),.in(BRAM1_out[15]),.enable(enable_read_a),.out(save_a[15]));

mux16to1_16bit mux16_a_bprop(.in1(save_a[0]),.in2(save_a[1]),.in3(save_a[2]),.in4(save_a[3]),.in5(save_a[4]),.in6(save_a[5]),.in7(save_a[6]),.in8(save_a[7]),.in9(save_a[8]),.in10(save_a[9]),.in11(save_a[10]),.in12(save_a[11]),.in13(save_a[12]),.in14(save_a[13]),.in15(save_a[14]),.in16(save_a[15]),.sel(sel_a_select),.out(save_a_selected));

mux64 mux64(.in(k),.sel(select_k),.out(k_selected));

convert_k conv_k(.in(k_selected),.k(k_convert));

mux2 mux2(.in1(k_convert),.in2(save_a_selected),.sel(~sel_a_or_k),.out(a_or_k_selected));

calculate_weight_and_delta cwd(.clk(clk),.enable_write_w(enable_write_w),.enable_delta(enable_delta),.enable_calc_delta(enable_calc_delta),.save_a(a_or_k_selected),
.delta1(mux_in[0]),.delta2(mux_in[1]),.delta3(mux_in[2]),.delta4(mux_in[3]),.delta5(mux_in[4]),.delta6(mux_in[5]),.delta7(mux_in[6]),.delta8(mux_in[7]),.delta9(mux_in[8]),.delta10(mux_in[9]),.delta11(mux_in[10]),.delta12(mux_in[11]),.delta13(mux_in[12]),.delta14(mux_in[13]),.delta15(mux_in[14]),.delta16(mux_in[15]),
.BRAM_out1(BRAM1_out[0]),.BRAM_out2(BRAM1_out[1]),.BRAM_out3(BRAM1_out[2]),.BRAM_out4(BRAM1_out[3]),.BRAM_out5(BRAM1_out[4]),.BRAM_out6(BRAM1_out[5]),.BRAM_out7(BRAM1_out[6]),.BRAM_out8(BRAM1_out[7]),.BRAM_out9(BRAM1_out[8]),.BRAM_out10(BRAM1_out[9]),.BRAM_out11(BRAM1_out[10]),.BRAM_out12(BRAM1_out[11]),.BRAM_out13(BRAM1_out[12]),.BRAM_out14(BRAM1_out[13]),.BRAM_out15(BRAM1_out[14]),.BRAM_out16(BRAM1_out[15]),
.write_weight1(new_weight[0]),.write_weight2(new_weight[1]),.write_weight3(new_weight[2]),.write_weight4(new_weight[3]),.write_weight5(new_weight[4]),.write_weight6(new_weight[5]),.write_weight7(new_weight[6]),.write_weight8(new_weight[7]),.write_weight9(new_weight[8]),.write_weight10(new_weight[9]),.write_weight11(new_weight[10]),.write_weight12(new_weight[11]),.write_weight13(new_weight[12]),.write_weight14(new_weight[13]),.write_weight15(new_weight[14]),.write_weight16(new_weight[15]),
.next_delta1(save_delta[0]),.next_delta2(save_delta[1]),.next_delta3(save_delta[2]),.next_delta4(save_delta[3]),.next_delta5(save_delta[4]),.next_delta6(save_delta[5]),.next_delta7(save_delta[6]),.next_delta8(save_delta[7]),.next_delta9(save_delta[8]),.next_delta10(save_delta[9]),.next_delta11(save_delta[10]),.next_delta12(save_delta[11]),.next_delta13(save_delta[12]),.next_delta14(save_delta[13]),.next_delta15(save_delta[14]),.next_delta16(save_delta[15]));

mux2 mux_in_1(.in1(next_delta[0]),.in2(delta3[0]),.sel(~sel_hs),.out(mux_in[0]));
mux2 mux_in_2(.in1(next_delta[1]),.in2(delta3[1]),.sel(~sel_hs),.out(mux_in[1]));
mux2 mux_in_3(.in1(next_delta[2]),.in2(delta3[2]),.sel(~sel_hs),.out(mux_in[2]));
mux2 mux_in_4(.in1(next_delta[3]),.in2(delta3[3]),.sel(~sel_hs),.out(mux_in[3]));
mux2 mux_in_5(.in1(next_delta[4]),.in2(delta3[4]),.sel(~sel_hs),.out(mux_in[4]));
mux2 mux_in_6(.in1(next_delta[5]),.in2(delta3[5]),.sel(~sel_hs),.out(mux_in[5]));
mux2 mux_in_7(.in1(next_delta[6]),.in2(delta3[6]),.sel(~sel_hs),.out(mux_in[6]));
mux2 mux_in_8(.in1(next_delta[7]),.in2(delta3[7]),.sel(~sel_hs),.out(mux_in[7]));
mux2 mux_in_9(.in1(next_delta[8]),.in2(delta3[8]),.sel(~sel_hs),.out(mux_in[8]));
mux2 mux_in_10(.in1(next_delta[9]),.in2(delta3[9]),.sel(~sel_hs),.out(mux_in[9]));
mux2 mux_in_11(.in1(next_delta[10]),.in2(delta3[10]),.sel(~sel_hs),.out(mux_in[10]));
mux2 mux_in_12(.in1(next_delta[11]),.in2(delta3[11]),.sel(~sel_hs),.out(mux_in[11]));
mux2 mux_in_13(.in1(next_delta[12]),.in2(delta3[12]),.sel(~sel_hs),.out(mux_in[12]));
mux2 mux_in_14(.in1(next_delta[13]),.in2(delta3[13]),.sel(~sel_hs),.out(mux_in[13]));
mux2 mux_in_15(.in1(next_delta[14]),.in2(delta3[14]),.sel(~sel_hs),.out(mux_in[14]));
mux2 mux_in_16(.in1(next_delta[15]),.in2(delta3[15]),.sel(~sel_hs),.out(mux_in[15]));

Dflipflopbp Dflip1(.clk(clk),.in(save_delta[0]),.enable(en_save_delta),.out(next_delta[0]));
Dflipflopbp Dflip2(.clk(clk),.in(save_delta[1]),.enable(en_save_delta),.out(next_delta[1]));
Dflipflopbp Dflip3(.clk(clk),.in(save_delta[2]),.enable(en_save_delta),.out(next_delta[2]));
Dflipflopbp Dflip4(.clk(clk),.in(save_delta[3]),.enable(en_save_delta),.out(next_delta[3]));
Dflipflopbp Dflip5(.clk(clk),.in(save_delta[4]),.enable(en_save_delta),.out(next_delta[4]));
Dflipflopbp Dflip6(.clk(clk),.in(save_delta[5]),.enable(en_save_delta),.out(next_delta[5]));
Dflipflopbp Dflip7(.clk(clk),.in(save_delta[6]),.enable(en_save_delta),.out(next_delta[6]));
Dflipflopbp Dflip8(.clk(clk),.in(save_delta[7]),.enable(en_save_delta),.out(next_delta[7]));
Dflipflopbp Dflip9(.clk(clk),.in(save_delta[8]),.enable(en_save_delta),.out(next_delta[8]));
Dflipflopbp Dflip10(.clk(clk),.in(save_delta[9]),.enable(en_save_delta),.out(next_delta[9]));
Dflipflopbp Dflip11(.clk(clk),.in(save_delta[10]),.enable(en_save_delta),.out(next_delta[10]));
Dflipflopbp Dflip12(.clk(clk),.in(save_delta[11]),.enable(en_save_delta),.out(next_delta[11]));
Dflipflopbp Dflip13(.clk(clk),.in(save_delta[12]),.enable(en_save_delta),.out(next_delta[12]));
Dflipflopbp Dflip14(.clk(clk),.in(save_delta[13]),.enable(en_save_delta),.out(next_delta[13]));
Dflipflopbp Dflip15(.clk(clk),.in(save_delta[14]),.enable(en_save_delta),.out(next_delta[14]));
Dflipflopbp Dflip16(.clk(clk),.in(save_delta[15]),.enable(en_save_delta),.out(next_delta[15]));

mux4to1_16bit mux_BRAM_1(.in1(a[0]),.in2(new_bias[0]),.in3(new_weight[0]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[0]));
mux4to1_16bit mux_BRAM_2(.in1(a[1]),.in2(new_bias[1]),.in3(new_weight[1]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[1]));
mux4to1_16bit mux_BRAM_3(.in1(a[2]),.in2(new_bias[2]),.in3(new_weight[2]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[2]));
mux4to1_16bit mux_BRAM_4(.in1(a[3]),.in2(new_bias[3]),.in3(new_weight[3]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[3]));
mux4to1_16bit mux_BRAM_5(.in1(a[4]),.in2(new_bias[4]),.in3(new_weight[4]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[4]));
mux4to1_16bit mux_BRAM_6(.in1(a[5]),.in2(new_bias[5]),.in3(new_weight[5]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[5]));
mux4to1_16bit mux_BRAM_7(.in1(a[6]),.in2(new_bias[6]),.in3(new_weight[6]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[6]));
mux4to1_16bit mux_BRAM_8(.in1(a[7]),.in2(new_bias[7]),.in3(new_weight[7]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[7]));
mux4to1_16bit mux_BRAM_9(.in1(a[8]),.in2(new_bias[8]),.in3(new_weight[8]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[8]));
mux4to1_16bit mux_BRAM_10(.in1(a[9]),.in2(new_bias[9]),.in3(new_weight[9]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[9]));
mux4to1_16bit mux_BRAM_11(.in1(a[10]),.in2(new_bias[10]),.in3(new_weight[10]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[10]));
mux4to1_16bit mux_BRAM_12(.in1(a[11]),.in2(new_bias[11]),.in3(new_weight[11]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[11]));
mux4to1_16bit mux_BRAM_13(.in1(a[12]),.in2(new_bias[12]),.in3(new_weight[12]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[12]));
mux4to1_16bit mux_BRAM_14(.in1(a[13]),.in2(new_bias[13]),.in3(new_weight[13]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[13]));
mux4to1_16bit mux_BRAM_15(.in1(a[14]),.in2(new_bias[14]),.in3(new_weight[14]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[14]));
mux4to1_16bit mux_BRAM_16(.in1(a[15]),.in2(new_bias[15]),.in3(new_weight[15]),.in4(32'h00000000),.sel(sel_BRAM_in),.out(BRAM1_in[15]));

endmodule