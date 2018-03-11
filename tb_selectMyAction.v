`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "selectMyAction.v"
`include "memory.v"

module tb_selectMyAction();
	reg clock, nrst;

	// Memory Module
	wire wr_en;
	wire [`WORD_WIDTH-1:0] address, mem_data_in, mem_data_out;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// selectMyAction Module
	reg start;
	wire forAggregation, done;
	wire [15:0] action;
	reg [15:0] nexthop, nextsinks, rng_in;
	selectMyAction sma1(clock, nrst, start, address, wr_en, nexthop, nextsinks, rng_in, action, mem_data_in, forAggregation, done);
    
    // Initial Values
    initial begin
		nexthop = 65;
		nextsinks = 65;
		rng_in = 5;
    end

	// Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
		nrst = 1;
		start = 0;
		#5 nrst = 0;
		#20 nrst = 1;
		#1 start = 1;
    end

    initial begin
        $dumpfile("tb_selectMyAction.vcd");
        $dumpvars(0, tb_selectMyAction);
        #500
        $finish; 
    end
endmodule