// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required
`include "controlSignals.v"

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0]IF_ID_inst;           // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
 

  // From others
  reg [31:0]ID_EX_rs1_data;
  reg [31:0]ID_EX_rs2_data;
  reg [31:0]ID_EX_imm;
  reg [3:0]ID_EX_ALU_ctrl_unit_input;
  reg [31:0]ID_EX_rs1;//forwarding
  reg [31:0]ID_EX_rs2;//fowarding
  reg [31:0]ID_EX_rd;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [31:0] EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg[31:0] MEM_WB_rd;

  reg [31:0] next_pc;
  wire [31:0] current_pc;
  wire [4:0] rs1;
  
  wire[31:0] iout;
  wire[31:0] dout;
  wire[31:0] rs1_dout;
  wire[31:0] rs2_dout;

  wire[31:0] writeData;

  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire alu_op;
  wire is_ecall;
  wire[6:0] control_signal;
  wire[6:0] control_sigs;

  wire [31:0] imm_gen_out;
  wire [3:0]func_code;

  wire[31:0] f_alu_in1;
  wire[31:0] f_alu_in2;


  wire[1:0] forward_A;
  wire[1:0] forward_B;
  wire[31:0] f_alu_in_1;
  wire[31:0] f_alu_in_2;
  wire[31:0]real_rs2;
  wire[31:0] alu_result;

  wire PCwrite;
  wire IFID_write;
  wire is_hazard;

  assign is_halted = (is_ecall && rs1_dout==10)? 1:0;

  mux2 rs1_selector(
    .mux_in1(IF_ID_inst[19:15]),
    .mux_in2(5'b10001),
    .control(is_ecall),
    .mux_out(rs1)
  );

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .PCwrite(PCwrite),   //input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  //for pc update
  always @(posedge clk) begin
    if(PCwrite) next_pc <= current_pc + 4;
  end


  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(iout)     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      IF_ID_inst <= 0;
    end
    else if(IFID_write) begin
      IF_ID_inst <= iout;
    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // inputs
    .rs1 (rs1),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (IF_ID_inst[11:7]),           // input
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
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  assign control_sigs = {mem_read,mem_to_reg,mem_write,alu_src,write_enable,pc_to_reg,alu_op};
  //-------control signal stop for stall------
  mux2 stall_control_sig (
    .mux_in1(control_sigs),
    .mux_in2(7'b0000000),
    .control(is_hazard),
    .mux_out(control_signal)
  );


  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst[31:0]),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      //control signal
      ID_EX_alu_op <= 0;  
      ID_EX_alu_src <= 0;
      ID_EX_mem_write <= 0;
      ID_EX_mem_read <= 0;
      ID_EX_mem_to_reg <= 0;
      ID_EX_reg_write <= 0;
      //data
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0; 
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_rs1 <= 0; 
      ID_EX_rs2 <= 0; 
      ID_EX_rd <= 0; 
    end
    else begin
      //control signal
      ID_EX_alu_op <= control_signal[`alu_op];     
      ID_EX_alu_src <= control_signal[`alu_src];
      ID_EX_mem_write <= control_signal[`mem_write];
      ID_EX_mem_read <= control_signal[`mem_read];
      ID_EX_mem_to_reg <= control_signal[`mem_to_reg];
      ID_EX_reg_write <= control_signal[`write_enable];
      //data
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= {IF_ID_inst[30],IF_ID_inst[14:12]};
      ID_EX_rs1 <= IF_ID_inst[19:15];
      ID_EX_rs2 <= IF_ID_inst[24:20];
      ID_EX_rd <= IF_ID_inst[11:7];
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
    .alu_op(func_code),      // input
    .alu_in_1(f_alu_in_1),    // input  
    .alu_in_2(f_alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_zero()     // output 몰?루
  );


  mux3 alu_src_1(
    .mux_in1(ID_EX_rs1_data),
    .mux_in2(writeData),
    .mux_in3(EX_MEM_alu_out),
    .control(forward_A),
    .mux_out(f_alu_in_1)
  );
  mux3 alu_src_2(
    .mux_in1(ID_EX_rs2_data),
    .mux_in2(writeData),
    .mux_in3(EX_MEM_alu_out),
    .control(forward_B),
    .mux_out(real_rs2)
  );

 mux2 rs2orI(
  .mux_in1(real_rs2),
  .mux_in2(ID_EX_imm),
  .control(ID_EX_alu_src),
  .mux_out(f_alu_in_2)
);
 // rs2_data와 imm중 결정하는 mux

forwardingUnit funit(
  .rs1_ID(ID_EX_rs1),
  .rs2_ID(ID_EX_rs2),
  .rd_EX_MEM(EX_MEM_rd),
  .rd_MEM_WB(MEM_WB_rd),
  .reg_write_EX_MEM(EX_MEM_reg_write),
  .reg_write_MEM_WB(MEM_WB_reg_write)

  
);

hazardDetection hunit(
  .rs1_ID(ID_EX_rs1),
  .rs2_ID(ID_EX_rs2),
  .rd_MEM_WB(MEM_WB_rd),
  .rd_EX_MEM(EX_MEM_rd),
  .use_rs1(IF_ID_inst[19:15]),
  .use_rs2(IF_ID_inst[24:20]),
  .mem_read(ID_EX_mem_read),
  .reg_write(MEM_WB_reg_write),
  .PCwrite(PCwrite),            //output
  .IF_ID_write(IFID_write),     //output
  .is_hazard(is_hazard)         //output
); 

//pc_write를 0으로 if/id write를 0으로 control을 0으로




//writeData mux
mux2 DataToWrite
(
  .mux_in1(MEM_WB_mem_to_reg_src_1),
  .mux_in2(MEM_WB_mem_to_reg_src_2),
  .control(MEM_WB_mem_to_reg),
  .mux_out(writeData)
);



  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      //control signal
      EX_MEM_mem_to_reg <= 0;
      EX_MEM_reg_write <= 0;
      EX_MEM_mem_write <= 0;
      EX_MEM_mem_read <= 0;
      //data
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
    end
    else begin
      //control signal
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_mem_read <= ID_EX_mem_read;
      //EX_MEM_is_branch ??
      //data
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= real_rs2;
      EX_MEM_rd <= ID_EX_rd;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),   // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (dout)        // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      //control signal of MEM/WB
      MEM_WB_mem_to_reg <= 0;
      MEM_WB_reg_write <= 0;
      //data of MEM/WB
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0;
    end
    else begin
      //control signal of MEM/WB
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
      MEM_WB_reg_write <= EX_MEM_reg_write;
      //data of MEM/WB
      MEM_WB_mem_to_reg_src_1 <= dout;
      MEM_WB_mem_to_reg_src_2 <= EX_MEM_alu_out;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

  
endmodule
