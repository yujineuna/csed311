`include "opcodes.v"


//state
`define STATE_IF1 3'b000
`define STATE_IF2 3'b111
`define STATE_ID 3'b001
`define STATE_EX1 3'b010
`define STATE_EX2 3'b011
`define STATE_MEM1 3'b100
`define STATE_MEM2 3'b101
`define STATE_WB 3'b110

//ALU control
`define ADD 2'b00
`define SUB 2'b01
`define Func 2'b10

//ALU_SrcA
`define PC_A    1'b0
`define REG_A   1'b1

//ALU_SrcB
`define REG_B 2'b00
`define FOUR 2'b01
`define IMMD 2'b10


//pc_source
`define ALU_pc 1'b0
`define ALUOut_pc 1'b1



module ControlUnit(
	input clk,
	input reset,
	input [6:0] part_of_inst,//instr [6:0]
	input alu_bcond,
    output reg pc_write_not_cond,        // output
    output reg pc_write,       // output
    output reg IorD,        // output
    output reg mem_read,      // output
    output reg mem_to_reg,    // output
   output reg mem_write,     // output
    output reg ir_write,       // output
    output reg reg_write,     // output
    output reg pc_source,
    output reg [1:0] ALU_op,
    output reg [1:0]ALU_SrcB,
    output reg ALU_SrcA,  // output
    output reg is_ecall
	 );
	


reg [2:0]current_state;
reg [2:0]next_state;
reg is_rtype;
reg is_itype;
reg is_load;
reg is_store;
reg is_jal;
reg is_jalr;
reg is_branch;


always@(*)begin //this is microcode controller
    is_rtype=0;
	is_itype=0;
	is_load=0;
	is_store=0;
	is_jal=0;
	is_jalr=0;
	is_branch=0;
	is_ecall=0;
	case (part_of_inst)
	
		`ARITHMETIC : is_rtype=1;//reg_write = 1;
		`ARITHMETIC_IMM : is_itype=1;
		`LOAD: begin
			is_itype=1;
			is_load=1;
		end
		`JALR: begin
		   is_jalr=1;
		end
		`STORE: begin 
		is_itype=1;
		is_store=1;
		end
		`BRANCH: is_branch = 1;
		`JAL: begin is_jal = 1; end
		`ECALL: begin 
		  is_ecall = 1;
		end
		default:begin end
	endcase
end

always @(*)begin
mem_read=0;
ir_write=0;
mem_write=0;
mem_to_reg=0;
reg_write=0;
pc_source=0;
pc_write=0;
pc_write_not_cond=0;

	case(current_state)
		`STATE_IF1: begin
			mem_read=1;
			IorD=0;
			ir_write=1; //IR latching enabled
		//write: IR<-mem[PC]
		end
		`STATE_IF2:begin
			if(is_ecall)begin
				ALU_SrcA=`PC_A;//pc
				ALU_SrcB=`FOUR;//offset
				ALU_op=`ADD;
				pc_source=`ALU_pc;
				pc_write=1;
			end
			mem_read=1;
			IorD=0;
			ir_write=1;
		end

		`STATE_ID: begin
			ALU_SrcA=`PC_A;//pc
			ALU_SrcB=`FOUR;//offset
			ALU_op=`ADD;//add_op
			//write: A<-RF[rs1]
			//write: B<=RF[rs2]
			//write: ALUOut<-pc+4
		end
		
		`STATE_EX1: begin
			if(is_itype) begin //for itype: calculate GPR[rs1]+imm and update pc<-pc+4
				ALU_SrcA = `REG_A;
				ALU_SrcB = `IMMD;
				ALU_op = `Func;
				//pc_source = 1;
				//pc_write = 1;
				
			end
			else if (is_rtype) begin//for rtype: calculate GPR[rs1] (op) GPR[rs2] and update pc<-pc+4
				ALU_SrcA = `REG_A;
				ALU_SrcB = `REG_B;
				ALU_op = `Func;
				//pc_source = 1;
				//pc_write = 1;
			end
			else if(is_branch) begin//if branch is not taken if !bcond then pc=pc+4
				ALU_SrcA = `REG_A;
				ALU_SrcB = `REG_B;//A-B
				ALU_op = `Func;
				pc_write_not_cond = 1;
				pc_source = `ALUOut_pc;//pc+4
			end
			else if(is_load | is_store) begin //for LOAD/SOTRE instruction: calculate the address and update pc<-pc+4
				ALU_SrcA = `REG_A;
				ALU_SrcB = `IMMD;
				ALU_op = `ADD;
			end
		end
		`STATE_EX2: begin
			if(is_branch) begin//if branch is taken then pc+immd is next pc
				ALU_SrcA = `PC_A;
				ALU_SrcB = `IMMD;
				ALU_op = `ADD;
				pc_write = 1;
				pc_source = `ALU_pc;
			end
		end
		`STATE_MEM1:begin//load_store instruction
			if(is_load)begin
				mem_read = 1;
				IorD = 1;
			end
			else if(is_store)begin
				mem_write = 1;
				IorD = 1;
				ALU_SrcA=`PC_A;
				ALU_SrcB=`FOUR;
				ALU_op=`ADD;
				pc_write=1;
				pc_source=`ALU_pc;
			end
		end

		`STATE_WB: begin
			reg_write = 1;
			mem_to_reg=0;
			if(is_rtype | is_itype) begin //for R-type, I-type: GPR[rd]<-ALUOut(the result of EX1 calculation)
				if(is_load)begin 
					mem_to_reg = 1;
					IorD = 0;
				end
				ALU_SrcA=`PC_A;
				ALU_SrcB=`FOUR;
				ALU_op=`ADD;
				pc_source=`ALU_pc;
				pc_write=1;
			end
			else if(is_jal) begin //for JAL: GPR[rd]<-ALUOut(pc+4), pc<-pc+imm
				//GPR[rd]<-ALUOut(pc+4)
				//pc<-pc+imm
				ALU_SrcA = `PC_A;
				ALU_SrcB = `IMMD;
				ALU_op = `ADD;
				pc_source = `ALU_pc;
				pc_write = 1;
			end
			else if(is_jalr) begin //for JALR: GPR[rd]<-ALUOut(pc+4), pc<-GPR[rs1]+imm
				//GPR[rd]<-ALUOut(pc+4)
				//pc<-GPR[rs1]+imm
				ALU_SrcA = `REG_A;
				ALU_SrcB = `IMMD;
				ALU_op = `ADD;
				pc_source = `ALU_pc;
				pc_write = 1;
			end
		end
	endcase
end




always @(*) begin

	case(current_state)
		`STATE_IF1: begin
		next_state = `STATE_IF2;
		end
		`STATE_IF2:begin
		if(is_ecall)next_state=`STATE_IF1;
		else next_state=`STATE_ID;
		end	
		`STATE_ID: begin
			if(is_jal | is_jalr) next_state = `STATE_WB;
			else next_state = `STATE_EX1;
		end
		`STATE_EX1: begin
			if(is_store|is_load) next_state = `STATE_MEM1;
			else if(is_rtype | is_itype) next_state = `STATE_WB;
			else if(is_branch) begin
				if(alu_bcond) next_state = `STATE_EX2;
				else next_state = `STATE_IF1;
			end
			else next_state = `STATE_IF1;
		end
		`STATE_EX2: next_state = `STATE_IF1;
		`STATE_MEM1: begin
			if(is_load) next_state = `STATE_WB;
			else next_state = `STATE_IF1;
		end
		`STATE_WB: next_state = `STATE_IF1;
	endcase
	
	end
	
always @(posedge clk)begin
	if(reset)begin
		current_state <= `STATE_IF1;
	end
	else begin
		current_state <= next_state;
	end
end
endmodule