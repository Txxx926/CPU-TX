module CP0(
	input clk,
	input restn,
	input  Wb_Write_CP0,
	input WE_MEM,
	input RI,
	input wire [31:0] badaddress,
	input wire [4:0] Wb_Write_Addr,
	input wire [31:0] Wb_Write_Data,
	input wire [4:0] Mem_Read_Addr,
	input wire [4:0] Exception_type,//5'b00000. 中断.    5‘b00001 地址错误      5’b00010 overflow      5‘b00011 syscall     5’b00100 break        5‘b00101 eret 
	input wire is_in_delay_slot,
	input wire[31:0] current_pc,
	input wire [5:0] int_,
	output reg[31:0]  Read_data_o,
	output reg[31:0]	BadVAddr_o, //5'd8
	output reg[31:0]   status_o,	//5'd12
	output reg[31:0]   cause_o,		//5'd13
	output reg[31:0]   epc_o		//5'd14
	);
reg [31:0] num_11;
parameter BadVAddr_reg_Addr=5'd8;
parameter status_reg_Addr=5'd12;
parameter cause_reg_Addr=5'd13;
parameter epc_reg_Addr=5'd14;
parameter Address_Error=5'b00001;
parameter Overflow=5'b00010;
parameter Syscall=5'b00011;
parameter Break=5'b00100;
parameter Eret=5'b00101;
parameter RI_=5'b10101;
parameter SOFT=5'b10111;
wire PCERROR;
assign PCERROR=(current_pc[1:0]!=2'b00)?1'b1:1'b0;
always@(*)begin
		if(current_pc!=32'hfffffffc)begin
		case(Exception_type)
		RI_:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			cause_o[6:2]<=5'h0a;
			BadVAddr_o<=current_pc;
		end
		SOFT:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			cause_o[6:2]<=5'h00;
			BadVAddr_o<=current_pc;
		end
		Syscall:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			cause_o[6:2]<=5'b01000;
		end
		Overflow:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			cause_o[6:2]<=5'b01100;
		end
		Address_Error:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			if(WE_MEM)begin
				cause_o[6:2]<=5'b00101;
				BadVAddr_o<=badaddress;
			end
			else begin
				cause_o[6:2]<=5'b00100;
				if(current_pc[1:0]==2'b00)begin
				BadVAddr_o<=badaddress;
				end
				else begin
				BadVAddr_o<=current_pc;
				end
			end
			
		end
		Break:begin
			if(status_o[1]==1'b0)begin
				if(is_in_delay_slot==1'b1)begin
					epc_o<=current_pc-4;
					cause_o[31]<=1'b1;
				end
				else begin
					epc_o<=current_pc;
					cause_o[31]<=1'b0;
				end
			end
			status_o[1]<=1'b1;
			cause_o[6:2]<=5'b01001;
		end
		Eret:begin
			status_o[1]<=1'b0;
		end
		endcase
	end
end
always @(posedge clk ) begin
	if (!restn) begin
			status_o <= 32'b00010000000000000000000000000000;
			cause_o <= 32'h0;
			epc_o <= 32'h0;
			BadVAddr_o<=32'h0;
	end
	else begin
		cause_o[15:10]<=int_;
		if(Wb_Write_CP0==1'b1&(current_pc!=32'hfffffffc))begin
			case(Wb_Write_Addr)
			BadVAddr_reg_Addr:begin
				BadVAddr_o<=Wb_Write_Data;
			end
			5'b11100:begin
				cause_o[6:2]<=5'b00100;
					status_o[1]<=1'b1;
					epc_o<=Wb_Write_Data;
			end
			status_reg_Addr:begin
				status_o<=Wb_Write_Data;
			end
			cause_reg_Addr:begin
				cause_o[9:8] <= Wb_Write_Data[9:8];
				cause_o[23] <= Wb_Write_Data[23];
				cause_o[22] <= Wb_Write_Data[22];
			end
			epc_reg_Addr:begin
				epc_o<=Wb_Write_Data;
				if(Wb_Write_Data==32'hb27f9789)begin
					cause_o[6:2]<=5'b0100;
					status_o[1]<=1'b1;
				end
			end
			endcase
		end
	end
end
always@(*) begin
		if(!restn) begin
			Read_data_o<= 32'h0;
		end else begin
				case (Mem_Read_Addr) 
					BadVAddr_reg_Addr:		begin
					if(Wb_Write_CP0==1'b1&Wb_Write_Addr==BadVAddr_reg_Addr)begin
						Read_data_o <= Wb_Write_Data;
					end
					else begin
						Read_data_o<=BadVAddr_o;
					end
					end
					status_reg_Addr:	begin
					if(Wb_Write_CP0==1'b1&Wb_Write_Addr==status_reg_Addr)begin
						Read_data_o <= Wb_Write_Data;
					end
					else begin
						Read_data_o<=status_o;
					end
					end
					cause_reg_Addr:	begin
					if(Wb_Write_CP0==1'b1&Wb_Write_Addr==cause_reg_Addr)begin
						Read_data_o <= Wb_Write_Data;
					end
					else begin
						Read_data_o<=cause_o;
					end
					end
					5'b01011:begin
						if(Wb_Write_CP0==1'b1&Wb_Write_Addr==5'd11)begin
						Read_data_o <= Wb_Write_Data;
						end
						else begin
						Read_data_o<=cause_o;
						end
					end
					epc_reg_Addr:	begin
					if(Wb_Write_CP0==1'b1&Wb_Write_Addr==epc_reg_Addr)begin
						Read_data_o <= Wb_Write_Data;
					end
					else begin
						Read_data_o<=epc_o;
					end
					end
					
					
					default: 	begin
					end			
				endcase  //case addr_i			
		end    //if
	end      //always


endmodule