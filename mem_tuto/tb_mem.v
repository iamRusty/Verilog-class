`timescale 1ns/1ps
`define CLK_PD 10
`define DEL_IN 3
module tb_mem;
  reg clk,wr_en;
  reg [31:0] addr,data_in;
  wire [31:0] data_out;

  mem UUT(
    .clk(clk),
    .wr_en(wr_en),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out)
  );

  always
    #(`CLK_PD/2.0) clk = ~clk;

  integer i;
  initial begin
    $vcdplusfile("tb_mem.vpd");
    $vcdpluson;

    /* Initialization */
    clk = 0;
    wr_en = 0;
    addr = 0;
    data_in = 0;

    #(`CLK_PD/2.0);
    #(`DEL_IN);

    /* Display initial contents of memory */
    for (i=0;i<4;i=i+1) begin
      $display("%X%X%X%X",
        UUT.memory[(i*4)],
        UUT.memory[(i*4)+1],
        UUT.memory[(i*4)+2],
        UUT.memory[(i*4)+3]
        );
    end

    /* Start */
    addr = 0;
    #(`CLK_PD);
    addr = 32'd4;
    #(`CLK_PD);
    addr = 32'd8;
    #(`CLK_PD);
    addr = 32'd12;
    #(`CLK_PD);
    $finish;
  end
endmodule
