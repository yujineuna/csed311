`include "AluOps.v"

module ALU(alu_op,rs1_dout,alu_in_2,alu_result,alu_bcond);

	input [3:0]alu_op;
	input [31:0] rs1_dout;
	input [31:0] alu_in_2;
	output reg [31:0] alu_result;
	output reg alu_bcond;
	

initial begin
  alu_result <= 0;
  alu_bcond <= 0;
end

	//calculate depend on op
	always @(*) begin
		alu_result <= 0;
		alu_bcond <= 0;
		case(alu_op)
			`BEQ: begin
			 if((rs1_dout - alu_in_2)==0) alu_bcond <=1;
			 else alu_bcond <= 0;
			end
			`BNE: begin
			 if((rs1_dout-alu_in_2)!=0) alu_bcond <=1;
			 else alu_bcond <= 0;
			end
			`BLT: begin
			 if(rs1_dout<alu_in_2) alu_bcond <=1;
			 else alu_bcond <= 0;
			end
			`BGE: begin
			 if(rs1_dout>=alu_in_2) alu_bcond <=1;
			 else alu_bcond <= 0;
			end
			`ADD: alu_result <= rs1_dout+alu_in_2;
			`SUB: alu_result <= rs1_dout-alu_in_2;
			`SLL: alu_result <= rs1_dout<<alu_in_2;
			`XOR: alu_result <= rs1_dout^alu_in_2;
			`OR: alu_result <= rs1_dout|alu_in_2;
			`AND: alu_result <= rs1_dout&alu_in_2;
			`SRL: alu_result <= rs1_dout>>alu_in_2;
			default:begin end
		endcase
		end

endmodule