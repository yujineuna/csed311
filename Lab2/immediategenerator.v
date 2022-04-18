`include "opcodes.v"
module ImmediateGenerator(
    input [31:0] inst,  // input
    output reg [31:0] imm_gen_out  // output
  );

reg [6:0] opcode;

  //according to instruction type
reg [11:0] imm11;
reg[12:0] imm13;
reg[20:0] imm22;


  always @(*) begin
     opcode = inst[6:0];
     if(opcode==`ARITHMETIC_IMM||opcode==`LOAD)
     begin
     imm11={inst[31],inst[30:25],inst[24:21],inst[20]};
     imm_gen_out=$signed(imm11);
     end
 else if(opcode==`STORE)
 begin
 imm11={inst[31],inst[30:25],inst[11:8],inst[7]};
  imm_gen_out=$signed(imm11);
 end
 else if(opcode==`BRANCH)
 begin
 imm13={inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
 imm_gen_out=$signed(imm13);
 end
 else if(opcode==`JAL)
 begin
 imm22={inst[31],inst[19:12],inst[20],inst[30:25],inst[24:21],1'b0};
 imm_gen_out=$signed(imm22);
 end
 else if(opcode==`JALR)
 begin
 imm_gen_out=$signed(inst[31:20]);
 end

  end




//for i tyype
//for s type
//for b type
//for u type
//for j type



endmodule