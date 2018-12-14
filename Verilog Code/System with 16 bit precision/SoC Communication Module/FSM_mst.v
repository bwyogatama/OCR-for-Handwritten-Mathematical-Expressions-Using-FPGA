module FSM_mst(
		clk, 
		reset, 
		training, 
		stop, 
		interrupt, 
		command, 
		arm,
		state);

input clk, reset, training, stop, interrupt;
input [1:0] command;

output reg arm;
output state;

reg [0:0] state;
reg [0:0] next_state;


parameter 	idle = 1'b0, 
			neuralnet = 1'b1;
			
//State Transition
always @(posedge clk) begin
  if (reset) begin
    state <= idle;
  end
  else begin
    state <= next_state;
  end
end

/* Next state logic */
always @(*) begin
  case (state)
  
	idle : begin
		if (interrupt==1'b0) 
		  begin
			if (command==2'b10)
				next_state = neuralnet;
			else 
				next_state = idle;
		  end
		else 
		  begin
			next_state = idle;
		  end
	end
	
	neuralnet : begin
		if (training==1'b0) 
		  begin
			if (interrupt==1'b1)
				next_state = idle;
			else
				next_state = neuralnet;
		  end
		else 
		  begin
			if (stop==1'b1)
				next_state = idle;
			else
				next_state = neuralnet;
		  end
	end
	
  endcase
end

always@(state) begin
	case (state)
		idle : begin
			arm <= 1'b0;
		end
		neuralnet : begin
			arm <= 1'b1;
		end
	endcase
end

endmodule
