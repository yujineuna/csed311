module RegisterFile(input reset,
                    input clk,
                    input [4:0] rs1,          // source register 1
                    input [4:0] rs2,          // source register 2
                    input [4:0] rd,           // destination register
                    input [31:0] rd_din,      // input data for rd
                    //input wr_en, 
                    input reg_write,         // RegWrite signal
                    output [31:0] rs1_dout,   // output of rs 1
                    output [31:0] rs2_dout,
                    output [31:0]rf17
                    );  // output of rs 2
  integer i;
  // Register file
reg [31:0] rf[0:31];


assign rf17=rf[17];
assign rs1_dout=rf[rs1];
assign rs2_dout=rf[rs2];


always @(posedge clk) begin 
    if(reg_write&&0<=rd&&rd<=31&&rd!=0)begin
    rf[rd]<=rd_din;
  end
end


  
  // TODO
  // Asynchronously = blocking  read register file
  // Synchronously <= non_blocking write data to the register file

  // Initialize register file (do not touch)
  always @(posedge clk) begin
    // Reset register file
    if (reset) begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] = 32'b0;
      rf[2] = 32'h2ffc; // stack pointer
    end
  end
  
endmodule
