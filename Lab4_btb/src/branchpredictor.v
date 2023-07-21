module branchpredictor(
input reset,
input clk,
input [31:0] pc,
input btb_update,
input [31:0] real_pc,
input [4:0] write_index,
input [24:0] tag_write,
output reg[31:0] pred_pc,
output reg taken
);

integer i;
reg [24:0] tag_table[0:31];
reg[31:0] btb[0:31];


//memory reset?��?��갔을?�� 초기?��

wire [4:0] btb_idx;
wire [24:0] tag;

assign btb_idx=pc[6:2];
assign tag=pc[31:7];

//when read asynchronous?

always @(*) begin
    if(reset)begin //btb initialziation
        for(i = 0; i < 32; i = i + 1)begin
            tag_table[i]=25'bZZZZZZZZZZZZZZZZZZZZZZZZZ;
            btb[i]=32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;
        end
        taken=0;
        pred_pc=0;
   end
   else begin
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

end


//when write btb to real_pc //synchoronous or asynchoronous?
always @(posedge clk) begin

if(btb_update)
begin
   btb[write_index]<=real_pc;
   tag_table[write_index]<=tag_write;
end
end





endmodule