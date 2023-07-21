`include "opcodes.v"

module ControlUnit(
	input [6:0] part_of_inst,
	output reg mem_read,
	output reg mem_to_reg,
	output reg mem_write,
	output reg alu_src,
	output reg write_enable,
	output reg pc_to_reg,
	output reg [6:0]alu_op,
	output reg is_ecall,
	output reg is_jal,
	output reg is_jalr,
	output reg branch,
	output reg is_bubble
	);

	//is_jal, is_jalr, branch 



always@(*)begin
	//for control flow instruction
	is_jal = 0;
	is_jalr = 0;
	branch = 0;
	//for lab 4
	mem_read = 0;
	mem_to_reg = 0;
	mem_write = 0;
	alu_src = 0;
	write_enable = 0;
	pc_to_reg = 0;
	alu_op = part_of_inst[6:0];
	is_ecall = 0;
	is_bubble=0;
	case (part_of_inst)
		`ARITHMETIC : write_enable = 1;
		`ARITHMETIC_IMM :begin
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
		    write_enable = 1; 
			is_jalr = 1;
			alu_src = 1;
			pc_to_reg = 1;
		end
		`STORE: begin 
			mem_write = 1;
		    alu_src = 1;
		end
		`BRANCH: branch = 1;
		`JAL: begin 
			is_jal = 1;
		    write_enable=1;
		    pc_to_reg = 1;
			alu_src=1;
		end
		`ECALL: is_ecall = 1;
		`BUBBLE:is_bubble=1;
		default:begin end
	endcase
end
endmodule

