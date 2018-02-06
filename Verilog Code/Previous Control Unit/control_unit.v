////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Institution   : Bandung Institute of Technology
// Engineer      : Jhonson Lee, Bobbi W. Yogatama, Hans Christian
//
// Create Date   : 31/1/2018 
// Design Name   : Control Unit for Forward and Backpropagation in Neural Networks
// Module Name   : control_unit
// Project Name  : LSI Design Contest in Okinawa 2018
// Target Devices: Zynq 7000
// Tool versions : Vivado v.2016.4
//
// Description: 
// 		Generating control signal controlling the whole operation
// 
//
// Revision: 
// Revision 0.01 - File Created
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit
		(clk,
		 reset,
		 arm,
		 train,
		 stop,
		 
		 selector_input,
		 enable_b,
		 enable_z,
		 enable_a,
		 selector_a,
		 enable_rounding,
		 finish,
		 selector_z_in,
		 
		 iteration_cplt,
		 enable_read_a,
		 enable_write_w,
		 enable_delta,
		 enable_calc_delta,
		 sel_a_select,
		 select_k,
		 sel_a_or_k,
		 en_k_reg,
		 en_save_delta,
		 en_b_back,
		 enable_supervisor,
		 en_delta3,
		 en_cost,
		 enable_BRAM1,
		 enable_BRAM2,
		 we_BRAM1,
		 sel_hs,
		 sel_BRAM_in,
		 address_1,
		 address_2);

parameter DWIDTH=32;							
parameter AWIDTH=10;								
parameter IWIDTH=64;
parameter HiddenNeuron=16;
parameter x=4;
parameter Layer=3;

input clk,reset,train,arm,stop;
input [15:0] iteration_cplt;
output reg enable_read_a,enable_write_w,enable_delta,en_save_delta,en_b_back,en_delta3,en_cost,sel_hs,sel_a_or_k,en_k_reg,enable_supervisor;
output reg [1:0] sel_BRAM_in;
output [5:0] select_k;
output [3:0] sel_a_select;
output [15:0] enable_calc_delta;
output reg [AWIDTH-1:0] address_1;
output reg [12:0] address_2 = 13'b0000000000000;
output reg [15:0] enable_BRAM1,  we_BRAM1;
output reg [0:0] enable_BRAM2;
 
//sinyal train untuk membedakan antara mode training dan test, kalo mode training berarti train = 1
output [5:0] selector_input; 
//enable_wx buat enable register buat nyimpen nilai w di layer x. Ada 4 bit karena di masing masing layer ada 4 register.
//Selector_input buat jadi selector multiplexer yang bakal milih 4 input dari 64 neuron input. 
output reg [0:0] enable_b, enable_a;
//Enable_b buat selector multiplexer yang bakal milih antara nilai bias ato nilai penjumlahan (kalo nilainya 1 berarti bias dipilih)
output reg [1:0] enable_z;
output[3:0] selector_a;

output reg enable_rounding;
//enable_rounding buat rounding nilai a3
output reg finish;
//sinyal finish menandakan proses identifikasi telah selesai
output reg selector_z_in;


reg [1:0] counter = 2'b11;
reg [3:0] counter_G;
reg [15:0] counter_K;
reg [15:0] mask;
reg [5:0] counter_M;


reg [5:0] state = 6'b000000;
reg [5:0] next_state = 6'b000000;
reg [5:0] counter_A;
reg [3:0] counter_C;
reg [3:0] counter_E;
reg [0:0] selector_l;


parameter S1 		= 6'b000000, 
		  S2_bias 	= 6'b000001, 
		  S2_w		= 6'b000010, 
		  S2_save 	= 6'b000011,
		  S2_act 	= 6'b000100, 
		  S2_storeA = 6'b000101, 
		  S3_bias 	= 6'b000110, 
		  S3_w 		= 6'b000111,
		  S3_save 	= 6'b001000, 
		  S3_act 	= 6'b001001, 
		  S3_storeA = 6'b001010, 
		  S4_bias 	= 6'b001011,
		  S4_w 		= 6'b001100, 
		  S4_save 	= 6'b001101, 
		  S4_act 	= 6'b001110, 
		  S4_storeA = 6'b001111,
		  S5 		= 6'b010000;
		  
parameter SB1_1		= 6'b010001;
parameter SB2_1		= 6'b010010;
parameter SB2_2		= 6'b010011;
parameter SB3_1		= 6'b010100;
parameter SB3_2		= 6'b010101;
parameter SB3_3		= 6'b010110;
parameter SB3_4		= 6'b010111;
parameter SB4_1		= 6'b011000;
parameter SB4_2		= 6'b011001;
parameter SB5_1		= 6'b011010;
parameter SB5_2		= 6'b011011;
parameter SB5_3		= 6'b011100;
parameter SB5_4		= 6'b011101;
parameter SB6_1		= 6'b011110;
parameter SB6_2		= 6'b011111;
parameter SB7_1		= 6'b100000;
parameter SB7_2		= 6'b100001;


//State Transition
always @(posedge clk) begin
  if (reset) begin
    state <= S1;
  end
  else begin
    state <= next_state;
  end
end

always @(*) begin
	case (state) 
		S1: begin
		  next_state = ((counter==2'b11)&&(arm)) ? S2_bias : S1;
		end
		S2_bias: begin
		  next_state = (counter==2'b11) ? S2_w : S2_bias; 
		end
		S2_w: begin
		  next_state = (counter==2'b11) ? S2_save : S2_w ;
		end
		S2_save: begin
		  next_state = (counter==2'b11) ? ((counter_A==6'b111111) ? S2_act : S2_w) : S2_save;
		end
		S2_act: begin
		  next_state = (counter==2'b11) ? S2_storeA : S2_act;
		end
		S2_storeA: begin
		  next_state = (counter==2'b11) ? S3_bias : S2_storeA;
		end
		S3_bias: begin
		  next_state = (counter==2'b11) ? S3_w : S3_bias;
		end
		S3_w: begin
		  next_state = (counter==2'b11) ? S3_save : S3_w;
		end
		S3_save: begin
		  next_state = (counter==2'b11) ? ( (counter_C==4'b1111) ? S3_act : S3_w) : S3_save;
		end
		S3_act: begin
		  next_state = (counter==2'b11) ? S3_storeA : S3_act;
		end
		S3_storeA: begin
		  next_state = (counter==2'b11) ? S4_bias : S3_storeA;
		end
		S4_bias: begin
		  next_state = (counter==2'b11) ? S4_w : S4_bias;
		end
		S4_w: begin
		  next_state = (counter==2'b11) ? S4_save : S4_w;
		end
		S4_save: begin
		  next_state = (counter==2'b11) ? ( (counter_E == 4'b1111) ? S4_act : S4_w) : S4_save;
		end
		S4_act: begin
		  next_state = (counter==2'b11) ? S4_storeA : S4_act;
		end
		S4_storeA: begin
		  next_state =  (counter==2'b11) ? (train ? SB1_1 : S5) : S4_storeA;
		end
		S5: begin
		  next_state = (counter==2'b11) ? S1 : S5;
		end
		SB1_1: begin
			next_state=(counter==2'b11) ? SB2_1 : SB1_1;
		end
		SB2_1: begin
			next_state=(counter==2'b11) ? SB2_2 : SB2_1;		
		end
		SB2_2: begin
			next_state=(counter==2'b11) ? SB3_1 : SB2_2;			
		end
		SB3_1: begin
			next_state=(counter==2'b11) ? SB3_2 : SB3_1;	
		end
		SB3_2: begin
			next_state=(counter==2'b11) ? SB3_3 : SB3_2;	
		end
		SB3_3: begin
			next_state=(counter==2'b11) ? ((counter_G==4'b1111)? SB3_4 : SB3_2) : SB3_3;
		end
		SB3_4: begin
			next_state=(counter==2'b11) ? SB4_1 : SB3_4;
		end
		SB4_1: begin
			next_state=(counter==2'b11) ? SB4_2 : SB4_1;
		end
		SB4_2: begin
			next_state=(counter==2'b11) ? SB5_1 : SB4_2;
		end
		SB5_1: begin
			next_state=(counter==2'b11) ? SB5_2 : SB5_1;
		end
		SB5_2: begin
			next_state=(counter==2'b11) ? SB5_3 : SB5_2;
		end
		SB5_3: begin
			next_state=(counter==2'b11) ? ((counter_G==4'b1111)? SB5_4 : SB5_2) : SB5_3;
		end
		SB5_4: begin
			next_state=(counter==2'b11) ? SB6_1 : SB5_4;
		end
		SB6_1: begin
			next_state=(counter==2'b11) ? SB6_2 : SB6_1;
		end
		SB6_2: begin
			next_state=(counter==2'b11) ? SB7_1 : SB6_2;
		end
		SB7_1: begin
			next_state=(counter==2'b11) ? SB7_2 : SB7_1;
		end
		SB7_2: begin
			next_state=(counter==2'b11) ? ((counter_M==6'b111111)? S1 : SB7_1) : SB7_2;
		end
		default : begin
			next_state = S1;
		end
	endcase
end


always @(posedge clk) begin
	if (reset) begin
		counter 	<= 2'b11;
		counter_G 	<= 4'b1111;
		counter_K	<= 16'b0000000000000000;
		counter_M	<= 6'b111111;
		address_2   <= 13'b0000000000000;
	end
	else 
	begin
		// Counter 4 clock
		counter <= counter + 1;
		
		//Counter input 64 cycles for Hidden Layer 1
		if (state==S1) begin
			counter_A <= 6'b111111;
		end
		else if ((state==S2_bias) && (next_state==S2_w)) begin
			counter_A <= counter_A + 1;
		end
		else if ((state==S2_save) && (next_state==S2_w)) begin
			counter_A <= counter_A + 1;
		end
		
		//Counter 16 cycles for Hidden Layer 2
		if (state==S2_storeA) begin
			counter_C <= 4'b1111;
		end
		else if ((state==S3_bias) && (next_state==S3_w)) begin
			counter_C <= counter_C + 1;
		end
		else if ((state==S3_save) && (next_state==S3_w)) begin
			counter_C <= counter_C + 1;
		end
		
		//Counter 16 cycles for Output Layer
		if (state==S3_storeA) begin
			counter_E <= 4'b1111;
		end
		else if ((state==S4_bias) && (next_state==S4_w)) begin
			counter_E <= counter_E + 1;
		end
		else if ((state==S4_save) && (next_state==S4_w)) begin
			counter_E <= counter_E + 1;
		end
		
		//Address BRAM
		if ((state==S1) && (next_state==S2_bias)) begin
			address_1		<= 10'b0000000000;
		end
		else if ((state==S2_bias) && (next_state==S2_w)) begin
			address_1		<= 10'b0001000000;
		end
		else if ((state==S2_save) && (next_state==S2_w)) begin
			address_1		<= address_1 + 10'b0000000001;
		end
		else if ((state==S2_act) && (next_state==S2_storeA)) begin
			address_1		<= 10'b0010000000;
		end
		else if ((state==S2_storeA) && (next_state==S3_bias)) begin
			address_1		<= 10'b0100000000;
		end
		else if ((state==S3_bias) && (next_state==S3_w)) begin
			address_1		<= 10'b0101000000;
		end
		else if ((state==S3_save) && (next_state==S3_w)) begin
			address_1		<= address_1 + 10'b0000000001;
		end
		else if ((state==S3_act) && (next_state==S3_storeA)) begin
			address_1		<= 10'b0110000000;
		end
		else if ((state==S3_storeA) && (next_state==S4_bias)) begin
			address_1		<= 10'b1000000000;
		end
		else if ((state==S4_bias) && (next_state==S4_w)) begin
			address_1		<= 10'b1001000000;
		end
		else if ((state==S4_save) && (next_state==S4_w)) begin
			address_1		<= address_1 + 10'b0000000001;
		end
		else if ((state==S4_act) && (next_state==S4_storeA)) begin
			address_1		<= 10'b1010000000;
		end
		
		
		if (state==S1) begin
			counter_G 	<= 4'b1111;
			counter_K	<= 16'b0000000000000000;
			counter_M	<= 6'b111111;
			address_2 	<= ((stop) || (address_2 == iteration_cplt[12:0])) 
						   ? 13'b0000000000000 
						   : address_2;
		end
		
		else if ((state==SB1_1)&&(next_state==SB2_1)) begin
			address_1 <= 10'b1000000000;
		end
		
		else if ((state==SB2_2)&&(next_state==SB3_1)) begin
			counter_G <= 4'b1111;
			address_1 <= 10'b0110000000;
		end
		
		else if ((state==SB3_1)&&(next_state==SB3_2)) begin
			counter_K <= 16'b0000000000000000;
			mask	  <= 16'b0000000000000001;
			counter_G <= counter_G +1;
			address_1 <= 10'b1001000000;
		end

		else if ((state==SB3_2)&&(next_state==SB3_3))begin
			counter_K <= mask;
		end
		
		else if ((state==SB3_3)&&(next_state == SB3_2)) begin
			counter_K <= 16'b0000000000000000;
			mask	  <= mask<<1;
			address_1 <= address_1+1;
			counter_G <= counter_G+1;
		end
		
		else if ((state==SB3_3)&&(next_state==SB3_4)) begin
			counter_K <= 16'b0000000000000000;
			address_1 <= 10'b0100000000;
			counter_G <= 4'b1111;
		end
		
		else if ((state==SB4_2)&&(next_state==SB5_1)) begin
			address_1 <= 10'b0010000000;
		end
		
		else if ((state==SB5_1)&&(next_state==SB5_2)) begin
			counter_G <= counter_G+1;
			counter_K <= 16'b0000000000000000;
			mask	  <= 16'b0000000000000001;
			address_1 <= 10'b0101000000;
		end
		
		else if ((state==SB5_2) && (next_state==SB5_3)) begin
			counter_K <= mask;
		end
		
		else if ((state==SB5_3) && (next_state==SB5_2)) begin
			counter_K <= 16'b0000000000000000;
			mask	  <= mask<<1;
			address_1 <= address_1+1;
			counter_G <= counter_G+1;
		end
		
		else if ((state==SB5_3) && (next_state==SB5_4)) begin
			address_1 <= 10'b0000000000;
			counter_G <= 4'b1111;
			counter_M <= 6'b111111;
			counter_K <= 16'b000000000000000;
		end
		
		else if ((state==SB6_2)&&(next_state==SB7_1)) begin
			address_1 <= 10'b0001000000;
			counter_M <= counter_M+1;
		end
		
		else if ((state==SB7_2) && (next_state==SB7_1)) begin
			counter_M <= counter_M + 1;
			address_1 <= address_1+1;
		end
		
		else if ((state==SB7_2)&&(next_state==S1)) begin
			counter_K <= 16'b0000000000000000;
			counter_G <= 4'b1111;
			counter_M <= 6'b111111;
			address_2 <= address_2 + 1;
		end
	end
end

//multi-bit Combinational output
assign selector_input = counter_A;
assign selector_a = selector_l ? counter_E : counter_C;

assign sel_a_select = counter_G;
assign enable_calc_delta = counter_K;
assign select_k = counter_M;

always @(state, train) begin
	case (state)
	S1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM1 	<= 16'b0000000000000000;
		enable_BRAM2 	<= train;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 1;
		enable_supervisor <= 1;
		
	end
	S2_bias:begin
		enable_b		<= 1'b1;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		finish			<= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S2_w:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b10;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S2_save:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S2_act:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b1;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;		
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S2_storeA:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b1111111111111111;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S3_bias:begin
		enable_b		<= 1'b1;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111; 
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S3_w:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b10;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S3_save:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S3_act:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b1;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S3_storeA:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b1111111111111111;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S4_bias:begin
		enable_b		<= 1'b1;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S4_w:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b10;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S4_save:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b01;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S4_act:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b1;
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S4_storeA:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_BRAM1		<= 16'b1111111111111111;
		we_BRAM1			<= 16'b1111111111111111;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		finish			<= 1'b0;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	S5:begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0; 
		enable_BRAM1		<= 16'b0000000000000000;
		we_BRAM1			<= 16'b0000000000000000;		
		enable_rounding <= 1'b1;
		finish 			<= 1'b1;
		selector_z_in   <= 1'b1;
		selector_l		<= 1'b1;
		
		enable_BRAM2 	<= 0;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end	
	SB1_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b0000000000000000;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 1;
		en_cost 		<= 1;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 1;
	end
	SB2_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 1;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB2_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB3_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 1;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB3_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 1;
		enable_delta 	<= 1;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB3_3: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB3_4: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b0000000000000000;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 1;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB4_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 1;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB4_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB5_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 1;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB5_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 1;
		enable_delta 	<= 1;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB5_3: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB5_4: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b0000000000000000;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 1;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB6_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 1;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB6_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB7_1: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
	
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 1;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b01;
		sel_a_or_k 		<= 1;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	SB7_2: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b1;
		
		
		enable_BRAM1 	<= 16'b1111111111111111;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b1111111111111111;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 1;
		sel_BRAM_in 	<= 2'b10;
		sel_a_or_k 		<= 1;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
	end
	default: begin
		enable_b		<= 1'b0;
		enable_z		<= 2'b00;
		enable_a		<= 1'b0;
		enable_rounding <= 1'b0;
		selector_z_in   <= 1'b0;
		selector_l		<= 1'b0;
		finish			<= 1'b0;
		
		enable_BRAM1 	<= 16'b0000000000000000;
		enable_BRAM2 	<= 0;
		we_BRAM1 		<= 16'b0000000000000000;
		enable_read_a 	<= 0;
		enable_write_w 	<= 0;
		enable_delta 	<= 0;
		en_save_delta 	<= 0;
		en_b_back 		<= 0;
		en_delta3 		<= 0;
		en_cost 		<= 0;
		sel_hs 			<= 0;
		sel_BRAM_in 	<= 2'b00;
		sel_a_or_k 		<= 0;
		en_k_reg 		<= 0;
		enable_supervisor <= 0;
		
	end
	
	
	endcase
end

endmodule
