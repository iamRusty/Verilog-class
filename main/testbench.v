`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`include "memory.v"

module testbench();
	reg clock, reset, wr_en;
	wire [`WORD_WIDTH-1:0] mem_data_out; 
	reg [`WORD_WIDTH-1:0] mem_data_in;
	//wire [`WORD_WIDTH-1:0] address;
    reg [`WORD_WIDTH-1:0] address;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// Clock
	initial begin
		clock = 0;
		forever #10 clock = ~clock;
	end

	// Memory testbench

	initial begin
		wr_en = 0;
		#5
		mem_data_in = 1;
		address = 0; 
		wr_en = 1;
		#10 wr_en = 0;
	end

	// Wavefile
	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		#100 
		$finish;
	end
endmodule
