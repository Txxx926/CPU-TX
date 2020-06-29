module forward(
		input [31:0]instrD, instrE,
		input [4:0] WAE,WAM, WAW,
		input wregE, wregM, wregW,
		output forward1D, forward2D,
		output reg [1:0] forward1E, forward2E
		);
		
		// M ->D      
		assign forward1D = (instrD[25:21] !=0 & instrD[25:21]  == WAM & wregM);
		assign forward2D = (instrD[20:16] !=0 & instrD[20:16]  == WAM & wregM);
		// M ->E    W ->E
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
endmodule