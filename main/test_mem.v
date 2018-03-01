`include "memory.v"

module test_mem(clock, nreset, data_in, data_out);
    input clock, nreset;

    input [15:0] data_in;
    output [15:0] data_out;


endmodule

module tb_test_mem();
    reg clock, nreset;
    


    initial begin
        $dumpfile("tb_test_mem.vcd");
        $dumpvars(0, tb_test_mem);
        #300
        $finish; 
    end
endmodule