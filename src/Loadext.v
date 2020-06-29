module Loadext(
    input [31:0] dmoutM,
    input [31:26] op,
    input [1:0] aluoutM,
    output reg [31:0] realDmoutM
    );
	 always@(*) begin
	 case(op)
	 6'b100000 : case(aluoutM)//LB
						2'b00 : realDmoutM = {{24{dmoutM[7]}} ,dmoutM[7:0]};
						2'b01 : realDmoutM = {{24{dmoutM[15]}},dmoutM[15:8]};
						2'b10 : realDmoutM = {{24{dmoutM[23]}},dmoutM[23:16]};
						2'b11 : realDmoutM = {{24{dmoutM[31]}},dmoutM[31:24]};
					 endcase
	 6'b100100 : case(aluoutM)//LBU
						2'b00 : realDmoutM = {{24'b0},dmoutM[7:0]};
						2'b01 : realDmoutM = {{24'b0},dmoutM[15:8]};
						2'b10 : realDmoutM = {{24'b0},dmoutM[23:16]};
						2'b11 : realDmoutM = {24'b0,dmoutM[31:24]};
					 endcase
	 6'b100001 : case(aluoutM[1])//LH
	               1'b0 : realDmoutM = {{24{dmoutM[15]}},dmoutM[15:0]};
						1'b1 : realDmoutM = {{24{dmoutM[31]}},dmoutM[31:16]};
					 endcase
	 6'b100101 : case(aluoutM[1])//LHU
	               1'b0 : realDmoutM = {24'b0,dmoutM[15:0]};
						1'b1 : realDmoutM = {24'b0,dmoutM[31:16]};
					 endcase
	 default :  realDmoutM = dmoutM;
	 endcase
	 end
endmodule
