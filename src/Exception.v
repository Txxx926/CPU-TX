module Exception(
	input wire resetn,
	input wire [31:0]current_Instuction,//instrM
	input wire[31:0] Exception_i,
	input is_in_delayslot_i,
	input [31:0] cp0_epc,
	input [31:0] cp0_casue,
	input [31:0] cp0_status,
	input We_MEM_i,
	input wire[3:0] Wen_i,
	output reg exception_o,
	output reg[31:0] exception_pc,
	output is_in_delayslot_o,
	output reg [4:0]exception_type,
	output  [31:0] exception_instruction,
	output  [3:0]Wen_o
	);
//exception_type. 5'b00000. 中断.    5‘b00001 地址错误      5’b00010 overflow      5‘b00011 syscall     5’b00100 break        5‘b00101 eret 
//Exception 32位，如果是syscall，则第0位为1；如果是break，则第1位为1；如果是Eret，则第2位为1；如果是OVerflow，则第3位为1，如果是Address_error，则第4位为1
parameter new_pc=32'hBFC00380;
assign Wen_o=((Exception_i==32'h0)&We_MEM_i)?Wen_i:4'b0000;
assign is_in_delayslot_o =is_in_delayslot_i ;
assign exception_instruction =current_Instuction ;
//assign exception_o=(Exception_i==32'h0|!resetn)?1'b0:1'b1;
always @(*)begin
	if (!resetn) begin
		exception_o=1'b0;
		exception_pc=32'h0;
	end
	else if(Exception_i!=32'h0) begin
		exception_o=1'b1;
		if(Exception_i[0]==1'b1)begin//syacall
			exception_pc=new_pc;
			exception_type=5'b00011;
		end
		else if(Exception_i[1]==1'b1)begin//break
			exception_pc=new_pc;
			exception_type=5'b00100;
		end
		else if(Exception_i[2]==1'b1)begin//eret
			exception_pc=cp0_epc;
			exception_type=5'b00101;
		end
		else if(Exception_i[3]==1'b1)begin//overflow
			exception_pc=new_pc;
			exception_type=5'b00010;
		end
		else if(Exception_i[4]==1'b1)begin//address_error
			exception_pc=new_pc;
			exception_type=5'b00001;
		end
		else if(Exception_i[5]==1'b1)begin //pc_eeroe
			exception_pc=new_pc;
			exception_type=5'b00001;
		end
		else if(Exception_i[6]==1'b1)begin//
			exception_pc=new_pc;
			exception_type=5'b10101;
		end
		else if(Exception_i[7]==1'b1)begin//Branch_tp_itself
			exception_pc=new_pc;
			exception_type=5'b10111;
		end
		else begin
			exception_pc=32'hx;
			exception_type=5'b11111;
		end
	end
	else begin
		exception_o=1'b0;
		exception_pc=32'hx;
		exception_type=5'b11111;
	end
end

endmodule