module pc(
    input reset,       // input (Use reset to initialize PC. Initial value must be 0)
    input clk,         // input
    input [31:0] next_pc,     // input
    output [31:0] current_pc   // output
  );

initial begin
    current_pc<=0;
end

always @(*)begin
    if(reset_n)begin
        current_pc<=0
    end
end

always @(posedge clk)begin
    current_pc<=next_pc;
end


endmodule
