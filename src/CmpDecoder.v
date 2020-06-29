module CmpDecoder(
	input [31:0]pCD,
    input [31:0] instrD,
    output reg [2:0] CmpOp
    );
	 always@(*)begin
	 	if(pCD!=32'h0)begin
	 case(instrD[31:26])
	 6'b000100 : CmpOp=3'b000; //beq
	 6'b000111 : CmpOp=3'b001; //bgtz
	 6'b000110 : CmpOp=3'b010; //blez
	 6'b000101 : CmpOp=3'b011; //bne
	 6'b000001 : case(instrD[20:16])
	 			5'b00001,5'b10001  : CmpOp=3'b100; //bgez、bgezal
	 			5'b00000,5'b10000  : CmpOp=3'b101; //bltz\bltzal
	 			default   : CmpOp=3'bxxx;
	 			 endcase
	 default   : CmpOp=3'bxxx; endcase
	end
	else begin
		CmpOp=3'bxxx;
	end
	end
endmodule

module CMP(
	input [31:0] pcD,
	input [31:0] instrD,
    input [31:0] A,
    input [31:0] B,
    input [2:0] Op,//表明branch的类型
    output reg Br
    );
	 always@(*)begin
	 if((pcD!=32'h0)&(instrD!=32'h0))begin
	 case(Op) 
	 3'b000 : Br=(A==B);             //beq
	 3'b001 : Br=(A[31]!=1)&(A!=0);  //bgtz
	 3'b010 : Br=(A[31]==1)|(A==0);  //blez
	 3'b011 : Br=(A!=B);         //bne
	 3'b100 : Br=(A[31]!=1);         //bgez
	 3'b101 : Br=(A[31]==1);         //bltz
	 default: Br=1'bx; 
	  endcase
	end
	else begin
		Br=1'bx;
	end
	 end


endmodule
