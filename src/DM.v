module DM(
    input [12:2] A ,
	 input [3:0]BE,
    input [31:0] WD,
	 output [31:0] RD,
    input we,
    input clk
    );
	 integer i;
    reg [31:0] DM[2047:0];
	initial 
		begin 
			for(i=0;i<2048;i=i+1)
					DM[i] =0;
		end
	always@(posedge clk)
		if(we)
		case(BE)
			4'b1111 : DM[A][31:0]  <= WD[31:0];
			4'b0011 : DM[A][15:0]  <= WD[15:0];
			4'b1100 : DM[A][31:16] <= WD[15:0];
			4'b0001 : DM[A][7:0]   <= WD[7:0];	
			4'b0010 : DM[A][15:8]  <= WD[7:0];
			4'b0100 : DM[A][23:16] <= WD[7:0];
			4'b0001 : DM[A][31:24] <= WD[7:0];
			default : ;
		 endcase
	
	assign RD = DM[A];

endmodule
