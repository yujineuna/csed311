module adder(add1, add2, addout)
input [31:0] add1;
input [31:0] add2;
output[31:0] addout;

assign addout=add1+add2;

endmodule