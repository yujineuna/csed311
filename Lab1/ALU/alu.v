module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
	always @(A or B or FuncCode) begin
		case(FuncCode)
			4'b0000: begin
				C = A + B;
				if(A[data_width - 1] == 0 && B[data_width - 1] == 0 && C[data_width - 1] == 1) OverflowFlag <= 1;
				else if(A[data_width - 1] == 1 && B[data_width - 1] == 1 && C[data_width - 1] == 0) OverflowFlag <= 1;
				else
					OverflowFlag <= 0;
			end 
			4'b0001: begin
				C = A - B;
				if(A[data_width - 1] == 0 && B[data_width - 1] == 1 && C[data_width - 1] == 1) OverflowFlag <= 1;
				else if(A[data_width - 1] == 1 && B[data_width - 1] == 0 && C[data_width - 1] == 0) OverflowFlag <= 1;
				else
					OverflowFlag <= 0;
			end 
			4'b0010: begin
				C <= A; OverflowFlag <= 0;
			end
			4'b0011: begin
				C <= ~A; OverflowFlag <= 0;
			end
			4'b0100: begin
				C <= A & B; OverflowFlag <= 0;
			end
			4'b0101: begin
				C <= A|B; OverflowFlag <= 0;
			end
			4'b0110: begin
				C <= ~(A&B); OverflowFlag <= 0;
			end
			4'b0111: begin
				C <= ~(A|B); OverflowFlag <= 0;
			end
			4'b1000: begin
				C <= A^B; OverflowFlag <= 0;
			end
			4'b1001: begin
				C <= ~(A^B); OverflowFlag <= 0;
			end
			4'b1010: begin
				C <= (A << 1); OverflowFlag <= 0;
			end
			4'b1011: begin
				C <= (A >> 1); OverflowFlag <= 0;
			end
			4'b1100: begin
				C <= (A <<<1); OverflowFlag <= 0;
			end
			4'b1101: begin
				C = (A >>> 1); OverflowFlag <= 0;
				if(A[data_width-1] == 1) C[data_width-1] = 1;
				else C[data_width-1] = 0;
			end
			4'b1110: begin
				C = ~A +1; OverflowFlag <= 0;
			end
			4'b1111: begin
				C <= 0; OverflowFlag <= 0;
			end
		endcase
	end
endmodule

