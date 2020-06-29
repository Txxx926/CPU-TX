module PR#(parameter WIDTH = 8)(
	input clk,
	input resetn,
	input stall,
	input flush,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);
	always @ (posedge clk)
		if (!resetn)begin
			q <= 0;
		end
		else if(flush==1'b1)begin
			q<=0;
		end
		else if(stall==0) begin
			q<=d;
		end
endmodule


module PR_PC#(parameter WIDTH = 8)(
	input clk,
	input resetn,
	input stall,
	input flush,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);
	always @ (posedge clk )
		if (!resetn)begin
			q<=32'hbfc00000;
			
		end
		else if(flush==1'b1)begin
			q<=0;
		end
		else if(stall==0) begin
			q<=d;
		end
endmodule



module PR_withflush#(parameter WIDTH = 8)(
	input clk,
	input resetn,
	input stall,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);
	always @ (posedge clk )
		if (!resetn) q <=  32'h0000_3000;
			else if (stall==0) q <=  d;
endmodule

module PipelineRegC #(parameter WIDTH = 8)(
		input clk,
		input resetn,
		input clear,
		input [WIDTH-1:0] d,
		output reg [WIDTH-1:0] q);
		
		always @(posedge clk )
				if (!resetn) q <=  0;
				else if (clear) q <=  0;
						else q <= d;
endmodule