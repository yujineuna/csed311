module branchpredictor(
input reset,
input clk,
input [31:0] pc,
input btb_update,
input [31:0] real_pc,
input [4:0] write_index,
input [24:0] tag_write,
input [1:0]real_taken,
output reg[31:0] pred_pc,
output reg taken
);

integer i;
reg [24:0] tag_table[0:31];
reg[31:0] btb[0:31]; // saturation counter
//reg [1:0] bht[0:31];
reg[1:0] global_counter;

wire [4:0] btb_idx;
wire [24:0] tag;

assign btb_idx=pc[6:2];
assign tag=pc[31:7];

//when read asynchronous?


//2bit global predictor,,howcan I use it?


always @(*) begin
    if(reset)begin //btb initialziation
        for(i = 0; i < 32; i = i + 1)begin
            tag_table[i]=25'bZZZZZZZZZZZZZZZZZZZZZZZZZ;
            btb[i]=32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;
        
           //bht[i]=2'b11;
        end
        global_counter=2'b11;
        taken=0;
        pred_pc=0;
   end


   else begin
    //if(tag==tag_table[btb_idx]&&(bht[btb_idx]>=2'b10))
    if(tag==tag_table[btb_idx]&&(global_counter>=2'b10))
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

//and bht enries update needed;

//when write btb to real_pc //synchoronous or asynchoronous?
always @(posedge clk) begin

if(btb_update)
begin
   btb[write_index]<=real_pc;
   tag_table[write_index]<=tag_write;

   //plus BHT update
end

/*if(real_taken==1)
   begin
       if(bht[btb_idx]==2'b11) begin end
       else if(bht[btb_idx]==2'b10)bht[btb_idx]<=bht[btb_idx]+1;
       else if(bht[btb_idx]==2'b01)bht[btb_idx]<=bht[btb_idx]+2;
       else if(bht[btb_idx]==2'b00)bht[btb_idx]<=bht[btb_idx]+1;
   end
    else if(real_taken==0)begin
 if(bht[btb_idx]==2'b11) bht[btb_idx]<=bht[btb_idx]-1;
       else if(bht[btb_idx]==2'b10)bht[btb_idx]<=bht[btb_idx]-2;
       else if(bht[btb_idx]==2'b01)bht[btb_idx]<=bht[btb_idx]-1;
       else if(bht[btb_idx]==2'b00)begin end

end
else begin end
*/
/*
if(real_taken==1)begin 
if(global_counter==2'b11) begin end
       else if(global_counter==2'b10)global_counter<=global_counter+1;
       else if(gloabl_counter==2'b01)global_counter<=global_counter+2;
       else if(bht[btb_idx]==2'b00)global_counter<=global_counter+1;
 else if(real_taken==0)begin
 if(global_counter==2'b11) begin global_counter<=global_counter-1;end
       else if(global_counter==2'b10)global_counter<=global_counter-2;
       else if(gloabl_counter==2'b01)global_counter<=global_counter-1;
       else if(bht[btb_idx]==2'b00)begin end
 
end
*/

if(real_taken==1)begin
//if (bht[btb_idx]==2'b11)begin end
//else bht[btb_idx]<=bht[btb_idx]+1;
if(global_counter==2'b11)begin end
else global_counter<=global_counter+1;
end
else if(real_taken==0)begin
//if(bht[btb_idx]==2'b00)begin end
//else bht[btb_idx]<=bht[btb_idx]-1;
if(global_counter==2'b00)begin end
else global_counter<=global_counter-1;
end
else begin end
end


endmodule