module mux(mux_in1,mux_in2,control,mux_out);
input [31:0]mux_in1;
input [31:0]mux_in2;
input control;
output [31:0] mux_out;

assign mux_out =(control==0)?mux_in1:mux_in2;

endmodule