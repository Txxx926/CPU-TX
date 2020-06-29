module ALUChoose(
    input [31:0] instrE, 
    input [31:0] aluA, aluB, aluoutE, HI, LO,
    output reg [31:0] Real_aluoutE
    );
	 wire [31:0] sub;
	 wire Csign, C0;
	 wire sltU, slt, mfhi, mflo; 
	 wire [3:0] ctrls;
	 
	 assign ctrls={sltU, slt, mfhi, mflo};
	 assign slt =(instrE[31:26]==6'b001010)| (instrE[31:26]==6'b000000 & instrE[5:0]==6'b101010 );//sign
	 assign sltU=(instrE[31:26]==6'b001011)| (instrE[31:26]==6'b000000 & instrE[5:0]==6'b101011 );//no sign
	 assign mfhi=(instrE[31:26]==6'b000000 & instrE[5:0]==6'b010000 );//mfhi
	 assign mflo=(instrE[31:26]==6'b000000 & instrE[5:0]==6'b010010 );//mflo
	 
	 
	 assign {Csign,sub}={aluA[31],aluA}-{aluB[31],aluB};
	 assign {C0,sub}={0,aluA}-{0,aluB};
	 
	 always@(*)
			 case(ctrls)
			 4'b0000 : Real_aluoutE=aluoutE;
			 4'b1000 : Real_aluoutE={31'b0,C0};//sltu
			 6'b0100 : Real_aluoutE={31'b0,Csign};   //slt
			 4'b0010 : Real_aluoutE=HI;//mfhi
			 4'b0001 : Real_aluoutE=LO;//mflo
			 default : Real_aluoutE=aluoutE;
			 endcase
endmodule
