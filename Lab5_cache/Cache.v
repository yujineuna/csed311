`include "CLOG2.v"
`include "state.v"

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


  reg data_req;
  reg tag_req;
  reg [0:LINE_SIZE*8-1]data_write;
  reg valid_req;
  reg dirty_req;

  reg mem_valid_req;
  reg mem_req_read;
  reg mem_req_write;
  reg [31:0] mem_req_addr;
  reg [1:0] current_state;
  reg [1:0] next_state;




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
  end


  //cache 
  always @(posedge clk) begin
    if(data_req) begin
      data_bank[idx] <= data_write;
    end
    if(tag_req)begin
      tag_bank[idx] <=tag;
    end
    if(valid_req)begin
      valid_table[idx] <= 1;
    end
    if(dirty_req)begin
      dirty_table[idx] <= 1;
    end
  end

  //when cache stall it also access to memory


  //---------------FSM---------------------------
  always @(*)begin
    is_hit=0;
    tag_req=0;
    data_req=0;
    valid_req=0;
    dirty_req=0;
    // Write din
    data_write = data_bank[idx];
    case(block_offset)
      0: data_write[0:31] = din;
      1: data_write[32:63] = din;
      2: data_write[64:95] = din;
      3: data_write[96:127] = din;
    endcase

    case(block_offset)
      0: dout = data_bank[idx][0:31];
      1: dout = data_bank[idx][32:63];
      2: dout = data_bank[idx][64:95];
      3: dout = data_bank[idx][96:127];
    endcase

    mem_valid_req=0;
    mem_req_addr={addr[31:4],4'b0000};
    mem_req_read=0;
    mem_req_write=0;

    case(current_state)
      `idle :begin // cache is not working
        if(is_input_valid)
          next_state = `tag_compare;
        else next_state = `idle;
      end
      `tag_compare:begin
        if(tag==tag_bank[idx]&&valid_table[idx])begin 
          is_hit=1;
        //tag match and cache line is valid  
        //write hit
          if(mem_write)begin
            data_req=1;
            tag_req=1;
            valid_req=1;
            dirty_req=1;
          end
          next_state = `idle;
        end
        else begin//cache miss
          tag_req=1;
          valid_req=1;
          dirty_req=mem_write;
          mem_valid_req=1;
          //miss with clean block
          if(valid_table[idx]==0||dirty_table[idx]==0) begin
            next_state = `allocate;
            mem_req_read=1;
          end
          //miss with dirty line
          else begin 
            mem_req_addr={tag_bank[idx],idx,4'b0000};
            mem_req_write=1;
            next_state = `write_back;
          end
        end
      end 
      `allocate: begin
        if(mem_output_valid)begin 
          // wait until the memory respond to..
          next_state = `tag_compare;
          //data_write = mem_dout;
          //data_req=1;
        end
      end
      `write_back:begin
        if(is_data_mem_ready)begin
          mem_valid_req=1; //issue new memory request
          mem_req_write=0;//change mem_write to zero
          mem_req_read=1;//mem_read to 1
          next_state = `allocate;
        end
      end
    endcase
  end

  //update data_write using mem_dout
  always @(posedge clk) begin
    if(current_state==`tag_compare && mem_output_valid) data_write <= mem_dout;
  end
  //state update 
  always @(posedge clk)begin
    if(reset) current_state <= `idle;
    else current_state <= next_state;
  end





  // Instantiate data memory
  DataMemory data_mem (
    .reset(reset),
    .clk(clk),

    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready), //output
     .is_input_valid(mem_valid_req),  //input
    // is output from the data memory valid?
    .is_output_valid(mem_output_valid),  //output
    .dout(mem_dout),  //output
    // send inputs to the data memory.
    .addr(mem_req_addr),        // send original address that comes from the cpu
    .mem_read(mem_req_read), 
    .mem_write(mem_req_write),
    .din(data_bank[idx])
  );

  endmodule
  //when access data 4block at once...!

  //mem_output_valid why not using?