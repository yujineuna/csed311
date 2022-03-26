// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
wire is_halted;

wire [31:0] next_pc;
wire [31:0] current_pc;

wire [31:0] tempPc1;//pc+4
wire [31:0] tempPc2;//pc+immediatevalue
wire [31:0] tempPc;//for mux fromPCSrc1
//for pc

wire [31:0] dout;//for instruction


wire [31:0] rf17;
wire [31:0] rs1_dout;
wire [31:0] rs2_dout;
wire [31:0] writeData;//alu result or memory value or pc+4
wire [31:0] memOrALU; //for the mux memReadData's output
//for register
wire[31:0] mem_dout;
//for datamemory
wire [31:0] imm_gen_out;
//for immediate value generation


wire[31:0] alu_in_2;//alu source & mux output
wire [3:0] alu_op;//output of alu control unit
wire alu_bcond;//for bcond
wire [31:0]alu_result;



//for alu
  
//constant for pcplus4

reg write_enable;
wire wr_en;
wire is_jal;
wire is_jalr; // same as pc_src_2
wire branch;
wire mem_read;
wire mem_to_reg;
wire mem_write;
wire alu_src;
wire reg_write;
wire pc_to_reg;
wire is_ecall;
wire pc_src_1;

  /***** Register declarations *****/


assign pc_src_1 = (branch&alu_bcond) | is_jal;



  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pcupdator(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  adder pcplus4(
    .add1(current_pc), //input
    .add2(4), //input
    .addout(tempPc1) //output
  );

adder pcplusImm(
.add1(current_pc), //input
.add2(imm_gen_out), //input
.addout(tempPc2) //output
);

  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(dout)     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (dout[19:15]),          // input
    .rs2 (dout[24:20]),          // input
    .rd (dout[11:7]),           // input
    .rd_din (writeData),       // input
    .reg_write(reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout(rs2_dout),
    .rf17(rf17)
    //.rf_data(rf_data)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .reset(reset),
    .part_of_inst(dout[6:0]),
    .rf17(rf17),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),
    .reg_write(reg_write),       // output   // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall),
    .is_halted(is_halted)      // output (ecall inst)
  );


  mux DatatoWrite(
  .mux_in1(memOrALU),//mem[add]
  .mux_in2(tempPc1),//pc+4
  .control(pc_to_reg),
  .mux_out(writeData)
);

  mux memReadData(
  .mux_in1(alu_result),
  .mux_in2(mem_dout),//mem[add]
  .control(mem_to_reg),
  .mux_out(memOrALU)
);

  mux fromPCSrc1(
  .mux_in1(tempPc1),//pc+4
  .mux_in2(tempPc2),
  .control(pc_src_1),
  .mux_out(tempPc)
);

  mux fromPCSrc2(
  .mux_in1(tempPc),//pc+4||pc+immediate value
  .mux_in2(alu_result),
  .control(is_jalr),
  .mux_out(next_pc)
);

  mux rs2orI(
  .mux_in1(rs2_dout),
  .mux_in2(imm_gen_out),
  .control(alu_src),
  .mux_out(alu_in_2)
);


  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .inst(dout),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(dout),  // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input
    .rs1_dout(rs1_dout),    // input  
    .alu_in_2(alu_in_2),    // input -> mux's output
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (mem_dout)        // output
  );
endmodule
