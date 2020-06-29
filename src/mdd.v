module mdd(
    input [3:0] A,
    input [3:0] B,
    input [3:0] C,
    input [3:0] D,
    output [7:0] AmulB,
    output [7:0] CandD,
    output [7:0] result1,
	 output [7:0] result2
    );
	 assign AmulB=$signed(A)*$signed(B);
	 assign CandD={C,D};
	 assign result1=$signed(A)*$signed(B)+{C,D};
	 assign result2=AmulB+CandD;
	 initial $monitor($time,,"A=%d B=%d AmulB=%b CandD=%b result1=%b result2=%b  AmulB=%d CandD=%d result1=%d result2=%d ",
   	 A,B,AmulB,CandD,result1,result2,AmulB,CandD,result1,result2);

endmodule
