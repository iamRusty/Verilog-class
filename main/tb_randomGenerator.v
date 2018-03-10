`include "randomGenerator.v"
`include "memory.v"

module tb_randomGenerator();
    reg clock, nrst, en_rng;
    wire [15:0] rng_out, rng_out_4bit;
    wire done;

    randomGenerator rng1(clock, nrst, rng_out, rng_out_4bit, en_rng, done);

    // Clock 
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
        #15;
        nrst = 0;
        #20 nrst = 1;
        #20 en_rng = 1;
        #20 en_rng = 0;
        #100 en_rng = 1;
        #20 en_rng = 0;
    end

    initial begin
        $dumpfile("tb_randomGenerator.vcd");
        $dumpvars(0, tb_randomGenerator);
        #500
        $finish;
    end
endmodule