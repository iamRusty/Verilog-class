`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "memory.v"
`include "randomGenerator.v"
`include "winnerPolicyV2.v"
`include "rngAddress.v"

module testbench2();
    reg clock, nreset;
	reg [`WORD_WIDTH-1:0] address_buf;

    // Memory Module
    reg wr_en;
    reg [`WORD_WIDTH-1:0] mem_data_in;
    wire [`WORD_WIDTH-1:0] address, mem_data_out;
	mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

	// RNG MODULE
	wire [`WORD_WIDTH-1:0] rng_out, rng_out_4bit, address0;
	wire ako_boss;
	randomGenerator rng1(clock, nreset, mem_data_out, address0, rng_out, rng_out_4bit, ako_boss);

	// Modulo Module
	wire [`WORD_WIDTH-1:0] rng_address, betterNeighborCount, which;
	wire start_rngAddress, done_rngAddress;
	rngAddress rad1(clock, nreset, start_rngAddress, betterNeighborCount, which, rng_address, done_rngAddress);

	// WinnerPolicy Module
	reg start_winnerPolicy;
	reg [`WORD_WIDTH-1:0] _mybest, _besthop, _bestvalue, _better_qvalue, _bestneighborID, MY_NODE_ID, epsilon, epsilon_step;
	wire [`WORD_WIDTH-1:0] nexthop, address1;
	wire done_winnerPolicy;
	wire [4:0] cstate;
	wire [1:0] mux_select;
	winnerPolicyV2 wp1(clock, nreset, start_winnerPolicy, _mybest, _besthop, _bestvalue, _better_qvalue, _bestneighborID, MY_NODE_ID,
						address1, mem_data_out, epsilon, epsilon_step, nexthop, done_winnerPolicy, cstate, rng_out, rng_out_4bit, 
						rng_address, start_rngAddress, done_rngAddress, mux_select, betterNeighborCount, which
	);

	// Mux Address
	always @ (*) begin
		if (ako_boss)
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
            0: begin //testcase 2
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                _mybest = 20;
                _bestvalue = 5;
                _besthop = 32;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
                state <= 1;
            end
            1: begin // testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                _mybest = 5;
                _bestvalue = 20;
                _besthop = 50;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
            default: begin //testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon_step = 1;
                _mybest = 5;
                _bestvalue = 20;
                _besthop = 50;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
        endcase

        state = state + 1;
    end

	initial begin
        epsilon = 7;
        epsilon_step = 1;
        _mybest = 1;
        _besthop = 50;
        _better_qvalue = 3;
        _bestneighborID = 4;   
        MY_NODE_ID = 5;
        _bestvalue = 8;

		#25 start_winnerPolicy = 1;
	end

    // Clock
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