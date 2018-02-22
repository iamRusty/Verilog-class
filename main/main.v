`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

module mem(clock, address, wr_en, data_in, data_out);
	input clock, wr_en;
	input [`WORD_WIDTH-1:0] address, data_in;
	output [`WORD_WIDTH-1:0] data_out;

	//INITIALIZE MEMORY ARRAY
	reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

/*
	//STORE INITIAL CONTENTS
	initial begin
		$readmemh("./mem.txt", memory);
	end
*/

	//READ PORT
	reg [`WORD_WIDTH-1:0] data_out_buf;

	always@(*)
		data_out_buf <= {memory[address], memory[address+1]};

	assign data_out = data_out_buf;

	//WRITE PORT
	always@(posedge clock) begin
		if (wr_en) begin
			memory[address] <= data_in[15:8];
			memory[address+1] <= data_in[7:0];
		end
	end
endmodule


module amISink(clock, reset, address, data_in, MYNODEID, iamSink, done)
	output address;
	input data_in;
	address = 0
	data_in = ?

module testbenc1h();
	reg clock, reset, wr_en;
	wire [`WORD_WIDTH-1:0] mem_data_out; 
	reg [`WORD_WIDTH-1:0] mem_data_in;
	// reg [`WORD_WIDTH-1:0] address;
	wire [`WORD_WIDTH-1:0] address;

	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);
	amISink aIS1(clock, reset, address, mem_data_out, MYNODEID, iamSink, done)
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
