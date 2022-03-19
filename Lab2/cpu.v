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

  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(),         // input
    .next_pc(),     // input
    .current_pc()   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(),   // input
    .clk(),     // input
    .addr(),    // input
    .dout()     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (),        // input
    .clk (),          // input
    .rs1 (),          // input
    .rs2 (),          // input
    .rd (),           // input
    .rd_din (),       // input
    .write_enable (),    // input
    .rs1_dout (),     // output
    .rs2_dout ()      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(opcode),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),     // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(),  // input
    .imm_gen_out()    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(),  // input
    .alu_op()         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(op),      // input
    .alu_in_1(data1),    // input  
    .alu_in_2(data2),    // input
    .alu_result(result),  // output
    .alu_bcond(bcond)//output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (addr),       // input
    .din (din),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (dout)        // output
  );
endmodule
