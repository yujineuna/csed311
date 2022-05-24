`include "CLOG2.v"
`define INVALID 2'b00
`define TAG_compare 2'b01 // Tag compare
`define WRITEBACK 2'b10
`define ALLOC 2'b11

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16,/* Your choice */
               parameter NUM_WAYS = 1/* Your choice */) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);

  // Wire declarations
  wire is_data_mem_ready;
  wire [3:0]idx;
  wire [23:0]tag;
  wire [1:0]block_offset;
  wire mem_output_valid;
  
  
  // Reg declarations
  // Save cache value temporary
  reg[0:LINE_SIZE*8-1] read_data;
  reg[0:LINE_SIZE*8-1] write_data;
  // Cache element
  reg[0:LINE_SIZE*8-1] data_bank[0:NUM_SETS-1]; //Cache block
  reg[23:0] tag_bank[0:NUM_SETS-1]; //Cache tag table
  reg valid_bank[0:NUM_SETS-1]; //Valid bit for each block
  reg dirty_bank[0:NUM_SETS-1]; //Dirty bit for Write-back
  // Cache State
  reg[1:0] current_state;
  reg[1:0] next_state;
  // element of DataMemory port
  reg[LINE_SIZE*8-1:0] mem_dout;
  reg[31:0] mem_addr;
  reg mem_input_valid;
  reg _mem_read;
  reg _mem_write;

  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;
  assign tag = addr[31:8];
  assign idx = addr[7:4];
  assign block_offset = addr[3:2];

  integer i;

  // Set initial cache value
  always @(posedge clk) begin
    if(reset) begin
      for(i = 0; i < NUM_SETS; i = i + 1) begin
        tag_bank[i] = 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
        data_bank[i] = 128'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
        valid_bank[i] = 0;
        dirty_bank[i] = 0;
      end
    end
  end

  always @(*) begin
    read_data = data_bank[idx];
    write_data = read_data;
    // Write din
    case(block_offset)
      0: write_data[0:31] = din;
      1: write_data[32:63] = din;
      2: write_data[64:95] = din;
      3: write_data[96:127] = din;
    endcase

    // Read cache data
    case(block_offset)
      0: dout = read_data[0:31];
      1: dout = read_data[32:63];
      2: dout = read_data[64:95];
      3: dout = read_data[96:127];
    endcase

    case(current_state)
      `INVALID: begin
        if(is_input_valid) next_state = `TAG_compare;
      end
      `TAG_compare: begin
        //Cache hit
        if(tag==tag_bank[idx] && valid_bank[idx]) begin
          is_hit = 1;
          is_output_valid = 1; //export cache read
          _mem_write = 0;
          _mem_read = 0;
          //hit_write for clean cache
          if(mem_write && dirty_bank[idx]==0) begin
            data_bank[idx] = write_data;
            dirty_bank[idx] = 1;
            next_state = `INVALID;
          end
          //hit_write for dirty cache
          if(mem_write && valid_bank[idx]) begin
            next_state = `WRITEBACK;
          end
        end
        // Cache miss
        else begin
          // Cold miss or Conflict miss on clear cache
          if(valid_bank[idx]==0 || dirty_bank[idx]==0) begin
            next_state = `ALLOC;
          end
          // Conflict miss on the dirty cache
          else begin
            next_state = `WRITEBACK;
          end
        end
      end
      `ALLOC: begin
        //read data memory
        mem_addr = {addr[31:4],4'b0000};
        if(is_ready) mem_input_valid = 1;
        _mem_read = 1;
        _mem_write = 0;
        if(mem_output_valid) begin
          next_state = `TAG_compare;
          write_data = mem_dout;
          tag_bank[idx] = tag;
          valid_bank[idx] = 1;
          dirty_bank[idx] = 0;
          mem_input_valid = 0;
        end
      end
      `WRITEBACK: begin
        mem_addr = {tag_bank[idx],idx,4'b0000};
        _mem_read = 0;
        _mem_write = 1;
        if(is_ready) begin
          mem_input_valid = 1;
          next_state = `ALLOC;
        end
      end
    endcase

  end


  // Update Cache state
  always @(posedge clk) begin
    if(reset) current_state <= `INVALID;
    else current_state <= next_state;
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(mem_input_valid),
    .addr(mem_addr),
    .mem_read(_mem_read),
    .mem_write(_mem_write),
    .din(din),
    // is output from the data memory valid?
    .is_output_valid(mem_output_valid),
    .dout(mem_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );


endmodule
