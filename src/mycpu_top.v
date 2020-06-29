module mycpu_top(
	 input clk,
	 input resetn,
	 input [5:0]int,
	 output  inst_sram_en,
	 output  [3:0] inst_sram_wen,
	 output  [31:0] inst_sram_addr,
	 output  [31:0] inst_sram_wdata,
	 input  [31:0] inst_sram_rdata,

	 output  data_sram_en,
	 output  [3:0] data_sram_wen,
	 output  [31:0] data_sram_addr,
	 output  [31:0] data_sram_wdata,
	 input [31:0] data_sram_rdata,

	 output [31:0] debug_wb_pc,
	 output [3:0] debug_wb_rf_wen,
	 output [4:0] debug_wb_rf_wnum,
	 output [31:0] debug_wb_rf_wdata 

    );

	 wire[31:0]  NPC;
	 wire [31:0]PC;
	 wire[31:0]  PCadd4F, PCadd4D, PCadd4E, PCadd4M, PCadd4W, PCadd8W, 
	             aluoutE, aluoutM, aluoutW, Real_aluoutE, resultW;
	 wire[31:0]  ReadData1D, ReadData2D;
	 wire[31:0]  ReadData1E, ReadData2E, FReadData2M;
	 wire[31:0]  FReadData1E, FReadData2E;
	 wire[31:0]  FReadData1D, FReadData2D;
	 wire [4:0]  WAD, WAE, WAM, WAW;
	 wire[31:0]  pcbeqD;
	 wire [31:0] instrF, instrD, instrE, instrM;
	 wire [31:0] saD, saE, immextD, immextE;
	 wire [31:0] aluA, aluB;
	 wire [31:0] moutM, realmoutM, MemOut2W;
	 wire [3:0] BE;//Õë¶ÔSW¡¢SH¡¢SB
	 wire Start, HiLo, We, Busy;
	 wire [31:0] HI, LO;
	 wire [1:0] mduOp;//³Ë³ý?
	 wire Great, Less, Zero, Over;
	 //hazards
	 wire [31:0] exception_pc;
	 wire [31:0] FinalPC;
	 wire stallPC, stallD, flushE,flushD,flushM,flushW;
	 wire[1:0] forward1E, forward2E;
	 wire      forward1D, forward2D;
	 
	 //controls
	 wire [2:0]CmpOp;
	 wire Branch;
	 wire wregD, wregE, wregM, wregW, 
			shiftD, shiftE, 
			exD, 
			aluimmD, aluimmE, 
			wmemD, wmemE, wmemM;
	 wire [1:0] regdstD, pcsourceD;
	 wire [3:0] alucD, alucE;
	 wire [1:0] data2regD, data2regE, data2regM, data2regW;
	 wire madd;
//F 32'hBFC00000
	reg PC_en;
	wire if_exception;//ÊÇ·ñ·¢ÉúÁËÒì?
	wire [31:0] Exception_D,Exception_E,Exception_M;//Èý¸ö½×¶ÎµÄÒì³£ÐÅ?
	assign inst_sram_wen =4'b0000;
	 assign inst_sram_en =PC_en&(!stallPC);
	 assign inst_sram_addr =PC;
	  //always@(clk)begin
	//if(resetn)begin
	//$display("NOW_PCF=0x%8h",PCadd4F-32'd4);
	//end
	//end
	 assign instrF =inst_sram_rdata&{32{resetn}};
	 //IM im(PC[12:2], instrF);
	 adder a1(PC, 32'b100,PCadd4F);
	 //mux2 mux123(if_exception,NPC,exception_pc,PC);
	 reg if_exception_end;
	 //always@(*)begin
	 	//if_exception_end<=if_exception;
	 //end
	 
	 parameter excep_pc=32'hBFC00380;

	 assign FinalPC=((if_exception)?exception_pc:NPC);

	always@(posedge resetn)begin
		PC_en<=1'b1;
	end
	reg flushD_end;

	 PR_PC #(32) R_FD1(clk, resetn, stallPC&(!if_exception), 1'b0,FinalPC, PC);

	 PR #(32) R_FD2(clk, resetn, stallD, flushD,PCadd4F, PCadd4D);//flushD
	 always@(*)begin
	 	if(resetn)begin
	 	flushD_end<=flushD;
	 end
	 end
	// PR #(32) R_FD3(clk, resetn, stallD, flushD,instrF, instrD);
	//assign PCadd4D=PCadd4F;
	assign instrD=inst_sram_rdata&{32{resetn}} ;//&{32{!flushD}};
//D
	     //ext
	    wire is_branch_from_E;
	    wire is_branch_from_D;
	    wire is_branch_from_ex;
	    wire is_in_delayslot_D;
	    wire is_in_delayslot_E;
	    wire is_in_delayslot_M;
	 ext e1(1'b0,{11'b0,instrD[10:6]},saD);//Õë¶ÔSRAºÍSRAVÖ¸Áî£¬Òò?
	 ext e2(exD , instrD[15:0], immextD);//exD?0Ê±×öÎÞ·ûºÅÍØÕ¹£¬exD?1Ê±×öÓÐ·ûºÅÍØ?
	 wire WbCP0_D,Read_CP0_D;
	 wire [4:0]Read_CP0_Addr_D,Write_CP0_Addr_D;
assign is_branch_from_ex =is_branch_from_E ;
	    //ctrl
	  
	 ctrl c1(instrD[31:26], instrD[5:0],(PCadd4D-32'd4),instrD,flushD,Branch, is_branch_from_ex,
				wmemD, wregD, alucD, shiftD, exD, aluimmD, pcsourceD, is_branch_from_D ,is_in_delayslot_D,Exception_D,data2regD, regdstD,WbCP0_D,Read_CP0_D,Read_CP0_Addr_D,Write_CP0_Addr_D);
	wire [1:0] pcsourceD_end;
	assign pcsourceD_end=(PCadd4D==32'h0|flushD_end)?2'b00:pcsourceD;
	 Regfile regfile(instrD[25:21], instrD[20:16], WAW, ReadData1D, ReadData2D, resultW, wregW, clk, resetn);
	 mux4 #(5) Regdst(regdstD, instrD[20:16], instrD[15:11],5'b11111, 5'b0, WAD);
	    //forward
	 mux2 #(32) mux1(forward1D, ReadData1D, aluoutM, FReadData1D);  //£¿£¿£¿ALUoutm£¿£¿
	 mux2 #(32) mux2(forward2D, ReadData2D, aluoutM, FReadData2D);
	    // branch cmp
	 CmpDecoder Cd(PCadd4D,instrD, CmpOp);
	 CMP  cmp(PCadd4D,instrD,FReadData1D, FReadData2D, CmpOp, Branch);
	 wire [31:0]Exception_D2E;
	 assign Exception_D2E=(pcsourceD_end==2'b01&((pcbeqD==(PCadd4D-32'd4))))?{Exception_D[31:8],1'b1,Exception_D[6:0]}:Exception_D;
	wire is_load_in_MEM;
	assign is_load_in_MEM=(instrM[31:26]==6'b100011)|(instrM[31:26]==6'b100000)|(instrM[31:26]==6'b100100)|(instrM[31:26]==6'b100001)|(instrM[31:26]==6'b100101);
	assign is_store_in_MEM=(instrM[31:26]==6'b101011)|(instrM[31:26]==6'b101000)|(instrM[31:26]==6'b101001);
// 	always@(posedge clk)begin
// 	if(resetn)begin
// 	$display("PC=0x%8h,PC_F=0x%8h,PC_D=0x%8h,Exception_D2E is 0x%8h,INstructionE is 32'b%32b,PC_E=0x%8h,PC_M=0x%8h,Exception_in_M is 0x%8h",PC,PCadd4F-32'd4,PCadd4D-32'd4,Exception_D,instrD,PCadd4E-32'd4,PCadd4M-32'd4,Exception_M_in);
// 	$display("Wmem=b%1b,data2regM=b%2b,wregM=b%1b",wmemM, data2regM, wregM);
// 	$display("instD=0x%8h,instrE=0x%8h",instrD,instrE);
// 	end
// 	if(flushE)begin
// 	$display("is_flsuhing_Exection");
// 	end
// 	if(flushD)begin
// 	$display("is_flushing_Decode");
// 	end
// 	if(flushM)begin
// 	$display("is_flushing_MEM");
// 	end
// 	if(wmemE==1'b1)begin
// 	$display("PC_in_EXE=0x%8h,__is store instruciton,INstruction is 0x%8h,Store_Address_is 0x%8h,alu_a=0x%8h,alu_b=0x%8h",PCadd4E-32'd4,instrE,aluoutE-32'hA0000000,aluA,aluB);
// 	end
// 	if(data2regE==1'b01)begin
// 	$display("PC_in_EXE=0x%8h,__is load instruciton,INstruction is 0x%8h,load_Address_is 0x%8h,alu_a=0x%8h,alu_b=0x%8h",PCadd4E-32'd4,instrE,aluoutE-32'hA0000000,aluA,aluB);
// 	end
// end
	// if(is_load_in_MEM)begin
	// 	$display("PC_in_MEM=0x%8h__is load instruciton,INstruction is 0x%8h,Load_Data_is 0x%8h,load_Address_is 0x%8h,Wen is 0x%8h,aluoutM=0x%8h",PCadd4M-32'd4,instrM,realmoutM,data_sram_addr,Wen_o,aluoutM-32'hA0000000);
	// end
	// if(is_store_in_MEM)begin
	// 	$display("PC_in_MEM=0x%8h__is store instruciton,INstruction is 0x%8h,Store_Data_is 0x%8h,store_Address_is 0x%8h,Wen is 0x%8h,aluoutM=0x%8h",PCadd4M-32'd4,instrM,data_sram_wdata,data_sram_addr,Wen_o,aluoutM-32'hA0000000);
	// end
	// if(Exception_type!=5'b00000&Exception_type!=5'b11111)begin
	// 	$display("Now exception is %5b, epc0 is 0x%8h,Current PCm is 0x%8h,Exception is 0x%8h,badaddress is 0x%8h,cp0_BadVAddr is 0x%8h",Exception_type,cp0_epc,PCadd4M-32'd4,Exception_M_2,badaddress,cp0_BadVAddr);
	// end
	// end
	// always@(cp0_epc)begin
	// 	$display("epc0 is changed,is 0x%8h",cp0_epc);
	// end
	// always@(cp0_cause)begin
	// 	$display("cp0cause is changed,is 0x%8h",cp0_cause);
	// end
	// always@(cp0_BadVAddr)begin
	// 	$display("cp0_BadVAddr is changed,is 0x%8h,WBCP0 is %1b,WB_CP0_addr is 0x%8h,Exception_type is %5b,PCM is 0x%8h",cp0_BadVAddr,WbCP0_M,Write_CP0_Addr_M,Exception_type,(PCadd4M-32'd4));
	// end
	// always@(Exception_M_in)begin
	// 	if(Exception_M_in!=32'H0)
	// 	$display("mem STAGE PC IS EXCEPTION,pc IS 0X%8H",(PCadd4M-32'd4));
	// end
	// always@(posedge clk)begin
	// if(resetn&debug_wb_rf_wnum!=5'b00000&debug_wb_rf_wen!=1'b0)begin
	// $display("debug_wb_pc=0x%8h,debug_wb_rf_wnum=%5b,debug_wb_rf_wdata=0x%8h",debug_wb_pc,debug_wb_rf_wnum,debug_wb_rf_wdata);
	// $display("data2regW=",data2regW);
	// end
	// end
	//  always@(*)begin
	//  	$display("HILO is changed,HI=0x%8h,LO=0x%8h",HI,LO);
	//  end
	// always@(*)begin
	// 		$display("ReadCP0_Address is 0x%8h,Read_data_is 0x%8h,status is 0x%8h,epc is 0x%8h, cause is 0x%8h",Read_CP0_Addr_M,Cp0Read_data,cp0_status,cp0_epc,cp0_cause);
	// end
	    //next pc
	 adder a2(PCadd4D, {immextD[29:0],2'B00}, pcbeqD);
	 mux4 #(32) npc(pcsourceD_end, PCadd4F, pcbeqD, FReadData1D, {PCadd4D[31:28],instrD[25:0],2'b00}, NPC);
	 

	   //PR
	  wire WbCP0_E,Read_CP0_E;
	 wire [4:0]Read_CP0_Addr_E,Write_CP0_Addr_E;

	 PR #(5)   R_DE1(clk, resetn,1'b0,flushE, WAD, WAE);//Write Address
	 PR #(1)	R_DE10(clk,resetn,1'b0,flushE,is_branch_from_D,is_branch_from_E);
	 PR #(1)	R_DE11(clk,resetn,1'b0,flushE,is_in_delayslot_D,is_in_delayslot_E);
	 PR #(32)  R_DE2(clk, resetn,1'b0,flushE, instrD, instrE);

	 PR #(32)  R_DE3(clk, resetn, 1'b0,flushE, saD, saE);

	 PR #(32)  R_DE4(clk, resetn, 1'b0,flushE, immextD, immextE);

	 PR #(32)  R_DE5(clk, resetn, 1'b0,flushE, PCadd4D, PCadd4E);

	 PR #(32)  R_DE6(clk, resetn, 1'b0,flushE, FReadData1D, ReadData1E);

	 PR #(32)  R_DE7(clk, resetn, 1'b0,flushE, FReadData2D, ReadData2E);

	 PR #(10)  R_DE8(clk, resetn, 1'b0,flushE, 
						{shiftD, aluimmD, alucD, wmemD, data2regD, wregD},
						{shiftE, aluimmE, alucE, wmemE, data2regE, wregE});
	 
	  PR #(12)  R_DE9(clk, resetn, 1'b0,flushE, {WbCP0_D,Read_CP0_D,Read_CP0_Addr_D,Write_CP0_Addr_D}, {WbCP0_E,Read_CP0_E,Read_CP0_Addr_E,Write_CP0_Addr_E});
	 PR #(32) R_DE13(clk,resetn,1'b0,flushE,Exception_D2E,Exception_E);
//E
	wire WbCP0_M,Read_CP0_M;
	wire [4:0] Read_CP0_Addr_M,Write_CP0_Addr_M;
	wire [31:0]Exception_E_2;
	wire [4:0] WAE_end;
	wire wregE_end;
	assign wregE_end=wregE&(!Over|(Over&is_sltE))&(Exception_E_2==32'h0);
	assign WAE_end=(Exception_E_2==32'h0)?WAE:5'b00000;
	assign is_sltE=(instrE[31:26]==6'b000000)&(instrE[5:0]==6'b101010);
	 mux4  #(32) mux4(forward1E, ReadData1E, aluoutM, resultW, 32'b0, FReadData1E);
	 mux4  #(32) mux5(forward2E, ReadData2E, aluoutM, resultW, 32'b0, FReadData2E);
	 mux2 #(32)  mux6(shiftE, FReadData1E, saE, aluA);
	 mux2 #(32)  mux7(aluimmE, FReadData2E, immextE, aluB);
	 MDctrl c2(instrE[31:26], instrE[5:0], Start, HiLo, We, mduOp, madd);
	 alu  Alu( instrE,aluA, aluB, alucE, Exception_E,Exception_E_2,aluoutE, Over);

	 mdu  Mdu( FReadData1E, FReadData2E, HiLo, mduOp, Start, We, Busy, madd, HI, LO, clk, resetn,if_exception);	 
	 ALUChoose  Aluchoose(instrE, aluA, aluB, aluoutE, HI, LO, Real_aluoutE);
 	 //choose aluout or sltout or hi or lo

	  //Pipeline Reg E->M
	

	 PR #(32) R_EM1(clk, resetn,1'b0,flushM,instrE, instrM);

	 PR #(32) R_EM2(clk, resetn, 1'b0,flushM,Real_aluoutE, aluoutM);

	 PR #(32) R_EM3(clk, resetn,1'b0,flushM, PCadd4E, PCadd4M);

	 PR #(32) R_EM4(clk, resetn, 1'b0,flushM,FReadData2E, FReadData2M);

	 PR #(5)  R_EM5(clk, resetn,1'b0,flushM,WAE_end, WAM);

	 PR #(4)  R_EM6(clk, resetn, 1'b0,flushM,{wmemE, data2regE, wregE_end},
													 {wmemM, data2regM, wregM});
	 PR #(32) R_EM7 (clk,resetn,1'b0,flushM,Exception_E_2,Exception_M);
	 PR #(12)  R_EM9(clk, resetn, 1'b0,flushM, {WbCP0_E,Read_CP0_E,Read_CP0_Addr_E,Write_CP0_Addr_E}, {WbCP0_M,Read_CP0_M,Read_CP0_Addr_M,Write_CP0_Addr_M});
	 PR #(1) R_EM10(clk,resetn,1'b0,flushM,is_in_delayslot_E,is_in_delayslot_M);
//Md
wire [31:0] badaddress;
wire [3:0]Wen_o;
wire [31:0] Wdata_end;
wire [31:0] Exception_M_in;
assign Exception_M_in=Exception_M;
assign data_sram_en =1'b1;
assign data_sram_wen =(PCadd4M!=32'h0)?Wen_o:4'b0000 ;
//assign data_sram_addr=(data2regE==2'b01)?(Real_aluoutE-32'hA0000000):aluoutM;
wire [31:0]store_address_end;
wire RI;
assign data_sram_addr=(data2regE==2'b01)?Real_aluoutE-32'hA0000000:store_address_end;
assign data_sram_wdata=Wdata_end;
wire [31:0]cp0_status,cp0_cause,cp0_epc,cp0_BadVAddr,Cp0Read_data,exception_instruction,Exception_M_2;
wire is_in_delayslot_from_Excep,En;
wire if_exception_in_MEM2W;
wire [31:0]storeaddress_in;
wire is_mul_div;
assign is_mul_div=(instrM[31:26]==6'b000000&(instrM[5:0]==6'b011000|instrM[5:0]==6'b011001))?1'b1:1'b0;
 assign	storeaddress_in=aluoutM-32'hA0000000;

	 BEdecoder B1(storeaddress_in[1:0],storeaddress_in, FReadData2M,(PCadd4M),Exception_M_in,instrM, wmemM,Exception_M_2,BE,En,store_address_end,Wdata_end);//aluoutM[1:0]±íÊ¾ÈôMEM½×¶ÎÈ¡Ö¸£¬ÔòµØÖ·µÄÄ©Á½Î»
	 // BEdecoder B1(aluoutM[1:0], Exception_E_2,instrE, wmemE,Exception_E_3,BE,En);
	 //DM dm(aluoutM[12:2], BE, FReadData2M, moutM, wmemM,clk);
	 Loadext L(data_sram_rdata, instrM[31:26], aluoutM[1:0], realmoutM);// alu out ext
	assign badaddress=(PCadd4M[1:0]!=2'b00|(Exception_M[6]==1'b1))?(PCadd4M-32'd4):aluoutM;
	wire [31:0] Exception_M_3,PCM;
	assign PCM=(PCadd4M-32'd4);
	reg [31:0] CurrentpCM;
	assign RI=(Exception_M[6]==1'b1);
	// wire WbCP0_M_end;
	// wire [4:0]Write_CP0_Addr_M_end;
	// wire [31:0] Write_CP0_Data_end;
	// assign WbCP0_M_end=(pcerror==1'b1)?1'b1:WbCP0_M;
	// assign Write_CP0_Addr_M_end=(pcerror==1'b1)?5'b11100:Write_CP0_Addr_M;
	// assign Write_CP0_Data_end=(pcerror==1'b1)?(PCadd4M-32'd4):FReadData2M;
	wire [4:0] Exception_type;
	 Exception Excption1(
	resetn,
	instrM,//instrM
	Exception_M_2,
	is_in_delayslot_M,
	cp0_epc,
	cp0_cause,
	cp0_status,
	wmemM,
	BE,
	if_exception,//Ç°ÃæÈ¡Ö¸
	exception_pc,
	is_in_delayslot_from_Excep,
	Exception_type,
	exception_instruction,
	Wen_o
	);

	CP0 CP(
	 clk,
	resetn,
	WbCP0_M,
	wmemM,
	RI,
	badaddress,
	Write_CP0_Addr_M,
	FReadData2M,
	Read_CP0_Addr_M,
	Exception_type,
	is_in_delayslot_from_Excep,
	(PCadd4M-32'd4),
	int,
	Cp0Read_data,
	cp0_BadVAddr,
	cp0_status,	
	cp0_cause,		
	cp0_epc);
 wire Read_CP0_W;
wire [31:0] Read_CP0_data_W,instrW;
wire wregM_end;
wire [4:0] WAM_end;
assign wregM_end=(PCadd4M==32'h0|is_mul_div)?1'b0:wregM;
assign WAM_end=(PCadd4M==32'h0|is_mul_div)?5'b00000:WAM;
wire address_Error_in_MEM;

assign address_Error_in_MEM=(Exception_type==5'b00001)?1'b1:1'b0;
	 PR #(32) R_MW1(clk, resetn, 1'b0,flushW,realmoutM, MemOut2W);
	 PR #(32) R_MW1b(clk, resetn, 1'b0,flushW,instrM, instrW);
	 PR #(32) R_MW2(clk, resetn, 1'b0,flushW,aluoutM, aluoutW);
	 PR #(1)  R_MW3(clk, resetn,1'b0,flushW, if_exception,if_exception_in_MEM2W);
	 PR #(5)  R_MW8(clk, resetn,1'b0,flushW, WAM_end&{5{!address_Error_in_MEM}}, WAW);

	 PR #(32) R_MW4(clk, resetn,1'b0,flushW, PCadd4M, PCadd4W);

	 PR #(3)  R_MW5(clk, resetn,1'b0,flushW, {data2regM, wregM_end&(!address_Error_in_MEM)}, {data2regW, wregW});
	 PR #(33)   R_MW6(clk,resetn,1'b0,flushW,{Read_CP0_M,Cp0Read_data},{Read_CP0_W,Read_CP0_data_W});
//W 
	 adder  a3(PCadd4W, 32'b100, PCadd8W);
	 wire [31:0]resultW1;
	
	 mux4 mux8(data2regW, aluoutW, MemOut2W, PCadd8W, 32'b0, resultW1);
	 mux2 mux22(Read_CP0_W,resultW1,Read_CP0_data_W,resultW);
	

assign debug_wb_pc =PCadd4W-32'd4;
assign debug_wb_rf_wen = {4{wregW}};
assign debug_wb_rf_wdata = (wregW==1'b1)?resultW:32'h0;
assign debug_wb_rf_wnum =WAW;
//hazard
	 Stall S(instrD, instrE, instrM,instrW,PCadd4D-32'd4,WAE, WAM, WAW, wregE, wregM, wregW,
			  data2regE, data2regM, Busy, if_exception,Exception_type,pcsourceD_end,stallPC, stallD, flushD,flushE,flushM);
			  
	 forward F(instrD, instrE,WAE,WAM, WAW, wregE, wregM, wregW, 
	       forward1D, forward2D, forward1E, forward2E);
		
endmodule
