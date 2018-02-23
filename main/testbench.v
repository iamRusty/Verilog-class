`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

`include "memory.v"
`include "amISink.v"

module testbench();
	reg clock, reset, wr_en;


    // MEMORY MODULE 
    wire [`WORD_WIDTH-1:0] mem_data_out; 
	reg [`WORD_WIDTH-1:0] mem_data_in;
    wire [`WORD_WIDTH-1:0] address;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);
    
    // amISink MODULE
    reg [`WORD_WIDTH-1:0] MY_NODE_ID;
    wire iamSink, done_iamSink;
    amISink ais1(clock, reset, address, mem_data_out, MY_NODE_ID, iamSink, done_iamSink);

	// Clock
	initial begin
		clock = 0;
		forever #10 clock = ~clock;
	end

    // MY_NODE_ID
    // IBAHIN MO ITO FOR TEST CASE
    initial begin
        //MY_NODE_ID = 17;
         MY_NODE_ID = 17;
        // MY_NODE_ID = 1;
    end

	// Memory testbench

/*
	initial begin
		wr_en = 0;
		#5
		mem_data_in = 1;
		address = 0; 
		wr_en = 1;
		#10 wr_en = 0;
	end
*/

	// Wavefile
	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#350
		$finish;
	end
endmodule
