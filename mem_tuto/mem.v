`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 32
module mem(
  clk,
  addr,
  wr_en,
  data_in,
  data_out
  );
  input clk,wr_en;
  input [`WORD_WIDTH-1:0] addr,data_in;
  output [`WORD_WIDTH-1:0] data_out;

  reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

  initial begin
    $readmemh("./mem.txt",memory);
  end

  //Read port
  reg [`WORD_WIDTH-1:0] data_out;

  always@(*)
    data_out <= {memory[addr],
                memory[addr+1],
                memory[addr+2],
                memory[addr+3]};

  //Write port
  always@(posedge clk)
    if (wr_en) begin
      memory[addr] <= data_in[31:24];
      memory[addr+1] <= data_in[23:16];
      memory[addr+2] <= data_in[15:8];
      memory[addr+3] <= data_in[7:0];
    end
endmodule
