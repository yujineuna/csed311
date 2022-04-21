
module hazardDetection(
    input [31:0] rs1_ID,
    input [31:0] rs2_ID,
    input [31:0] rd_MEM_WB,
    input [31:0] rd_EX_MEM,
    input [4:0] use_rs1,
    input [4:0] use_rs2,
    input mem_read,
    input reg_write,
    output reg PCwrite,
    output reg IF_ID_write,
    output reg is_hazard
    );

    reg USE_rs1;
    reg USE_rs2;

    always @(*) begin
        USE_rs1 = ($signed(use_rs1)==rs1_ID && rs1_ID!=0);
        USE_rs2 = ($signed(use_rs2)==rs2_ID && rs2_ID!=0);
        //one stall for Load instruction
        if ((((rs1_ID == rd_EX_MEM) && USE_rs1) || ((rs2_ID == rd_EX_MEM) && use_rs2)) && mem_read) begin
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
        else begin
            PCwrite = 1;
            IF_ID_write = 1;
            is_hazard = 0;
        end
    end

endmodule