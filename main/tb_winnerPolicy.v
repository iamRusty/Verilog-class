`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "memory.v"
`include "randomGenerator.v"
`include "winnerPolicy.v"
`include "rngAddress.v"

module tb_winnerPolicy();
    reg clock, nreset;
	reg [`WORD_WIDTH-1:0] address_buf;

    // Memory Module
    reg wr_en;
    reg [`WORD_WIDTH-1:0] mem_data_in;
    wire [`WORD_WIDTH-1:0] address, mem_data_out;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// RNG MODULE
	wire [`WORD_WIDTH-1:0] rng_out, rng_out_4bit, address0;
	wire internalmux_select;
	randomGenerator rng1(clock, nreset, mem_data_out, address0, rng_out, rng_out_4bit, internalmux_select);

	// Modulo Module
	wire [`WORD_WIDTH-1:0] rng_address, betterNeighborCount, which;
	wire start_rngAddress, done_rngAddress;
	rngAddress rad1(clock, nreset, start_rngAddress, betterNeighborCount, which, rng_address, done_rngAddress);

	// WinnerPolicy Module
	reg start_winnerPolicy;
	reg [`WORD_WIDTH-1:0] mybest, besthop, bestvalue, bestneighborID, MY_NODE_ID, epsilon, epsilon_step;
	wire [`WORD_WIDTH-1:0] nexthop, address1;
	wire done_winnerPolicy;
	winnerPolicy wp1(clock, nreset, start_winnerPolicy, mybest, besthop, bestvalue, bestneighborID, MY_NODE_ID,
						address1, mem_data_out, epsilon, epsilon_step, nexthop, done_winnerPolicy, rng_out, rng_out_4bit, 
						rng_address, start_rngAddress, done_rngAddress, betterNeighborCount, which
	);

	// Mux Address
	always @ (*) begin
		if (internalmux_select)
			address_buf = address0;
		else
			address_buf = address1;
	end

	assign address = address_buf;

    // Reset
    initial begin
        nreset = 1;
        #5 nreset = 0;
        #10 nreset = 1;
    end

    reg [3:0] state;
    always @ (posedge done_winnerPolicy) begin
        case (state)
            1: begin //testcase 2
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                mybest = 20;
                bestvalue = 5;
                besthop = 32;
                bestneighborID = 4;   
                MY_NODE_ID = 5;
                state = 2;
            end
            2: begin // testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                mybest = 5;
                bestvalue = 20;
                besthop = 50;
                bestneighborID = 4;   
                MY_NODE_ID = 5;
                state = 3;
            end
            default: begin //testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon_step = 1;
                mybest = 5;
                bestvalue = 20;
                besthop = 50;
                bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
        endcase
    end

	initial begin
        epsilon = 7;
        epsilon_step = 1;
        mybest = 1;
        besthop = 50;
        bestneighborID = 4;   
        MY_NODE_ID = 5;
        bestvalue = 8;
        state = 1;
		#25 start_winnerPolicy = 1;
	end

    // Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("tb_winnerPolicy.vcd");
        $dumpvars(0, tb_winnerPolicy);
        #600
        $finish; 
    end
endmodule