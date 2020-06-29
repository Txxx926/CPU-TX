module MDctrl(
    input [31:26] instrOp,
	 input [5:0] instrFunc,
    output  Start,
    output  HiLo,
    output  We,
    output  [1:0] Op,
	 output madd
    );
	 reg [5:0] MDctrls;
	 assign {Start, HiLo, We, Op, madd}= MDctrls;
	 always@(*)
	 if(instrOp==0) 
		case (instrFunc)
		6'b011010 : MDctrls <=6'b1_0_0_11_0;//div
		6'b011011 : MDctrls <=6'b1_0_0_10_0;//divu
		6'b011000 : MDctrls <=6'b1_0_0_01_0;//mult
		6'b011001 : MDctrls <=6'b1_0_0_00_0;//multu
		6'b010000 : MDctrls <=6'b0_0_0_00_0;//mfhi
		6'b010010 : MDctrls <=6'b0_1_0_00_0;//mflo
		6'b010001 : MDctrls <=6'b0_0_1_00_0;//mthi
		6'b010011 : MDctrls <=6'b0_1_1_00_0;//mtlo
		default: MDctrls <=6'bxxxxxx;
		endcase
	      else MDctrls <=6'bxxxxxx;
	 
	 

endmodule
