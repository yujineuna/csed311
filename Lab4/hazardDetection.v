
module hazardDetection(
    input [31:0] rs1_ID,
    input [31:0] rs2_ID,
    input [31:0] rd_MEM_WB,
    input [31:0] rd_ID_EX,
    input mem_read,
    input reg_write,
    input [1:0]is_halted,
    output reg PCwrite,
    output reg IF_ID_write,
    output reg is_hazard
    );

    wire USE_rs1;
    wire USE_rs2;

    assign USE_rs1 = rs1_ID!=0;
    assign USE_rs2 = rs2_ID!=0;
    
    always @(*) begin
        //one stall for Load instruction
        if ((((rs1_ID == rd_ID_EX) && USE_rs1) || ((rs2_ID == rd_ID_EX) && USE_rs2)) && mem_read) begin
            PCwrite = 0;
            IF_ID_write = 0;
            is_hazard = 1;
        end
        //one stall because there is no internal forwarding
        else if ((((rs1_ID==rd_MEM_WB) && USE_rs1) || ((rs2_ID==rd_MEM_WB) && USE_rs2)) && reg_write) begin
            PCwrite = 0;
            IF_ID_write = 0;
            is_hazard = 1;
        end
        else if(is_halted >= 2) begin
            PCwrite=0;
            IF_ID_write=0;
            is_hazard=1;
        end
        else begin
            PCwrite = 1;
            IF_ID_write = 1;
            is_hazard = 0;
        end
    end

endmodule