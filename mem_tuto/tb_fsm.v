`timescale 1ns/1ps
`define CLK_PD 10
`define DEL_IN 3
module tb_mem;
  reg clk, nrst;
  wire [31:0] addr;
  wire [31:0] data_in;
  wire [31:0] data_out;
  wire wr_en, done;

  mem IG(
    .clk(clk),
    .wr_en(wr_en),
    .addr(addr),
    .data_in(data_out),
    .data_out(data_in)
  );
  fsm UUT(
    .clk(clk),
    .nrst(nrst),
    .wr_en(wr_en),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .done(done)
  );

  always
    #(`CLK_PD/2.0) clk = ~clk;

  integer i;
  initial begin
    //$vcdplusfile("tb_mem.vpd");
    //$vcdpluson;
    $dumpfile("tb_fsm.vcd");
    $dumpvars(0, tb_mem);

    /* Initialization */
    clk = 0;
    nrst = 0;

    #(`CLK_PD/2.0);
    #(`DEL_IN);

    /* Display initial contents of memory */
    for (i=0;i<4;i=i+1) begin
      $display("%X%X%X%X",
        IG.memory[(i*4)],
        IG.memory[(i*4)+1],
        IG.memory[(i*4)+2],
        IG.memory[(i*4)+3]
        );
    end

    /* Start */
    #(`CLK_PD);
    nrst = 1;

    #(`CLK_PD*203.0);
    nrst = 0;

    #(`CLK_PD);

    /* Display final contents of memory */
    for (i=0;i<4;i=i+1) begin
      $display("%X%X%X%X",
        IG.memory[(i*4)],
        IG.memory[(i*4)+1],
        IG.memory[(i*4)+2],
        IG.memory[(i*4)+3]
        );
    end

    #(`CLK_PD);
    $finish;
  end
endmodule
