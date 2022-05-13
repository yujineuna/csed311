module branchpredictor(
   input reset,
   input clk,
   input [31:0] pc,
   input btb_update,
   input [31:0] real_pc,
   input [4:0] write_index,
   input [31:0] tag_write,
   input [1:0]real_taken,
   output reg[31:0] pred_pc,
   output reg taken
);

integer i;
reg [31:0] tag_table[0:31];
reg[31:0] btb[0:31]; // saturation counter
//reg [1:0] bht[0:31];
reg[1:0] branch_history_table[0:31];
reg[7:0] bhsr;

wire [4:0] btb_idx;
wire [24:0] tag;

assign btb_idx=pc[6:2]^bhsr[7:0];
assign tag=pc[31:0]; //tag is all bit of PC

//when read asynchronous?


//2bit global predictor,,howcan I use it?


always @(*) begin
   if(reset)begin //btb initialziation
      for(i = 0; i < 32; i = i + 1)begin
         tag_table[i] = 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;
         btb[i] = 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;
         branch_history_table[i] = 2'b11;
      end
      bhsr = 8'b11111111;
      taken=0;
      pred_pc=0;
   end
   else begin
      if(tag==tag_table[btb_idx]&&(branch_history_table[btb_idx]>=2'b10)) begin
         taken=1;
         pred_pc=btb[btb_idx];
      end
      else begin
         taken=0;
         pred_pc=pc+4;
      end
   end
end

//and bht enries update needed;

//when write btb to real_pc //synchoronous or asynchoronous?
always @(posedge clk) begin
   if(btb_update)
   begin
      btb[write_index]<=real_pc;
      tag_table[write_index]<=tag_write;
      //plus BHT update
   end

   if(real_taken==1)begin
      if(branch_history_table[btb_idx]==2'b11)begin end
      else branch_history_table[btb_idx] <= branch_history_table[btb_idx]+1;

      if(bhsr==8'b11111111)begin end
      else bhsr <= bhsr + 1;
   end
   else if(real_taken==0)begin
      if(branch_history_table[btb_idx]==2'b00)begin end
      else branch_history_table[btb_idx] <= branch_history_table[btb_idx]-1;

      if(bhsr==8'b00000000) begin end
      else bhsr <= bhsr - 1;
   end
   else begin end
end


endmodule