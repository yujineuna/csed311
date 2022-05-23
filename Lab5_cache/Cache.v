`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16, /* Your choice */
               parameter NUM_WAYS = 1, /* Your choice */
               parameter TAG_SIZE = 24,
               parameter IDX_SIZE = `CLOG2(NUM_SETS)) (
    input reset,
    input clk,

    input is_input_valid, 
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);
  
  // Wire declarations
  wire is_data_mem_ready;
  wire [TAG_SIZE-1:0] tag;
  wire [IDX_SIZE-1:0] idx;
  wire [1:0] block_offset;
  wire mem_output_valid;

  // Reg declarations
  reg [0:LINE_SIZE*8-1] data_bank [0:NUM_SETS-1];
  reg [TAG_SIZE-1:0] tag_bank [0:NUM_SETS-1];
  reg valid_table [0:NUM_SETS-1];
  reg dirty_table [0:NUM_SETS-1];
  wire [LINE_SIZE*8-1:0] mem_dout;
  wire [31:0] mem_addr;

  integer i;

  // You might need registers to keep the status.
  assign is_output_valid = valid_table[idx]==1 ? 1 : 0;
  assign is_ready = is_data_mem_ready;
  assign tag = addr[31:8];
  assign idx = addr[7:4];
  assign block_offset = addr[3:2];

  // Set initial cache value
  always @(posedge clk) begin
    if(reset) begin
      for(i = 0; i < NUM_SETS; i = i + 1) begin
        tag_bank[i] = 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
        data_bank[i] = 128'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
        valid_table[i] = 0;
        dirty_table[i] = 0;
      end
    end
    // Update memory when cache miss: both write miss, read miss
    else if(mem_output_valid) begin
      data_bank[idx] <= mem_dout;
      dirty_table[idx] <= 0;
      tag_bank[idx] <= tag;
      valid_table[idx] <= 1;
    end

   /* // Update tag when cache miss
    else if(!is_hit && is_input_valid) begin
      tag_bank[idx] <= tag;
      valid_table[idx] <= 1;
    end*/
  end

  // Check the value of cache with idx and block_offset
  always @(*) begin    
    if ((tag_bank[idx] == tag) && valid_table[idx]) is_hit = 1;
    else is_hit = 0;
    // Read cache
    if(is_hit && mem_read) begin
      case(block_offset)
        0: dout = data_bank[idx][0:31];
        1: dout = data_bank[idx][32:63];
        2: dout = data_bank[idx][64:95];
        3: dout = data_bank[idx][96:127];
      endcase
    end
  end

  // Write cache
  always @(posedge clk) begin
    if(is_hit && mem_write && dirty_table[idx]==0) begin
      case(block_offset)
        0: data_bank[idx][0:31] <= din;
        1: data_bank[idx][32:63] <= din;
        2: data_bank[idx][64:95] <= din;
        3: data_bank[idx][96:127] <= din;
      endcase
      dirty_table[idx] <= 1;
    end
  end
  wire[31:0] a1;
  wire[31:0] a2;
  assign a1 = tag[idx]<<4;
  assign a2 = ((addr>>`CLOG2(LINE_SIZE))<<`CLOG2(LINE_SIZE));


  assign mem_addr = (mem_write && !is_hit && valid_table[idx]!=0 && !mem_output_valid) ? a1 : a2;
  //when cache stall it also access to memory

  // Instantiate data memory
  DataMemory data_mem (
    .reset(reset),
    .clk(clk),
 
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready), //output
    .is_input_valid(is_input_valid),  //input

    // is output from the data memory valid?
    .is_output_valid(mem_output_valid),  //output
    .dout(mem_dout),  //output

    // send inputs to the data memory.
    .addr(mem_addr),        // send original address that comes from the cpu
    .mem_read((mem_read||mem_write)&&!is_hit), 
    .mem_write((mem_write && is_hit && dirty_table[idx]==1)||(mem_write && !is_hit && valid_table[idx]!=0)),
    .din(data_bank[idx])
  );

endmodule
//when access data 4block at once...!

//mem_output_valid why not using?