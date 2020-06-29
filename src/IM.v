module IM(
    input [11:2] addr,
    output [31:0] dout
    );
	 
	 reg [31:0] im[2047:0];
	 
	 initial begin
	 $readmemh ("code.txt",im);
	 end
	 
	 
	 assign dout = im[addr];


endmodule
