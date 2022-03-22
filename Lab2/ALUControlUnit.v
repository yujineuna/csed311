`include "opcodes.v"
`include "AluOps.v"

module ALUControlUnit(part_of_inst, alu_op);
	input [31:0] part_of_inst;
	output reg [3:0] alu_op;

	reg [6:0] opcode;
	reg [2:0] funct3;
	reg is_sub;
	
	

//initial aluOp
initial begin
alu_op <= 4'b1111; //dummy value
opcode <= 7'b0000000;
funct3 <= 3'b000;
is_sub <= 0;
end

	always @(part_of_inst) begin
		opcode = part_of_inst[6:0];
		funct3 = part_of_inst[14:12];
		is_sub = part_of_inst[30];
	case(opcode) 
		`BRANCH: begin
			if(funct3 == `FUNCT3_BEQ) alu_op = `BEQ;
			else if(funct3 == `FUNCT3_BNE) alu_op = `BNE;
			else if(funct3 == `FUNCT3_BLT) alu_op = `BLT;
			else if(funct3 == `FUNCT3_BGE) alu_op = `BGE;
			else begin end
			end
		`ARITHMETIC: begin 
			if(funct3 == `FUNCT3_ADD && is_sub == 0) alu_op = `ADD;
			else if(funct3 == `FUNCT3_SUB && is_sub == 1) alu_op = `SUB;
			else if(funct3 == `FUNCT3_SLL) alu_op = `SLL;
			else if(funct3 == `FUNCT3_XOR) alu_op = `XOR;
			else if(funct3 == `FUNCT3_OR) alu_op = `OR;
			else if(funct3 == `FUNCT3_AND) alu_op = `AND;
			else if(funct3 == `FUNCT3_SRL) alu_op = `SRL;
			else begin end
			end
		`ARITHMETIC_IMM: begin 
			if(funct3 == `FUNCT3_ADD) alu_op = `ADD;
			else if(funct3 == `FUNCT3_SLL) alu_op = `SLL;
			else if(funct3 == `FUNCT3_XOR) alu_op = `XOR;
			else if(funct3 == `FUNCT3_OR) alu_op = `OR;
			else if(funct3 == `FUNCT3_AND) alu_op = `AND;
			else if(funct3 == `FUNCT3_SRL) alu_op = `SRL;
			else begin end
			end
		`LOAD: alu_op = `ADD;
		`STORE: alu_op = `ADD;
		default: begin alu_op <= 4'b1111;end
	endcase
	end
endmodule