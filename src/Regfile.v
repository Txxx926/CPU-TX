
module Regfile(A1,A2,A3,RD1,RD2,WD,We,Clk,resetn);


    input [4:0] A1;
    input [4:0] A2;
    input [4:0] A3;
    output [31:0] RD1;  
    output [31:0] RD2;
	 input [31:0] WD;
	 input We;             
	 input Clk;
    input resetn;
	 
	 
	 reg [31:0] gpr[31:0];
	 assign RD1=(We&A1==A3&A3!=0)?WD:gpr[A1];
	 assign RD2=(We&A2==A3&A3!=0)?WD:gpr[A2];
	 integer i;
	 initial 
		begin 
			for(i=0;i<32;i=i+1)
					gpr[i] =0;
		end
	 always@(posedge Clk or negedge resetn)
	 begin
			if(resetn==1'b0)
				begin
				  for(i=0;i<32;i=i+1)
					gpr[i] =0;
				end 
			else if(We&A3!=0) begin
					
            //$display("$%d <= %x", A3, WD);
            	gpr[A3] <= WD;
        end
	 end
	 
endmodule