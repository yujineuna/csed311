`include "AluOps.v"

module ALU(op,data1,data2,result,bcond);

	input [3:0]op;
	input [31:0] data1;
	input [31:0] data2;
	output reg [31:0] result;
	output reg bcond;

//initialization
result = 0;
bcond = 0;

	//calculate depend on op
	always @(op) begin
		result = 0;
		bcond = 0;
		case(op)
			BEQ: begin
			 if(data1-data2==0) bcond =1;
			 else bcond = 0;
			end
			BNE: begin
			 if(data1-data2!=0) bcond =1;
			 else bcond = 0;
			end
			BLT: begin
			 if(data1<data2) bcond =1;
			 else bcond = 0;
			end
			BGE: begin
			 if(data1>data2) bcond =1;
			 else bcond = 0;
			end
			ADD: result = data1+data2;
			SUB: result = data1-data2;
			SLL: result = data1>>data2;
			XOR: result = data1^data2;
			OR: result = data1|data2;
			AND: result = data1&data2;
			SRL: result = data1<<data2;
		endcase
	end

endmodule