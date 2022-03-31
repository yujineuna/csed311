module PC(
    input reset,       // input (Use reset to initialize PC. Initial value must be 0)
    input clk,
    input pc_write,
    input alu_bcond,
    input pc_write_not_cond,        // input
    input [31:0] next_pc,     // input
    output reg [31:0] current_pc   // output
  );


always @(posedge clk)begin
    if(reset)begin
        current_pc <= 0;
    end
    if(pc_write || (!alu_bcond && pc_write_not_cond))begin
        current_pc <= next_pc;
    end
end


endmodule
