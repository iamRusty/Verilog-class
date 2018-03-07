`include "randomGenerator.v"
`include "memory.v"

module tb_randomGenerator();
    reg clock, nreset;
    wire [15:0] rng_out, rng_out_4bit, address, mem_data_in, mem_data_out;
    wire wr_en, internalmux_select; 

    randomGenerator rng1(clock, nreset, mem_data_out, address, rng_out, rng_out_4bit, internalmux_select);
    mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);    

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