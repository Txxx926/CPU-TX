module ctrl(
    input [5:0] op,
    input [5:0] func,
    input [31:0] PCD_in,
    input [31:0]InstuctionD,
    input flushD,
    input  Br,
    input EX_is_Branch,
    output   wmem,
    output  wreg,
    output  [3:0] aluc,
    output  shift,
	 output  ext,
    output  aluimm,
    output  [1:0] pcsource,
    output   reg This_is_Branch,//传�?�到EX阶段
    output  this_is_in_delayslot,//传�?�到EX阶段
    output  reg [31:0]Exception,
    output  [1:0] data2reg,
    output  [1:0] regdst,
    output reg WCP0,
    output reg Read_CP0,
    output reg [4:0]Read_CP0_Addr,
    output reg [4:0] Write_CP0_Addr
    );
	 reg [14:0]control;
	 wire syscall;
	 wire Break;
	 wire eret;
	 wire mtc0;
	 wire mfc0;//

//Exception 32位，如果是syscall，则�?0位为1；如果是Break，则�?1位为1；如果是Eret，则�?2位为1；如果是OVerflow，则�?3位为1，如果是Address_error，则�?4位为1
	 assign {wmem,wreg,aluc,shift,aluimm,ext,pcsource, data2reg, regdst}=(flushD)?15'h0:control;
	 assign this_is_in_delayslot =EX_is_Branch ;
	 assign  syscall=(op==6'b000000)&(func==6'b001100) ;
	 assign  Break = (op==6'b000000)&(func==6'b001101);
	 assign eret=(op==6'b010000)&(func==6'b011000);
	 assign mtc0 = (InstuctionD[31:21]==11'b01000000100)&(InstuctionD[10:3]==8'b00000000);
	 assign mfc0 = (InstuctionD[31:21]==11'b01000000000)&(InstuctionD[10:3]==8'b00000000);
	 always @(*) begin
	 	Exception=32'h0;
	 	if(PCD_in[1:0]!=2'b00&(PCD_in!=32'h0-32'd4))begin
	 		Exception={26'h0,1'b1,5'b0};
	 	end
	 	if(syscall)begin
	 		Exception={31'h0,1'b1};
	 	end
	 	if(Break)begin
	 		Exception={30'h0,1'b1,1'b0};
	 	end
	 	if(eret)begin
	 		Exception={29'h0,1'b1,2'b00};
	 	end
	 end
	 always@(*)
	  begin
	  	This_is_Branch<=1'b0;
	  	WCP0<=1'b0;
	  	Read_CP0<=1'b0;
	  	Read_CP0_Addr<=5'bxxxxx;
	  	Write_CP0_Addr<=5'bxxxxx;
	  	//Exception=32'h0;
	  	if(mtc0)begin
	  		WCP0<=1'b1;
	  		Write_CP0_Addr<=InstuctionD[15:11];
	  		control<=15'b0_0_0000_0_0_0_00_11_11;
	  	end
	  	else if(mfc0)begin
	  		Read_CP0<=1'b1;
	  		Read_CP0_Addr<=InstuctionD[15:11];
	  		control<=15'b0_1_0000_0_0_0_00_11_00;//!!!!
	  	end
	  	else begin
	  	if(PCD_in[1:0]!=2'b00)begin
	  		control<=15'b0_0_1000_0_0_0_00_00_11;
	  	end
	  	else begin
		case(op)
			//wmem,wreg,aluc,shift,aluimm, ext, pcsource, data2reg, regdst 
					   
			//写MEMmory。写寄存器，alu的运算类型（4位），是否是移动指令，alu二操作数是否是立即数，拓展类型，下一个pc来源�?2位），写�?寄存器数据来源（2位），写寄存器的地址
			6'b100011 : control <= 15'b0_1_0000_0_1_1_00_01_00;//lw
			6'b100000 : control <= 15'b0_1_0000_0_1_1_00_01_00;//lb
			6'b100100 : control <= 15'b0_1_0000_0_1_1_00_01_00;//lbu
			6'b100001 : control <= 15'b0_1_0000_0_1_1_00_01_00;//lh
			6'b100101 : control <= 15'b0_1_0000_0_1_1_00_01_00;//lhu
			6'b101011 : control <= 15'b1_0_0000_0_1_1_00_00_11;//sw
			6'b101000 : control <= 15'b1_0_0000_0_1_1_00_00_11;//sb
			6'b101001 : control <= 15'b1_0_0000_0_1_1_00_00_11;//sh
			//{wmem,wreg,aluc,shift,aluimm,ext,pcsource, data2reg, regdst}
			6'b000100 :begin 
						 if(Br) begin control <= 15'b0_0_1000_0_0_1_01_00_11;end
					     else  begin control <= 15'b0_0_1000_0_0_1_00_00_11; end//beq
					     This_is_Branch<=1'b1;
					   end
			6'b000101 :begin if(Br)begin  control <= 15'b0_0_1000_0_0_1_01_00_11; end
						  else   begin control <= 15'b0_0_1000_0_0_1_00_00_11;end //bne
						  This_is_Branch<=1'b1;
						end
			6'b000111 :begin if(Br) begin control <= 15'b0_0_1000_0_0_1_01_00_11; end
						  else  begin  control <= 15'b0_0_1000_0_0_1_00_00_11; end//bgtz 
						  This_is_Branch<=1'b1;
					   end
			6'b000001 :begin
							case(InstuctionD[20:16])
							5'b00000,5'b00001:
								begin if(Br) begin control <= 15'b0_0_1000_0_0_1_01_00_11;  end
					     		else  begin control <= 15'b0_0_1000_0_0_1_00_00_11; end//bgez & bltz
					     		This_is_Branch<=1'b1;
					    		end
					    	5'b10001,5'b10000://bgezal,bltzal
					    		begin
					    		if(Br)begin
					    			control<=15'b0_1_1000_0_0_1_01_10_10;
					    		end
					    		else begin
					    			control<=15'b0_1_1000_0_0_1_00_10_10;
					    		end
					    
					    		This_is_Branch<=1'b1;
					    		end
					    	endcase
					    end
			6'b000110 :begin if(Br)begin  control <= 15'b0_0_1000_0_0_1_01_00_11; end
					     else  begin  control <= 15'b0_0_1000_0_0_1_00_00_11; end//blez
					     This_is_Branch<=1'b1;
					   end
	
				
			6'b000010 : begin control <= 15'b0_0_0000_0_0_0_11_00_00; 
						This_is_Branch<=1'b1;
						end//j
			6'b000011 : begin control <= 15'b0_1_0000_0_0_0_11_10_10;//jal
						This_is_Branch<=1'b1;
						end
			
			6'b001111 : control <= 15'b0_1_0110_0_1_0_00_00_00;//lui
			6'b001000 : control <= 15'b0_1_1001_0_1_1_00_00_00;//addi
			6'b001001 : control <= 15'b0_1_0000_0_1_1_00_00_00;//addiu
			6'b001100 : control <= 15'b0_1_0001_0_1_0_00_00_00;//andi
			6'b001101 : control <= 15'b0_1_0101_0_1_0_00_00_00;//ori
			6'b001110 : control <= 15'b0_1_0010_0_1_0_00_00_00;//xori
			
			6'b001010 : control <= 15'b0_1_0100_0_1_1_00_00_00;//slti
		    6'b001011 : control <= 15'b0_1_1000_0_1_1_00_00_00;//sltiu
			
			6'b010000:control<=15'b0_0_0000_0_0_0_00_00_00;//eret
			6'b000000 : //R
			    begin
					case(func)
					   //wmem,wreg,aluc,shift,aluimm, ext, pcsource, data2reg, regdst 
					   
						6'b100000 : control <= 15'b0_1_1001_0_0_0_00_00_01;//add
						6'b100001 : control <= 15'b0_1_0000_0_0_0_00_00_01;//addu
						6'b100010 : control <= 15'b0_1_0100_0_0_0_00_00_01;//sub
						6'b100011 : control <= 15'b0_1_1000_0_0_0_00_00_01;//subu
						6'b100100 : control <= 15'b0_1_0001_0_0_0_00_00_01;//and
						6'b100101 : control <= 15'b0_1_0101_0_0_0_00_00_01;//or
						6'b100110 : control <= 15'b0_1_0010_0_0_0_00_00_01;//xor						
						6'b100111 : control <= 15'b0_1_1110_0_0_0_00_00_01;//nor
						
						6'b000000 : control <= 15'b0_1_0011_1_0_0_00_00_01;//sll
						6'b000010 : control <= 15'b0_1_0111_1_0_0_00_00_01;//srl
						6'b000011 : control <= 15'b0_1_1111_1_0_0_00_00_01;//sra
						6'b000100 : control <= 15'b0_1_0011_0_0_0_00_00_01;//sllv
						6'b000110 : control <= 15'b0_1_0111_0_0_0_00_00_01;//srlv
						6'b000111 : control <= 15'b0_1_1111_0_0_0_00_00_01;//srav
						
						//wmem,wreg,aluc,shift,aluimm, ext, pcsource, data2reg, regdst 
						
						6'b001000 : begin control <= 15'b0_0_0000_0_0_0_10_00_00;//jr
						This_is_Branch<=1'b1;
						end
						6'b001001 : begin control <= 15'b0_1_0000_0_0_0_10_10_01;//jalr
						This_is_Branch<=1'b1;
						end
						
						
						6'b101010 : control <= 15'b0_1_0100_0_0_0_00_00_01;//slt
						6'b101011 : control <= 15'b0_1_1000_0_0_0_00_00_01;//sltu
						
						6'b001101: control<=15'b0_0_0000_0_0_0_00_00_00;//Break;
						6'b001100:control<=15'b0_0_0000_0_0_0_00_00_00;//Syscall;
						
						6'b011010 : control <= 15'b0_0_0000_0_0_0_00_00_11;//div
						6'b011011 : control <= 15'b0_0_0000_0_0_0_00_00_11;//divu
						6'b011000 : control <= 15'b0_0_0000_0_0_0_00_00_11;//mult
						6'b011001 : control <= 15'b0_0_0000_0_0_0_00_00_11;//multu
						6'b010000 : control <= 15'b0_1_0000_0_0_0_00_00_01;//mfhi
						6'b010010 : control <= 15'b0_1_0000_0_0_0_00_00_01;//mflo
						6'b010001 : control <= 15'b0_0_0000_0_0_0_00_00_00;//mthi
						6'b010011 : control <= 15'b0_0_0000_0_0_0_00_00_00;//mtlo
						6'b000000 : control <= 15'b0_0_0000_0_0_0_00_00_00;//nop
						default : control <= 15'bxxxxxxxxxxxxxxx;
						
					endcase
				 end
				default : begin control <= 15'bxxxxxxxxxxxxxxx;
					Exception={25'h0,1'b1,6'b0};
				end
			endcase
			end
		end
		end


endmodule