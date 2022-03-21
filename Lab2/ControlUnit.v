`include "opcodes.v"

module ControlUnit(
	input [6:0] part_of_inst,
	output reg is_jal, 
	output reg is_jalr,
	output reg branch,
	output reg mem_read,
	output reg mem_to_reg,
	output reg mem_write,
	output reg alu_src,
	output reg write_enable,
	output reg pc_to_reg,
	output reg is_ecall);

//initialization
/*initial begin
is_jal <= 0; //JAL
is_jalr <= 0; //JALR
branch <= 0; //Branch
mem_read <= 0; //MemRead
mem_to_reg <= 0; //MemtoReg
mem_write <= 0; //MemWrite
alu_src <= 0; //ALUSrc
write_enable <= 0; //RegWrite
pc_to_reg <= 0; //PCtoReg
is_ecall <= 0; //end sign
end*/

always@(part_of_inst)begin
	is_jal = 0;
	is_jalr = 0;
	branch = 0;
	mem_read = 0;
	mem_to_reg = 0;
	mem_write = 0;
	alu_src = 0;
	write_enable = 0;
	pc_to_reg = 0;
	is_ecall = 0;
	case (part_of_inst)
		`ARITHMETIC : write_enable = 1;
		`ARITHMETIC_IMM : begin 
				write_enable = 1;
				alu_src = 1;
				end
		`LOAD: begin
			write_enable = 1;
			mem_read = 1;
			mem_to_reg = 1;
			alu_src = 1;
			end
		`JALR: begin 
			is_jalr = 1;
			alu_src = 1;
			pc_to_reg = 1;
			end
		`STORE: begin mem_write = 1;
		       alu_src = 1; end
		`BRANCH: branch = 1;
		`JAL: begin is_jal = 1;
		     pc_to_reg = 1; end
		`ECALL: begin end
	endcase
end
endmodule

