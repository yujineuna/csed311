`include "opcodes.v"
module ImmediateGenerator(
    input [31:0] inst,  // input
    output reg [31:0] imm_gen_out  // output
  );

reg opcode;
  //according to instruction type

  always @(opcode) begin
     opcode = inst[6:0];
     if(opcode==`ARITHMETIC_IMM||opcode==`LOAD)
     begin
 imm_gen_out=$signed({inst[31],inst[30:25],inst[24:21],inst[20]});
     end
 else if(opcode==`STORE)
 begin
  imm_gen_out=$signed({inst[31],inst[30:25],inst[11:8],inst[7]});
 end
 else if(opcode==`BRANCH)
 begin
 imm_gen_out=$signed({inst[31],inst[7],inst[30:25],inst[11:8],0});
 end
 else if(opcode==`JAL||opcode==`JALR)
 begin
 imm_gen_out=$signed({inst[31],inst[19:12],inst[20],inst[30:25],inst[24:21],0});
 end

  end




//for i tyype
//for s type
//for b type
//for u type
//for j type



endmodule
