module PC(
    input reset,       // input (Use reset to initialize PC. Initial value must be 0)
    input clk,         // input
    input [31:0] next_pc,     // input
    output [31:0] current_pc   // output
  );

reg [31:0] pc;
assign current_pc=pc;

initial begin
    pc<=0;
end

always @(*)begin
    if(reset)begin
        pc<=0;
    end
end

always @(posedge clk)begin
    pc<=next_pc;
end


endmodule
