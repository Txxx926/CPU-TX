module mdu(
    input [31:0] D1,
    input [31:0] D2,
    input HiLo,
    input [1:0] Op,
    input Start,
    input We,	 
    output Busy,
	 input madd,
    output   [31:0] HI,
    output   [31:0] LO,
    input Clk,
    input resetn,
    input if_exception
    );
	 reg [63:0]temp1,temp2;
	 reg [63:0]temp;
	 integer delay=0;
	 reg [31:0]MDu[1:0];
	 initial begin 
	 MDu[0]=0; MDu[1]=0;
	 end 
	 assign Busy=(delay!=0);
	 always@(posedge Clk) begin
		if(!resetn) begin MDu[0]=0; MDu[1]=0; delay=0;end
		else begin if(We) begin
						case(HiLo)
						1'b0 : MDu[0] =D1;
						1'b1 : MDu[1] =D1;
						endcase
						delay=1;
						end
						
						if(Start&!if_exception)
						case (Op)
						2'b00 : begin { MDu[0], MDu[1]} = D1*D2; delay=5; end    //delay=5 ，无符号乘法
						2'b01 : begin { MDu[0], MDu[1]} = $signed(D1)*$signed(D2);  delay=5; end//有符号乘法
						2'b10 : begin  MDu[0] = D1%D2;  MDu[1]= D1/D2; delay=10;   end //delay=10 
						2'b11 : begin  MDu[0] = $signed(D1)%$signed(D2); 
										   MDu[1] = $signed(D1)/$signed(D2); 
										   delay=10; end
						endcase   
						if(madd) begin 
						               temp1= $signed(D1)*$signed(D2);
								         temp2={MDu[0], MDu[1]};
											temp=temp1+temp2;
											MDu[0] =temp[63:32];
											MDu[1] =temp[31:0];
											
								/* {MDu[0],Mdu[1]}=$signed(D1)*$signed(D2)+{MDu[0], MDu[1]} */
											
										delay=5; end
						if(delay>0) delay = delay-1;						
				end
	 end
	 assign HI=MDu[0];
	 assign LO=MDu[1];
endmodule
