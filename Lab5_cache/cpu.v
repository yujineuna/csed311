// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required
`include "controlSignals.v"
`include "opcodes.v"

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output reg is_halted); // Whehther to finish simulation
           
 
  /***** Wire declarations *****/
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0]IF_ID_inst;
  reg [31:0] IF_ID_pred_pc; 
  reg [31:0] IF_ID_current_pc;
         // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [31:0] ID_EX_pred_pc;
  reg [31:0] ID_EX_current_pc; 
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_branch;
  reg [6:0] ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  reg ID_EX_pc_to_reg;
 

  // From others
  reg [31:0]ID_EX_rs1_data;
  reg [31:0]ID_EX_rs2_data;
  reg [31:0]ID_EX_imm;
  reg [3:0]ID_EX_ALU_ctrl_unit_input;
  reg [31:0]ID_EX_rs1;//forwarding
  reg [31:0]ID_EX_rs2;//fowarding
  reg [31:0]ID_EX_rd;
  reg [6:0] ID_EX_opcode;


  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg [31:0]EX_MEM_current_pc;
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  reg EX_MEM_pc_to_reg;
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [31:0] EX_MEM_rd;  
  reg [6:0] EX_MEM_opcode;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg[31:0] MEM_WB_current_pc;
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  reg MEM_WB_pc_to_reg;
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg[31:0] MEM_WB_rd;

reg [31:0] next_pc;
  wire [31:0] current_pc;
  wire [4:0] rs1;
  
  wire[31:0] iout;
  wire[31:0]inst;
  wire[31:0] dout;
  wire[31:0] rs1_dout;
  wire[31:0] rs2_dout;


  wire [31:0] writeMemData;
  wire[31:0] writeData;

  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire [6:0]alu_op;
  wire is_ecall;

  wire is_jal;
  wire is_jalr;
  wire branch;
  wire is_bubble;

  wire[15:0] control_signal;
  wire[15:0] control_sigs;

  wire [31:0] imm_gen_out;
  wire [3:0]func_code;
  wire alu_bcond;

  wire[1:0] forward_A;
  wire[1:0] forward_B;
  wire [31:0] final_alu_1;
  wire[31:0] f_alu_in_1;
  wire[31:0] f_alu_in_2;
  wire[31:0]real_rs2;
  wire[31:0] alu_result;

  wire PCwrite;
  wire IFID_write;
  wire is_hazard;
  wire is_ready;
  wire is_output_valid;
  wire is_hit;
  wire is_input_valid;
  reg cache_stall;
  reg PCwrite_cachestall;
  reg IFID_write_cachestall;


  reg [31:0] IF_ID_rs1;
  reg [31:0] IF_ID_rs2;  
  reg [1:0] halted_state;

  reg halt_type;
  reg [2:0]halt_signal;
   
  reg [31:0] real_pc;
  reg need_update;
  reg need_change;
    
always @(posedge clk)begin
end

  //---------------------------halted condition
  always @(*) begin
    if(is_ecall && ID_EX_rd == 17) begin
      if(ID_EX_alu_op == `LOAD) begin
        halted_state = 3;
        halt_type = 0;
      end
      else if (ID_EX_alu_op==`ARITHMETIC | ID_EX_alu_op==`ARITHMETIC_IMM) begin
        halted_state = 2;
        halt_type = 1;
      end
    end
  end

  always @(posedge clk) begin
    case (halted_state)
      2'b01: begin
        if(MEM_WB_mem_to_reg_src_1 == 10 && halt_type==0) halt_signal<= 1;
        else if(EX_MEM_alu_out==10 && halt_type==1) halt_signal <= 1;
        else halted_state <= 0;
      end
      2'b10: halted_state <= halted_state - 1;
      2'b11: halted_state <= halted_state - 1;
      default: halted_state <= 0;
    endcase
  end
  
  always@(posedge clk)begin
  if(halt_signal>=1)
  halt_signal<=halt_signal+1;
  if(halt_signal==4)
  is_halted<=1;
  end
  //-------------------halted condition end


  mux2 rs1_selector(
    .mux_in1(5'b10001),
    .mux_in2(IF_ID_inst[19:15]),
    .control(is_ecall),
    .mux_out(rs1)
  );

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .PCwrite(PCwrite&&!PCwrite_cachestall),   //input
    .is_halted(halted_state),
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  

  
  //****************//
  //then How can I update PC?
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(iout)     // output
  );
  
 mux2 ioutorBubble(
  .mux_in1({iout[31:7],7'bZZZZZZZ}),
  .mux_in2(iout),
  .control(need_change),
  .mux_out(inst)); // for IF instruction bubble


  wire taken;
  wire [31:0] pred_pc;
  reg btb_update;
  reg [4:0]write_index;
  reg [24:0]tag_write;


  branchpredictor bp(
  .reset(reset),
  .clk(clk),
  .pc(current_pc),
  .btb_update(btb_update),
  .real_pc(real_pc),
  .write_index( write_index),
  .tag_write(tag_write),
  .pred_pc(pred_pc),
  .taken(taken)
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      IF_ID_inst <= 0;
      IF_ID_pred_pc<=0;
      IF_ID_current_pc<=0;
    end
    else if(IFID_write&&!IFID_write_cachestall) begin
      IF_ID_inst <= inst;
      IF_ID_pred_pc<=pred_pc;
      IF_ID_current_pc<=current_pc;// is this has a relation ship with IFID_write?maybe,,,yes?
      end
      else begin end
    end

  always @(*) begin
    case(control_signal[`alu_op+6:`alu_op])
        `ARITHMETIC: begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = IF_ID_inst[24:20];
        end
        `ARITHMETIC_IMM:begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = 0;
        end
        `LOAD:begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = 0;
        end
        `JALR:begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = 0;
          
        end
        `STORE:begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = IF_ID_inst[24:20];
        end
        `BRANCH: begin
          IF_ID_rs1 = IF_ID_inst[19:15];
          IF_ID_rs2 = IF_ID_inst[24:20];
        end
        `JAL: begin
          IF_ID_rs1 = 0;
          IF_ID_rs2 = 0;
        end
      endcase
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // inputs
    .rs1 (rs1),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (writeData),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[6:0]),  // input
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .alu_op(alu_op),        // output
    .is_ecall(is_ecall),
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .branch(branch),
    .is_bubble(is_bubble)      // output (ecall inst)
  );

  assign control_sigs = {is_jal,is_jalr,branch,alu_op,mem_read,mem_to_reg,mem_write,alu_src,write_enable,pc_to_reg};
  //-------control signal stop for stall------
  mux2 stall_control_sig (
    .mux_in1(16'b0000000000000000),
    .mux_in2(control_sigs),
    .control(is_hazard||need_change||is_bubble||cache_stall),
    .mux_out(control_signal)
  );


  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .inst(IF_ID_inst[31:0]),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset||need_change||halt_signal) begin
      //control signal
      ID_EX_is_jal<=0;
      ID_EX_is_jalr<=0;
      ID_EX_branch<=0;
      ID_EX_alu_op <= 0;  
      ID_EX_alu_src <= 0;
      ID_EX_mem_write <= 0;
      ID_EX_mem_read <= 0;
      ID_EX_mem_to_reg <= 0;
      ID_EX_reg_write <= 0;
      ID_EX_pc_to_reg<=0;
      //data
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0; 
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_rs1 <= 0; 
      ID_EX_rs2 <= 0; 
      ID_EX_rd <= 0; 
      ID_EX_pred_pc<=0;
      ID_EX_current_pc<=0;
      ID_EX_opcode <= 0;
    end
    else if(cache_stall) begin end
    else begin
      //control signal
      ID_EX_is_jal<=control_signal[`is_jal];
      ID_EX_is_jalr<=control_signal[`is_jalr];
      ID_EX_branch<=control_signal[`branch];
      ID_EX_alu_op <=control_signal[`alu_op+6:`alu_op];    
      ID_EX_alu_src <= control_signal[`alu_src];
      ID_EX_mem_write <= control_signal[`mem_write];
      ID_EX_mem_read <= control_signal[`mem_read];
      ID_EX_mem_to_reg <= control_signal[`mem_to_reg];
      ID_EX_reg_write <= control_signal[`write_enable];
      ID_EX_pc_to_reg<=control_signal[`pc_to_reg];
      //data
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= {IF_ID_inst[30],IF_ID_inst[14:12]};
      ID_EX_pred_pc<=IF_ID_pred_pc;
      ID_EX_current_pc<=IF_ID_current_pc;
      ID_EX_opcode <= IF_ID_inst[6:0];
      //decide rs1, rs2, rd and imm(0)
      case(control_signal[`alu_op+6:`alu_op])
        `ARITHMETIC: begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= IF_ID_inst[24:20];
          ID_EX_rd <= IF_ID_inst[11:7];
        end
        `ARITHMETIC_IMM:begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= 0;
          ID_EX_rd <= IF_ID_inst[11:7];
        end
        `LOAD:begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= 0;
          ID_EX_rd <= IF_ID_inst[11:7];
        end
        `JALR:begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= 0;
          ID_EX_rd <= IF_ID_inst[11:7];
        end
        `STORE:begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= IF_ID_inst[24:20];
          ID_EX_rd <= 0;
        end
        `BRANCH: begin
          ID_EX_rs1 <= IF_ID_inst[19:15];
          ID_EX_rs2 <= IF_ID_inst[24:20];
          ID_EX_rd <= 0;
        end
        `JAL: begin
          ID_EX_rs1 <= 0;
          ID_EX_rs2 <= 0;
          ID_EX_rd <= IF_ID_inst[11:7];
        end
      endcase
    end
  end



//for computing real controlflow destination
//If ID_EX_branch signal is 1 then compare actual ALU(alu_result(in wire))outcome with ID_EX_pred_pc



//only taken branches and jumps are held in BTB

//if branch is not taken btb does not change
//if branch is taken btb changes
//if jal/ jalr instruction btb changes

always @(*)begin
  if(ID_EX_branch)begin
    if(!alu_bcond) begin
    real_pc=ID_EX_current_pc+4;end
  else begin
      real_pc=ID_EX_current_pc+ID_EX_imm;
    end
  end
  else if(ID_EX_is_jal)begin
    real_pc=ID_EX_current_pc+ID_EX_imm;
  end
  else if(ID_EX_is_jalr)begin
    real_pc=(f_alu_in_1+ID_EX_imm)&32'hFFFFFFFE;
  end
  else begin real_pc=0;end
end



always @(*)begin
  if(ID_EX_branch&&alu_bcond&&(real_pc!=ID_EX_pred_pc))
  begin 
    need_update=1;
    need_change=1;
  end
  else if(ID_EX_branch&&!alu_bcond)
  begin 
    need_update=0;
    if(real_pc!=ID_EX_pred_pc) need_change=1;
    else need_change=0;
  end
  else if((ID_EX_is_jal||ID_EX_is_jalr)&&(real_pc!=ID_EX_pred_pc))
  begin 
    need_update=1;
    need_change=1;
  end
  else begin 
    need_update=0;
    need_change=0;
  end
end

always @(*)begin
  if(need_change) next_pc = real_pc;
  else next_pc = pred_pc;
end


//when update next_pc
//two bubble if compare_result is 0

always @(*) begin//in both IF &ID make bubble
  if(need_update)begin//interpret it as bubble in IF/ID stage
    //btb table update is needed
    btb_update=1;
    write_index=ID_EX_current_pc[6:2];
    tag_write=ID_EX_current_pc[31:7];
  end
  else begin
    btb_update=0;
    write_index=ID_EX_current_pc[6:2];
    tag_write=ID_EX_current_pc[31:7];
  end
end





  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(ID_EX_ALU_ctrl_unit_input),
    .alu_op(ID_EX_alu_op),  // input
    .func_code(func_code)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op_alu(func_code),      // input
    .alu_in_1(final_alu_1),    // input  
    .alu_in_2(f_alu_in_2),    // input
    .alu_result(alu_result),
    .alu_bcond(alu_bcond)  // output 
  );


  mux3 alu_src_1(
    .mux_in1(ID_EX_rs1_data),//00
    .mux_in2(writeData),//01
    .mux_in3(EX_MEM_alu_out),//02
    .control(forward_A),
    .mux_out(f_alu_in_1)
  );

  mux2 pc_src1(
    .mux_in1(ID_EX_current_pc),
    .mux_in2(f_alu_in_1),
    .control(ID_EX_is_jal),
    .mux_out(final_alu_1)
  );
  mux3 alu_src_2(
    .mux_in1(ID_EX_rs2_data),
    .mux_in2(writeData),
    .mux_in3(EX_MEM_alu_out),
    .control(forward_B),
    .mux_out(real_rs2)
  );

 mux2 rs2orI(
  .mux_in1(ID_EX_imm),
  .mux_in2(real_rs2),
  .control(ID_EX_alu_src),
  .mux_out(f_alu_in_2)
);

forwardingUnit funit(
  .rs1_EX(ID_EX_rs1),
  .rs2_EX(ID_EX_rs2),
  .rd_EX_MEM(EX_MEM_rd),
  .rd_MEM_WB(MEM_WB_rd),
  .reg_write_EX_MEM(EX_MEM_reg_write),
  .reg_write_MEM_WB(MEM_WB_reg_write),
  .forward_A(forward_A),
  .forward_B(forward_B)  
);

hazardDetection hunit(
  .rs1_ID(IF_ID_rs1),
  .rs2_ID(IF_ID_rs2),
  .rd_MEM_WB(MEM_WB_rd),
  .rd_ID_EX(ID_EX_rd),
  .mem_read(ID_EX_mem_read),
  .reg_write(MEM_WB_reg_write),
  .is_halted(halted_state),
  .PCwrite(PCwrite),            //output
  .IF_ID_write(IFID_write),     //output
  .is_hazard(is_hazard)         //output
); 



  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset|| (halt_signal && !halt_type)) begin
      //control signal
      EX_MEM_mem_to_reg <= 0;
      EX_MEM_reg_write <= 0;
      EX_MEM_mem_write <= 0;
      EX_MEM_mem_read <= 0;
      EX_MEM_pc_to_reg<=0;
      EX_MEM_current_pc<=0;
      //data
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
      EX_MEM_opcode <= 0;
    end
    else if(cache_stall) begin end
    else begin
      //control signal
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_mem_read <= ID_EX_mem_read;
      EX_MEM_pc_to_reg<=ID_EX_pc_to_reg;
      EX_MEM_current_pc<=ID_EX_current_pc;
      //data
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= real_rs2;
      EX_MEM_rd <= ID_EX_rd;
      EX_MEM_opcode <= ID_EX_opcode;
    end
  end
  
  assign is_input_valid =(EX_MEM_opcode[6:0]==7'b0000011 || EX_MEM_opcode[6:0]==7'b0100011)? 1 : 0;
  //------------Cache-------------
  Cache cache(
    .reset(reset),
    .clk(clk),
    .is_input_valid(is_input_valid), //it means there is a request to Cache
    .addr(EX_MEM_alu_out),
    .mem_read(EX_MEM_mem_read),
    .mem_write(EX_MEM_mem_write),
    .din(EX_MEM_dmem_data),
    .is_ready(is_ready),    //output
    .is_output_valid(is_output_valid),   //output
    .dout(dout),    //output
    .is_hit(is_hit)   //output
  );

  //------------stall by cache: cache_stall means stall ------
  always @(*) begin
    if(is_input_valid) begin
      if(is_ready && is_hit && is_output_valid) begin
        cache_stall = 0;
        PCwrite_cachestall = 0;
        IFID_write_cachestall = 0;//so i think it can be just unified by cache_stall
      end
      else begin
        cache_stall = 1;
        PCwrite_cachestall = 1;
        IFID_write_cachestall = 1;
      end
    end
    else begin
      cache_stall = 0;
      PCwrite_cachestall = 0;
      IFID_write_cachestall = 0;
    end
  end

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      //control signal of MEM/WB
      MEM_WB_mem_to_reg <= 0;
      MEM_WB_reg_write <= 0;
      MEM_WB_pc_to_reg<=0;
      MEM_WB_current_pc<=0;
      //data of MEM/WB
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0;
    end    
    else if(cache_stall) begin end
    else begin
      //control signal of MEM/WB
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
      MEM_WB_reg_write <= EX_MEM_reg_write;
      MEM_WB_pc_to_reg<=EX_MEM_pc_to_reg;
      MEM_WB_current_pc<=EX_MEM_current_pc;
      //data of MEM/WB
      MEM_WB_mem_to_reg_src_1 <= dout;
      MEM_WB_mem_to_reg_src_2 <= EX_MEM_alu_out;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

//writeData mux
mux2 DataToWrite
(
  .mux_in1(MEM_WB_mem_to_reg_src_1),
  .mux_in2(MEM_WB_mem_to_reg_src_2),
  .control(MEM_WB_mem_to_reg),
  .mux_out(writeMemData)
);

mux2 pcWB
(
  .mux_in1(MEM_WB_current_pc+4),
  .mux_in2(writeMemData),
  .control(MEM_WB_pc_to_reg),
  .mux_out(writeData)
);
  
endmodule