`include "opcodes.v"
module ImmediateGenerator imm_gen(
    input [31:0] inst,  // input
    output [31:0] imm_gen_out  // output
  );

reg opcode =inst[6:0];
  //according to instruction type
 if(opcode==ARITHMETIC_IMM||opcode==LOAD)
 { imm_gen_out=$signed({inst[31],inst[30:25],inst[24:21],inst[20]})}
 else if(opcode==STORE)
 {imm_gen_out=$signed({inst[31],inst[30:25],inst[11:8],inst[7]})}
 else if(opcode==BRANCH)
 {imm_gen_out=$signed({inst[31],inst[7],inst[30:25],inst[11:8],0})}
 else if(opcode==JAL||opcode==JALR)
 {imm_gen_out=$signed({inst[31],inst[19:12],inst[20],inst[30:25],inst[24:21],0})}



//for i tyype
//for s type
//for b type
//for u type
//for j type



endmodule
