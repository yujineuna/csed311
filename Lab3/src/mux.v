module mux2(mux_in1,mux_in2,control,mux_out);
input [31:0]mux_in1;
input [31:0]mux_in2;
input control;
output [31:0] mux_out;

assign mux_out =(control==0)?mux_in1:mux_in2;

endmodule

module mux4(mux_in1_1,mux_in2_1,mux_in3,mux_in4,control,mux_out);
input [31:0]mux_in1_1;
input [31:0]mux_in2_1;
input [31:0]mux_in3;
input [31:0]mux_in4;
input [1:0]control;
output reg[31:0] mux_out;

always@(*)begin
    if(control==2'b00)
    begin
        mux_out=mux_in1_1;
    end
    else if(control==2'b01)
    begin
        mux_out=mux_in2_1;
    end
    else if(control==2'b10)
    begin
        mux_out=mux_in3;
    end
    else if(control==2'b11)
    begin
        mux_out=mux_in4;
    end
end

endmodule