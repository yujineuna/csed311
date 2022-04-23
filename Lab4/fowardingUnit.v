module forwardingUnit(
  input[4:0]rs1_EX,
  input[4:0]rs2_EX,
  input[4:0]rd_EX_MEM,
  input[4:0]rd_MEM_WB,
  input reg_write_EX_MEM,
  input reg_write_MEM_WB,
  output reg[1:0]forward_A,
  output reg[1:0]forward_B);

always @(*)begin
    /*
    if(reg_write_EX_MEM)begin
        if((rs1_EX!=0)&&(rs1_EX==rd_EX_MEM))
        begin
        forward_A=2'b10;//memory  
        end
        else forward_A=2'b00;
        if((rs2_EX!=0)&&(rs2_EX==rd_EX_MEM))
        begin
        forward_B=2'b10;//memory
        end
        else forward_B=2'b00;
    end

    else if(reg_write_MEM_WB)begin
        if ((rs1_EX!=0)&&(rs1_EX==rd_MEM_WB))
        begin
        forward_A=2'b01;
        end
        else forward_A=2'b00;
        if ((rs2_EX!=0)&&(rs2_EX==rd_MEM_WB))
        begin
        forward_B=2'b01;//wb
        end
        else forward_B=2'b00;
        end

    else
        begin
        forward_A=2'b00;
        forward_B=2'b00;
    end*/
    if ( rd_MEM_WB == rd_EX_MEM) begin
        //forward_A
        if(reg_write_EX_MEM && (rs1_EX!=0)&&(rs1_EX==rd_EX_MEM)) forward_A = 2'b10;
        else if (reg_write_MEM_WB && (rs1_EX!=0)&&(rs1_EX==rd_MEM_WB)) forward_A = 2'b01;
        else forward_A = 2'b00;
        //forward_B
        if(reg_write_EX_MEM && (rs2_EX!=0)&&(rs2_EX==rd_EX_MEM)) forward_B = 2'b10;
        else if (reg_write_MEM_WB && (rs2_EX!=0)&&(rs2_EX==rd_MEM_WB)) forward_B = 2'b01;
        else forward_B = 2'b00;
    end
    else begin
        //forward_A
        if (reg_write_MEM_WB && (rs1_EX!=0)&&(rs1_EX==rd_MEM_WB)) forward_A = 2'b01;
        else if(reg_write_EX_MEM && (rs1_EX!=0)&&(rs1_EX==rd_EX_MEM)) forward_A = 2'b10;
        else forward_A = 2'b00;
        //forward_B
        if (reg_write_MEM_WB && (rs2_EX!=0)&&(rs2_EX==rd_MEM_WB)) forward_B = 2'b01;
        else if(reg_write_EX_MEM && (rs2_EX!=0)&&(rs2_EX==rd_EX_MEM)) forward_B = 2'b10;
        else forward_B = 2'b00;
    end
end



endmodule