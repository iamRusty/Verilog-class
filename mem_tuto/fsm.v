`timescale 1ns/1ps
`define ITER 200 
module fsm(clk,nrst,wr_en,addr,data_in,data_out,done);
  input clk,nrst;
  output wr_en;
  output [31:0] addr,data_out;
  input [31:0] data_in; 
  output done;

  reg [1:0] state;
  reg [9:0] ticks;
  always@(posedge clk or negedge nrst)
    if (!nrst)
      state <= 0;
    else
      case(state)
        2'd0: state <= 2'd1;
        2'd1: 
          if (ticks < `ITER)
            state <= 2'd0;
          else
            state <= 2'd2;
        default: state <= 2'd2;
      endcase

  always@(posedge clk or negedge nrst)
    if (!nrst)
      ticks <= 0;
    else
      ticks <= ticks + 1;

  reg [31:0] addr;
  always@(posedge clk or negedge nrst)
    if (!nrst)
      addr <= 0;
    else
      if (state == 2'd1)
        if (addr != 32'd12)
          addr <= addr + 4;
        else
          addr <= 0;

  reg [31:0] data_out;
  always@(posedge clk or negedge nrst)
    if (!nrst)
      data_out <= 0;
    else
      if (state == 0)
        data_out <= {data_in[30:0],data_in[31]};

  reg wr_en;
  always@(*)
    /*if (!nrst)
      wr_en <= 0;
    else*/
      if (state == 2'd1)
        wr_en <= 1'b1;
      else
        wr_en <= 0;
 
  assign done = (state == 2'd2)? 1'b1:0;
endmodule
