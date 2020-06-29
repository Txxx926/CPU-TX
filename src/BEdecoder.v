module BEdecoder(
    input [1:0] Store_Address_in_low2,
    input [31:0] Store_Address_in,
    input [31:0] FReadData2M,
    input [31:0] PCNOW,
    input [31:0]ExceptionM_1,
    input [31:0] instrM,
    input We_Mem,
    output reg[31:0]ExceptionM_2,
    output reg [3:0] BE,
    output reg En,
    output reg [31:0]store_address,
    output reg [31:0] Wdata_out
    );
	 always@(*) begin
	 BE=4'b0000;
	 En=1'b1;
	 ExceptionM_2=ExceptionM_1;
	 if(We_Mem==1'b1)
	 begin
	  if(instrM[31:26]==6'b101001)  begin //SH
	        if(Store_Address_in_low2==2'b10) begin BE=4'b1100; En=1'b1;store_address=Store_Address_in-32'd2;Wdata_out={FReadData2M[15:0],16'h0};end
			else if(Store_Address_in_low2==2'b00) begin BE=4'b0011;En=1'b1;store_address=Store_Address_in;Wdata_out={16'h0,FReadData2M[15:0]};end
			else begin ExceptionM_2={ExceptionM_1[31:5],1'b1,ExceptionM_1[3:0]};end
			end
	  if(instrM[31:26]==6'b101000)begin //SB
	       case(Store_Address_in_low2)
			   	2'b00 :  begin
			   		BE=4'b0001;
			   		store_address=Store_Address_in;
			   		Wdata_out={23'h0,FReadData2M[7:0]};
			   		end
				2'b01 :  begin 
					BE=4'b0010;
					store_address=Store_Address_in-32'd1;
					Wdata_out={16'h0,FReadData2M[7:0],8'h0};
					end
				2'b10 :  begin BE=4'b0100;
					store_address=Store_Address_in-32'd2;
					Wdata_out={8'h0,FReadData2M[7:0],16'h0};
						 end

				2'b11 :  begin 
						BE=4'b1000;
						store_address=Store_Address_in-32'd3;
						Wdata_out={FReadData2M[7:0],24'h0};
					end
				
			  endcase
			  //BE=4'b0010;
		end
	  if(instrM[31:26]==6'b101011) //SW
	      begin
	      	if(Store_Address_in_low2[1:0]==2'b00)begin
	        BE=4'b1111;
	        store_address=Store_Address_in;
	        Wdata_out=FReadData2M;
	    		end
	    	else begin
	    		ExceptionM_2={ExceptionM_1[31:5],1'b1,ExceptionM_1[3:0]};
	    	end
	       end
	   end
	   else if(We_Mem==1'b0)begin
	  if(instrM[31:26]==6'b100011)//lw
	  	begin
	  		if(Store_Address_in_low2[1:0]!=2'b00)begin
	  		    ExceptionM_2={ExceptionM_1[31:5],1'b1,ExceptionM_1[3:0]};
	  		end
	  		else begin
	  			En=1'b1;
	  			store_address=Store_Address_in;
	  		end
	  	end
	  if(instrM[31:26]==6'b100000 |instrM[31:26]==6'b100000 )//lb\lbu
	  	begin
	  		En=1'b1;
	  		store_address=Store_Address_in;
	  	end
	  if(instrM[31:26]==6'b100001 |instrM[31:26]==6'b100101)//lh\lhu
	  	begin
	  		if(Store_Address_in_low2[0]==1'b1)
	  		begin
	  			ExceptionM_2={ExceptionM_1[31:5],1'b1,ExceptionM_1[3:0]};
	  		end
	  		else begin
	  			En=1'b1;
	  			store_address=Store_Address_in;
	  		end
	  	end
	  	if(PCNOW[1:0]!=2'b00)begin
	  		ExceptionM_2={ExceptionM_1[31:5],1'b1,ExceptionM_1[3:0]};
	  	end
	 end
    end
endmodule