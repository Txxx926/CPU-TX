module hazard(
		input [31:0]instrD, instrE,
		input [4:0] WAE,WAM, WAW,
		input wregE, wregM, wregW,
		input Exception,
		input [2:0] data2regE, data2regM,
		output forward1D, forward2D,
		output reg [1:0] forward1E, forward2E,
		output stallPC, stallD, flushD,flushE,flushM
		);
		

		wire beqD, JD;
		wire lwstallD, beqstallD,JrstallD;
		
		
		// forwarding sources to D stage (branch equality)        
		assign forward1D = (instrD[25:21] !=0 & instrD[25:21]  == WAM & wregM);
		assign forward2D = (instrD[20:16] !=0 & instrD[20:16]  == WAM & wregM);
		
		
		// forwarding sources to E stage (ALU) 
		always @(*)
		begin
			forward1E = 2'b00; forward2E = 2'b00;
			if (instrE[25:21] != 0)
				if (instrE[25:21] == WAM & wregM)
						forward1E = 2'b01;  
				else if (instrE[25:21] == WAW & wregW) 
						forward1E = 2'b10;
			if (instrE[20:16] != 0)
				if (instrE[20:16] == WAM & wregM)
						forward2E = 2'b01; 
				else if (instrE[20:16] == WAW & wregW) 
						forward2E = 2'b10;
		end
		
		
		
		// stalls
		
		assign  lwstallD = (data2regE==2'b01)&(instrD[25:21] == WAE | instrD[20:16] == WAE);//current instrc is lw
		
		assign beqD =(instrD[31:26]== 6'b000100) | (instrD[31:26]== 6'b000111);//beq bgtz
		assign JD =((instrD[31:26]== 6'b000000) & (instrD[5:0] == 6'b001000))|  //jr
			((instrD[31:26]== 6'b000000) & (instrD[5:0] == 6'b001001));   //jarl
		assign  beqstallD =beqD &(wregE &(WAE == instrD[25:21] | WAE == instrD[20:16])|(data2regM==2'b001) &(WAM == instrD[25:21] | WAM == instrD[20:16]));
		assign  JrstallD =JD &(wregE &(WAE == instrD[25:21])|(data2regM==2'b001) &(WAM == instrD[25:21]));;

		
		assign  stallD = lwstallD | beqstallD | JrstallD;
		assign  stallPC = stallD;
		assign  flushE = stallD|Exception;
		assign flushM =Exception ;
		assign flushD =Exception ;
		// stalling D flushes next stage
		// Note: not necessary to stall D stage on store
		// if source comes from load;
		// instead, another bypass network could
		// be added from W to M
endmodule
