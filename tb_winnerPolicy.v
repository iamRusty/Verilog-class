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
    reg clock, nrst;

    // Memory Module
    wire wr_en;
    wire [`WORD_WIDTH-1:0] mem_data_in;
    wire [`WORD_WIDTH-1:0] mem_data_out;
    wire [10:0] address;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// RNG MODULE
    wire en_rng, done_rng;
	wire [`WORD_WIDTH-1:0] rng_out, rng_out_4bit;
	randomGenerator rng1(clock, nrst, rng_out, rng_out_4bit, en_rng, done_rng);

	// Modulo Module
	wire [`WORD_WIDTH-1:0] rng_address, betterNeighborCount, which;
	wire start_rngAddress, done_rngAddress;
	rngAddress rad1(clock, nrst, start_rngAddress, betterNeighborCount, which, rng_address, done_rngAddress);

	// WinnerPolicy Module
	reg en, start_winnerPolicy;
	reg [`WORD_WIDTH-1:0] mybest, besthop, bestvalue, bestneighborID, MY_NODE_ID, epsilon, epsilon_step;
	wire [`WORD_WIDTH-1:0] nexthop;
	wire done_winnerPolicy;
	winnerPolicy wp1(clock, nrst, en, start_winnerPolicy, mybest, besthop, bestvalue, bestneighborID, MY_NODE_ID,
						address, mem_data_out, wr_en, mem_data_in, epsilon_step, nexthop, done_winnerPolicy, en_rng, rng_out, rng_out_4bit, 
						rng_address, start_rngAddress, done_rngAddress, betterNeighborCount, which
	);

    // Reset
    initial begin
        nrst = 1;
        #5 nrst = 0;
        #10 nrst = 1;
        #20 en = 1;
        #20 en = 0;
    end

    reg [3:0] state;
/*
    always @ (posedge done_winnerPolicy) begin
        case (state)
            1: begin //testcase 2
                #10 nrst = 0;
                #20 nrst = 1;
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
                #10 nrst = 0;
                #20 nrst = 1;
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
                #10 nrst = 0;
                #20 nrst = 1;
                epsilon_step = 1;
                mybest = 5;
                bestvalue = 20;
                besthop = 50;
                bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
        endcase
    end
*/
	initial begin

        epsilon = 7;
        epsilon_step = 1;
        mybest = 1;
        besthop = 50;
        bestneighborID = 4;   
        MY_NODE_ID = 5;
        bestvalue = 8;
        state = 1;
		#100 start_winnerPolicy = 1;

/*
        epsilon = 2;
        epsilon_step = 1;
        mybest = 20;
        bestvalue = 5;
        besthop = 32;
        bestneighborID = 4;   
        MY_NODE_ID = 5;
        state = 2;
        #100 start_winnerPolicy = 1;
        */
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