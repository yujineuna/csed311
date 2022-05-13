`include "opcodes.v"
`include "AluOps.v"


  // ID_EX_ALU_ctrl_unit_input <= {IF_ID_inst[30],IF_ID_inst[14:12]};
  //alu_op [6:0] opcode?��?��
  //IF_ID_inst[30]->is_sub
  //IF_ID_inst [14:12] funct3


module ALUControlUnit(part_of_inst, alu_op,func_code);

	input [6:0] alu_op;
    input[3:0] part_of_inst;
    output reg [3:0] func_code;
    
	reg [2:0] funct3;
	reg is_sub;


	always @(*) begin
		funct3 = part_of_inst[2:0];
		is_sub = part_of_inst[3];
	case(alu_op) 
		`BRANCH: begin
			if(funct3 == `FUNCT3_BEQ) func_code = `BEQ;
			else if(funct3 == `FUNCT3_BNE)func_code = `BNE;
			else if(funct3 == `FUNCT3_BLT) func_code = `BLT;
			else if(funct3 == `FUNCT3_BGE)func_code= `BGE;
			else begin end
			end
		`ARITHMETIC: begin 
			if(funct3 == `FUNCT3_ADD && is_sub == 0) func_code= `ADD;
			else if(funct3 == `FUNCT3_SUB && is_sub == 1) func_code = `SUB;
			else if(funct3 == `FUNCT3_SLL) func_code = `SLL;
			else if(funct3 == `FUNCT3_XOR) func_code = `XOR;
			else if(funct3 == `FUNCT3_OR) func_code = `OR;
			else if(funct3 == `FUNCT3_AND) func_code = `AND;
			else if(funct3 == `FUNCT3_SRL) func_code = `SRL;
			else begin end
			end
		`ARITHMETIC_IMM: begin 
			if(funct3 == `FUNCT3_ADD) func_code = `ADD;
			else if(funct3 == `FUNCT3_SLL) func_code = `SLL;
			else if(funct3 == `FUNCT3_XOR) func_code = `XOR;
			else if(funct3 == `FUNCT3_OR) func_code = `OR;
			else if(funct3 == `FUNCT3_AND) func_code = `AND;
			else if(funct3 == `FUNCT3_SRL) func_code = `SRL;
			else begin end
			end
		`JAL:func_code=`ADD;
		`JALR: func_code = `ADD;
		`LOAD: func_code = `ADD;
		`STORE: func_code = `ADD;
		default: begin func_code = 4'b1111;end
	endcase
	end
endmodule