`include "opcodes.v"


//state
`define STATE_IF 3'b000
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
`define PC_A      1'b0
`define REG_A   1'b1

//ALU_SrcB
`define REG_B 2'b00
`define FOUR 2'b01
`define IMMD 2'b10


//pc_source
`define ALU_pc 1'b0
`define ALUOut_pc 1'b1




module ControlUnit(
	input [6:0] part_of_inst,//instr [6:0]
	input alu_bcond,
	output reg pvs_write_en,
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
    output reg ALU_SrcB,
    output reg ALU_SrcA,  // output
    output reg is_ecall );

reg current_state;
reg next_state;
reg is_rtype;
reg is_itype;
reg is_load;
reg is_store;
reg is_jal;
reg is_jalr;
reg is_branch;
reg is_ecall;
reg pvs_write_en;
reg is_ecall;


always@(*)begin // this is used for micro code controller input!instruction type determined
	is_rtype=0;
	is_itype=0;
	is_load=0;
	is_store=0;
	is_jal=0;
	is_jalr=0;
	is_branch=0;
	is_ecall=0;
	pvs_write_en=0;
	case (part_of_inst)
		`ARITHMETIC : is_rtype=`TRUE;//reg_write = 1;
		`ARITHMETIC_IMM : 
		         begin is_itype=`TRUE;
				end
		`LOAD: begin
			is_itype=`TRUE;
			is_load=`TRUE;
			end
		`JALR: begin
		   is_jalr=1;
			end
		`STORE: begin 
		is_itype=`TRUE;
		is_store=`TRUE;
		`BRANCH: is_branch = 1;
		`JAL: begin is_jal = 1; end
		`ECALL: begin 
		  is_ecall = 1;
		  if(rf17==10) is_halted=1;
		  else begin end
		end
		default:begin end
	endcase
end


always@(*)begin //this is microcode controller
	
	IorD=0;
	ir_write=0;
	pc_source=0;
	pc_write=0;
	pc_write_not_cond=0;
	ALU_SrcA=0;
	ALU_SrcB=2'b11;
	ALU_op=2'b00;
	reg_write=0;
	mem_read=0;
	mem_write=0;
	mem_to_reg=0;
	//initialization -> 필요한진 잘 모르겠음...

	case(current_state)
	`STATE_IF:begin
		mem_read=1;
		IorD=0;
		ir_write=1; //IR latching enabled
		//IR<-mem[PC]
	end

	`STATE_ID:begin
		//A<-RF[rs1]
		//B<=RF[rs2]
		//ALUOut<-pc+4
		ALU_SrcA=`PC_A;//pc
		ALU_SrcB=`FOUR;//offset
		ALU_op=`ADD;//add_op
	end
	//aluout에 pc+4가 저장된 상태
	`STATE_EX1:begin
		if(is_itype)begin //for itype
		ALU_SrcA=`REG_A;
		ALU_SrcB=`IMMD;
		ALU_op=`ADD;
		end
		else if (is_rtype)begin//for rtype
		ALU_SrcA=`REG_A;
		ALU_SrcB=`REG_B;
		ALU_op=`Func;
		end
		else if(is_branch)begin//if branch is not taken if !bcond then pc=pc+4
			ALU_SrcA=`REG_A;
			ALU_SrcB=`REG_B;//A-B
			ALU_op=`SUB;
			pvs_write_en=1;
			pc_write_not_cond=1;
			pc_source=`ALUOut_pc;//pc+4
		end
	end
	`STATE_EX2:begin
		if(is_branch)begin//if branch is taken then pc+immd is next pc
			ALU_SrcA=`PC_A;
			ALU_SrcB=`IMMD;
			ALU_op=`ADD;
			pvs_write_en=1;
			pc_write=1;
			pc_source=`ALU_pc;
	end
	end
	`STATE_MEM1:begin//load_store instruction
		if(is_load)begin
			mem_read=1;
			IorD=1;
		end
		else if(is_store)begin
			mem_write=1;
			IorD=1;
		end
	end
	`STATE_MEM2:begin//after storing pc_write pc=pc+4
		if(is_store)begin
		mem_write=1;
		ALU_SrcA=`PC_A;
		ALU_SrcB=`FOUR;
		ALU_op=`ADD;
		pc_write=1;
		pc_source=`ALU_pc;
		end
	end

	`STATE_WB:begin//rtype (from ex1)/ar-i type(from ex1)/load type(from mem1) /jalr&jal type(from id)
		reg_write=1;
		mem_to_reg=0;
		if(is_jal)begin // is jalr &is jal -> aluout contains pc+4
			//rf[rd]=pc+4;
			//pc<-pc+immd;
			reg_write=1;
			mem_to_reg=0;
			ALU_SrcA=`PC_A;
			ALU_SrcB=`IMMD;
			ALU_op=`ADD;
			pc_source=`ALU_pc;
			pvs_write_en=1;
			pc_write=1;
			pvs_write_en=1;
		end
		else if(is_jalr)begin
			//rf[rd]=pc+4;
			//pc<=A+immd;
			reg_write=1;
			mem_to_reg=0;
			ALU_SrcA=`REG_A;
			ALU_SrcB=`IMMD;
			ALU_op=`ADD;
			pc_source=`ALU_pc;
			pvs_write_en=1;
			pc_write=1;
			pvs_write_en=1;

		end
		else begin 
			if(is_load) mem_to_reg=1;
			//is_load / is_itype,is_rtype모두 포함
			reg_write=1;
			alu_src_A = `PC_A;
            alu_src_B = `FOUR;
            alu_op = `ADD;
				pvs_write_en=1;
                pc_write = 1;
                pc_src = `ALU_pc;
		end

	end
	
end


always @(*)begin
	case(current_state)
	`STATE_IF:begin
	next_state=`state_ID;
end
`STATE_ID:begin
	next_state=`STATE_EX1;
end
`STATE_EX1:begin

	if(is_store|is_load)begin
		next_state=`STATE_MEM1;
end
else if(is_rtype|is_itype)begin
	next_state=`STATE_WB;
end
else if(is_branch)begin
	if(!alu_bcond)begin
		next_state=`STATE_IF;
	end
end
else if(is_branch)begin
	next_state=`STATE_EX2;
end
end
`STATE_EX2:begin
	if(is_branch)begin
	next_state=`STATE_IF;//branch_taken
	end
end
`STATE_MEM_1: if(is_load)next_state=`STATE_WB;
else if (is_store) next_state=`STATE_MEM2;
`STATE_MEM_2: next_state=`STATE_IF;
`STATE_WB:next_state=`STATE_IF;
end


always @(posedge clk)begin
	if(!reset)begin
	current_state<=`STATE_IF;
	end
	else begin
		current_state<=next_state;
	end

end
end module