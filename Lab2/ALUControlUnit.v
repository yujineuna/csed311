`include "opcodes.v"
`include "AluOps.v"

module ALUControlUnit(inst, aluOp)
	input [31:0] inst;
	output reg [3:0] aluOp;

	reg [6:0] opcode;
	reg [2:0] funct3;
	reg is_sub;

//initial aluOp
aluOp = 4'b1111; //dummy value
opcode = 7'b0000000;
funct3 = 3'b000;
is_sub = 0;

	always @(inst) begin
		opcode = inst[6:0];
		funct3 = inst[14:12];
		is_sub = inst[30];
	case(opcode) 
		BRANCH: begin
			if(funct3 == FUNCT3_BEQ) aluOp = BEQ;
			else if(funct3 == FUNCT3_BNE) aluOp = BNE;
			else if(funct3 == FUNCT3_BLT) aluOp = BLT;
			else if(funct3 == FUNCT3_BGE) aluOp = BGE;
			else begin end
			end
		ARITHMETIC: begin 
			if(funct3 == FUNCT3_ADD && is_sub == 0) aluOp = ADD;
			else if(funct3 == FUNCT3_SUB && is_sub == 1) aluOp = SUB;
			else if(funct3 == FUNCT3_SLL) aluOp = SLL;
			else if(funct3 == FUNCT3_XOR) aluOp = XOR;
			else if(funct3 == FUNCT3_OR) aluOp = OR;
			else if(funct3 == FUNCT3_AND) aluOp = AND;
			else if(funct3 == FUNCT3_SRL) aluOp = SRL;
			else begin end
			end
		ARITHMETIC_IMM: begin 
			if(funct3 == FUNCT3_ADD) aluOp = ADD;
			else if(funct3 == FUNCT3_SLL) aluOp = SLL;
			else if(funct3 == FUNCT3_XOR) aluOp = XOR;
			else if(funct3 == FUNCT3_OR) aluOp = OR;
			else if(funct3 == FUNCT3_AND) aluOp = AND;
			else if(funct3 == FUNCT3_SRL) aluOp = SRL;
			else begin end
			end
		LOAD: aluOp = ADD;
		STORE: aluOp = ADD;
		default: aluOp = 4'b1111;
	endcase
	end
endmodule