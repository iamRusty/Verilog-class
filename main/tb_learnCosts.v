`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "learnCosts.v"
`include "memory.v"

module tb_learnCosts();
	reg clock, nrst;

	// Memory Module
	wire wr_en;
	wire [`WORD_WIDTH-1:0] address, mem_data_in, mem_data_out;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// learnCosts Module
	reg start;	
	reg [`WORD_WIDTH-1:0] fsourceID, fbatteryStat, fValue, fclusterID;
	wire reinit, done;
	learnCosts lc1(clock, nrst, start, fsourceID, fbatteryStat, fValue, fclusterID, address, wr_en, mem_data_out, mem_data_in, reinit, done);
    
    // Initial Values
    initial begin
        // Add new neighbor 
        /*fsourceID = 1;
        fbatteryStat = 5;
        fValue = 10;
        fclusterID = 11;*/

        // if neighbor is found
        fsourceID = 31;
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
        start = 0;
        nrst = 1;
        #5 nrst = 0;
        #10 
        nrst = 1;
        #5
        start = 1;
    end

    initial begin
        $dumpfile("tb_learnCosts.vcd");
        $dumpvars(0, tb_learnCosts);
        #500
        $finish; 
    end
endmodule