`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "learnCosts.v"
`include "memory.v"

module tb_learnCosts();
	reg clock, nreset;

	// Memory Module
	wire wr_en;
	wire [`WORD_WIDTH-1:0] address, data_in, data_out;
	mem mem1(clock, address, wr_en, data_in, data_out);

	// learnCosts Module
	reg start;	
	reg [`WORD_WIDTH-1:0] fsourceID, fbatteryStat, fValue, fclusterID;
	wire reinit, done;
	learnCosts lc1(clock, nreset, start, fsourceID, fbatteryStat, fValue, fclusterID, address, wr_en, data_in, data_out, reinit, done);
    
    // Initial Values
    initial begin
        fsourceID = 1;
        fbatteryStat = 5;
        fValue = 10;
        fclusterID = 11;
    end

	// Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
        nreset = 1;
        #5 nreset = 0;
        #10 nreset = 1;
    end

    initial begin
        $dumpfile("tb_learnCosts.vcd");
        $dumpvars(0, tb_learnCosts);
        #300
        $finish; 
    end
endmodule