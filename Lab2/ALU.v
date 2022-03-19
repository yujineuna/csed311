`include "AluOps.v"

module ALU(alu_op,alu_in_1,alu_in_2,alu_result,alu_bcond);

	input [3:0]alu_op;
	input [31:0] alu_in_1;
	input [31:0] alu_in_2;
	output reg [31:0] alu_result;
	output reg alu_bcond;

//initialization
initial begin
  alu_result <= 0;
  alu_bcond <= 0;
end

	//calculate depend on op
	always @(alu_op) begin
		alu_result = 0;
		alu_bcond = 0;
		case(alu_op)
			`BEQ: begin
			 if(alu_in_1 - alu_in_2==0) alu_bcond =1;
			 else alu_bcond = 0;
			end
			`BNE: begin
			 if(alu_in_1-alu_in_2!=0) alu_bcond =1;
			 else alu_bcond = 0;
			end
			`BLT: begin
			 if(alu_in_1<alu_in_2) alu_bcond =1;
			 else alu_bcond = 0;
			end
			`BGE: begin
			 if(alu_in_1>alu_in_2) alu_bcond =1;
			 else alu_bcond = 0;
			end
			`ADD: alu_result = alu_in_1+alu_in_2;
			`SUB: alu_result = alu_in_1-alu_in_2;
			`SLL: alu_result = alu_in_1<<alu_in_2;
			`XOR: alu_result = alu_in_1^alu_in_2;
			`OR: alu_result = alu_in_1|alu_in_2;
			`AND: alu_result = alu_in_1&alu_in_2;
			`SRL: alu_result = alu_in_1>>alu_in_2;
		endcase
	end

endmodule