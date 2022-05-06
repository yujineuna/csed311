module branchpredictor(

input [31:0] pc;
input btb_update;
input [31:0] real_pc;
input [4:0] write_index;
input [24:0] tag_write;
output reg[31:0] pred_pc;
output reg taken;
);

reg [24:0] tag_table[0:31];
reg[31:0] btb[0:31];


//memory reset들어갔을떄 초기화

wire [4:0] btb_idx;
wire [24:0] tag;

assign btb_idx=pc[6:2];
assign tag=pc[31:7];

//when read asynchronous?

always @(*) begin
    if(tag==tag_table[btb_idx])
    begin
    taken=1;
    pred_pc=btb[btb_idx];
    end
    else
    begin
    taken=0;
    pred_pc=pc+4;
    end
end

//taken이 1이아니라 0일경우 nextpc를 pc+4로 update함 아닐 시 real_pc로 업데이트.

//when write btb to real_pc //synchoronous or asynchoronous?
always @(posedge clk)
if(btb_update)
begin
   btb[write_index]<=real_pc;
   tag_table[write_index]<=tag_write;
end
end





endmodule