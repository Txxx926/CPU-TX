module mux2 #(parameter WIDTH = 32)(
    input s,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] out
    );

 always@(*)
	begin
		if(s)
			out <= b;
		else
			out <= a;
	end
endmodule

module mux4 #(parameter WIDTH = 32)(
    input [1:0] op,
    input [WIDTH-1:0] a0,
    input [WIDTH-1:0] a1,
    input [WIDTH-1:0] a2,
    input [WIDTH-1:0] a3,
    output reg [WIDTH-1:0] out
    );
	 always@(*)
	 begin                            
		 case (op)
		 2'b00 : out <= a0;
		 2'b01 : out <= a1;
		 2'b10 : out <= a2;
		 2'b11 : out <= a3;
		 endcase
	 end
endmodule

module mux8 #(parameter WIDTH = 32)(
    input [2:0] op,
    input [WIDTH-1:0] a0,
    input [WIDTH-1:0] a1,
    input [WIDTH-1:0] a2,
    input [WIDTH-1:0] a3,
	 input [WIDTH-1:0] a4,
    input [WIDTH-1:0] a5,
    input [WIDTH-1:0] a6,
    input [WIDTH-1:0] a7,
    output reg [WIDTH-1:0] out
    );
	 always@(*)
	 begin                            
		 case (op)
		 3'b000 : out <= a0;
		 3'b001 : out <= a1;
		 3'b010 : out <= a2;
		 3'b011 : out <= a3;
		 3'b100 : out <= a4;
		 3'b101 : out <= a5;
		 3'b110 : out <= a6;
		 3'b111 : out <= a7;
		 endcase
	 end
endmodule

