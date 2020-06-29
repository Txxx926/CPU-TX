module Judge(
	 input [31:0] instrD,
    input [31:0] A,
    input [31:0] B,
    output reg [1:0] Zero
    );
	 reg [31:0] out;
	 always@(*)
	  case (instrD[31:26])
	    6'b000111 : out <= A;
		 default   : out <= A-B;
		endcase
		
	 always@(*) begin
	 if(out==0) Zero <= 00;
		 else begin
					if(out[31]==1) Zero <= 01;
					else Zero <= 10;
				end
	 end

endmodule
