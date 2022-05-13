module PC(
    input reset,       // input (Use reset to initialize PC. Initial value must be 0)
    input clk,         // input
    input PCwrite,
    input [1:0] is_halted,
    input [31:0] next_pc,     // input
    output reg [31:0] current_pc   // output
  );


always @(posedge clk)begin
    if(reset)begin
        current_pc<=0;
    end
    else if (PCwrite && !is_halted) begin
        current_pc<=next_pc;
    end
end


endmodule