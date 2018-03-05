
module testbench2();
    reg clock, nreset;


    // CLOCK
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("testbench2.vcd");
        $dumpvars(0, testbench2);
        #600
        $finish; 
    end
endmodule