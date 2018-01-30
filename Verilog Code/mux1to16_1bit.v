module mux1to16_1bit(
	input wire in,
	input wire [3:0] sel,
	output reg [15:0] out
	);
	
always@(*) begin
    if (in) begin
       if (sel==4'b0000) out <= 16'b0000000000000001;
       else if (sel==4'b0001) out <= 16'b0000000000000010;
       else if (sel==4'b0010) out <= 16'b0000000000000100;
       else if (sel==4'b0011) out <= 16'b0000000000001000;
       else if (sel==4'b0100) out <= 16'b0000000000010000;
       else if (sel==4'b0101) out <= 16'b0000000000100000;
       else if (sel==4'b0110) out <= 16'b0000000001000000;
       else if (sel==4'b0111) out <= 16'b0000000010000000;
       else if (sel==4'b1000) out <= 16'b0000000100000000;
       else if (sel==4'b1001) out <= 16'b0000001000000000;
       else if (sel==4'b1010) out <= 16'b0000010000000000;
       else if (sel==4'b1011) out <= 16'b0000100000000000;
       else if (sel==4'b1100) out <= 16'b0001000000000000;
       else if (sel==4'b1101) out <= 16'b0010000000000000;
       else if (sel==4'b1110) out <= 16'b0100000000000000;
       else if (sel==4'b1111) out <= 16'b1000000000000000;
    end
    else begin
        out = 16'b0000000000000000;
    end
end

endmodule