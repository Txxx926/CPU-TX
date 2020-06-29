module alu(
	input [31:0] instr,
    input [31:0] A,
    input [31:0] B,
    input [3:0] Op,
    input [31:0] Excption_E_1,
    output reg[31:0]Excption_E_2,
    output reg [31:0] C,
	 output reg Over
	 );
	 reg C32;	 
	 always@(*)
		 begin 
		 	 Over=0;                           
			 case (Op)
			 4'b0000: C=A+B; //无符号立即数加法或者加法		
			 4'b0001: C=A&B; //与
			 4'b0010: C=A^B; //异或
			 4'b0101: C=A|B; //或
			 4'b1110: C=~(A|B);//或非
			 4'b0011: C=B<<A[4:0];
			 4'b1000: C=A-B;  //无符号减法
			 4'b0110: C={B[15:0],16'b0}; //lui
			 4'b0111: C=B>>A[4:0]; // logical shift is add 0!
			 4'b1111: C=$signed(B)>>>A[4:0]; // mathtical shift is add gpr[31]
			 4'b0100: begin {C32,C}={A[31],A}-{B[31],B};
								  Over=(C32!=C[31]);  end    //带符号减法
			 4'b1001: begin {C32,C}={A[31],A}+{B[31],B};   
								  Over=(C32!=C[31]);  end	  //有符号加法
			 default : C = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
			 endcase
	   end
	   wire is_slt;
	   assign is_slt=(instr[31:26]==6'b000000)&(instr[5:0]==6'b101010);
	  always @(*) begin
	  	if(Over)begin
	  		if(!is_slt)begin
	  		Excption_E_2<={Excption_E_1[31:4],1'b1,Excption_E_1[2:0]};
	  	end 
	  	else begin
	  		Excption_E_2<=Excption_E_1;
	  	end
	  	end 
	  	else begin
	  		Excption_E_2<=Excption_E_1;
	  	end
	  end
endmodule

module adder(
    input [31:0] A,
    input [31:0] B,
    output [31:0] Y
    );
assign Y=A+B;

endmodule

module ext(
	 input ext,
    input [15:0] a,
    output [31:0] b
    );
	 reg [31:0] temp;
	 assign b=temp;
	 always@(*)
	 
	  begin 
	    case(ext)
		 0 : temp={16'b0,a};
		 1 : temp={{16{a[15]}},a};
		 endcase
		end

endmodule