`include "randomGenerator.v"

module tb_randomGenerator();
    reg clock, nreset;
    wire [15:0] rng_out;
    wire [15:0]  rng_out_4bit;

    randomGenerator rng1(clock, nreset, rng_out, rng_out_4bit);

    // Clock 
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
        nreset = 0;
        #25 nreset = 1;
    end

    initial begin
        $dumpfile("tb_randomGenerator.vcd");
        $dumpvars(0, tb_randomGenerator);
        #500
        $finish;
    end
endmodule