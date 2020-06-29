module Stall(
		input [31:0]instrD, instrE,instrM,instrW,
		input [31:0] pcd,
		input [4:0] WAE, WAM, WAW,
		input wregE, wregM, wregW,
		input [1:0] data2regE, data2regM,
		input Busy,
		input exception,
		input [4:0]exception_type,
		input [1:0]pcsourceD,
		output stallPC, stallD, flushD,flushE,flushM
		);
		

		wire beqD, bgtzD, JD, MdD;
		wire lwstallD, beqstallD, bgtzstallD, JrstallD, MDstallD;
		wire mfhiE,mfloE,mfc0E,mfc0M;
		wire is_wired_pc;
		assign is_wired_pc=(pcd==32'h0xb27f9789);
		
		assign beqD =(instrD[31:26]== 6'b000100) | (instrD[31:26]== 6'b000101);   //beq bne
		assign bgtzD=(instrD[31:26]== 6'b000001) | (instrD[31:26]== 6'b000111)|   //bgez bltz bgtz
						 (instrD[31:26]== 6'b000110);	 //blez	 
		assign JD   =((instrD[31:26]==6'b000000) & (instrD[5:0] == 6'b001000))|   //jr
			         ((instrD[31:26]== 6'b000000) & (instrD[5:0] == 6'b001001));   //jarl
	   assign MdD  =(instrD[31:26]== 6'b000000)&(
					    (instrD[5:0] == 6'b011010)| (instrD[5:0] == 6'b011011)|		  //div divu								  //divu
						 (instrD[5:0] == 6'b011000)| (instrD[5:0] == 6'b011001)|      //mult multu
		             (instrD[5:0] == 6'b010010)| (instrD[5:0] == 6'b010000)|      //mflo mfhi
						 (instrD[5:0] == 6'b010001)| (instrD[5:0] == 6'b010011));     //mthi mtlo
		assign lwstallD = (data2regE==2'b01)&
						 (instrD[25:21] == WAE | instrD[20:16] == WAE);//current E instrc is lw
		assign beqstallD =beqD &(wregE & (WAE == instrD[25:21] | WAE == instrD[20:16])|
						 (data2regM==2'b01)& (WAM == instrD[25:21] | WAM == instrD[20:16]));
		assign bgtzstallD=bgtzD&(wregE &( WAE == instrD[25:21]) | data2regM==2'b01 & WAM == instrD[25:21]);
		assign JrstallD =JD &(wregE&WAE == instrD[25:21]|(data2regM==2'b01|data2regM==2'b10)& WAM == instrD[25:21]);
		assign MDstallD =MdD & Busy;
		assign is_load_in_EXE=(instrE[31:26]==6'b100011)|(instrE[31:26]==6'b100000)|(instrE[31:26]==6'b100100)|(instrE[31:26]==6'b100001)|(instrE[31:26]==6'b100101);
		assign is_store_in_EXE=(instrE[31:26]==6'b101011)|(instrE[31:26]==6'b101000)|(instrE[31:26]==6'b101001);
		 assign mfhiE=(instrE[31:26]==6'b000000 & instrE[5:0]==6'b010000 )&(instrE[25:21]==instrD[25:21]|instrE[25:21]==instrD[20:16]);//mfhi
		 assign mfloE=(instrE[31:26]==6'b000000 & instrE[5:0]==6'b010010 )&(instrE[25:21]==instrD[25:21]|instrE[25:21]==instrD[20:16]);//mflo
		 assign mfc0E = (instrE[31:21]==11'b01000000000)&(instrE[10:3]==8'b00000000)&(instrE[20:16]==instrD[25:21]|instrE[20:16]==instrD[20:16]);
		 assign mfc0M=(instrM[31:21]==11'b01000000000)&(instrM[10:3]==8'b00000000)&(instrM[20:16]==instrD[25:21]|instrM[20:16]==instrD[20:16]);
		 assign mtc0E = (instrE[31:21]==11'b01000000100)&(instrE[10:3]==8'b00000000)&(instrE[20:16]==instrD[25:21]|instrE[20:16]==instrD[20:16]);
		 assign mtc0M = (instrM[31:21]==11'b01000000100)&(instrM[10:3]==8'b00000000)&(instrM[20:16]==instrE[25:21]|instrM[20:16]==instrE[20:16]);
		 assign PCerror=exception&(exception_type==5'b00110);
		 wire is_exception_instr_in_exe,syscall,Break;
		  assign  syscall=((instrE[31:26]==6'b000000)&(instrE[5:0]==6'b001100));
	 	assign  Break = ((instrE[31:26]==6'b000000)&(instrE[5:0]==6'b001101));
	 	assign eret=((instrE[31:26]==6'b010000)&(instrE[5:0]==6'b011000));
		 assign is_exception_instr_in_exe=((syscall|eret|Break)&pcsourceD==2'b01);
		assign  stallD = lwstallD | beqstallD | JrstallD | MDstallD | bgtzstallD|is_store_in_EXE|is_load_in_EXE|mfloE|mfhiE|mfc0E|mfc0M|mtc0M|mtc0E|is_exception_instr_in_exe;
		assign  stallPC = stallD;
		assign  flushE = stallD|exception;
		assign flushD =exception;
		assign flushM =exception&(!PCerror) ;
		
		
endmodule

