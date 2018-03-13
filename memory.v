`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/*  Address List
 *  
 *  (2/4)       [0x0 - 0x07]        amISink/forAggregation FLAGS
 *  (2/16)      [0x8 - 0x27]        knownSinks  
 *  (2/16)      [0x28 - 0x47]       worstHops
 *  (2/64)      [0x48 - 0xC7]       neighborID
 *  (2/64)      [0xC8 - 0x147]      clusterID
 *  (2/64)      [0x148 - 0x1C7]     batteryStat
 *  (2/64)      [0x1C8 - 0x247]     qValue
 *  (2/8*64)    [0x248 - 0x647]     sinkIDs
 *
 *  (2/16)      [0x648 - 0x667]     Hop Count Multiplier (Constants)
 *  (2/16)      [0x668 - 0x687]     betterNeighbors
 *
 *  (2/1)       [0x688 - 0x689]     knownSinkCount
 *  (2/1)       [0x68A - 0x68B]     neighborCount
 *  (2/1)       [0x68C - 0x68D]     betterNeighborCount      
 *  (2/64)      [0x68E - 0x70D]     sinkIDCount
 *  
 *  (2/1)       [0x798 - 0x799]     RNG_Seed
 *  243 bytes out
 */

module mem(clock, address, wr_en, data_in, data_out);
	input clock, wr_en;
	input [`WORD_WIDTH-1:0] data_in;
    input [10:0] address;
	output [`WORD_WIDTH-1:0] data_out;

	//INITIALIZE MEMORY ARRAY
	reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

    initial begin
        $readmemh("mem_wp1.txt", memory);
    end

    // INITIAL CONTENTS FOR TESTING PURPOSES ONLY
    integer i;
    initial begin
    // WinnerPolicy testcase
/*        // epsilon
        memory['h4] = 0;    // testcase 1
        memory['h5] = 7;
*/
/*
        memory['h4] = 0;    // testcase 2 and 3
        memory['h5] = 7;

        // betterNeighbor
        memory['h668] = 0;
        memory['h668 + 1] = 35;

        memory['h668 + 2] = 0;
        memory['h668 + 3] = 51;

        memory['h668 + 4] = 0;
        memory['h668 + 5] = 77;

        // betterNeighborCount
        memory['h68C] = 0;
        memory['h68C + 1] = 3;
*/ 

    // LearnCosts test case
/*
        // neighborCount
        memory['h68A] = 0;
        memory['h68A + 1] = 2;

        // knownSinkCount
        memory['h688] = 0;
        memory['h688 + 1] = 2;

        // knownSink
        memory['h8] = 0;
        memory['h8 + 1] = 5;

        memory['h8 + 2] = 0;
        memory['h8 + 3] = 13;

        // neighborID
        memory['h48] = 0;
        memory['h48 + 1] = 30;

        memory['h48 + 2] = 0;
        memory['h48 + 3] = 31;

        // batteryStat
        memory['h148] = 0;
        memory['h148 + 1] = 1;

        memory['h148 + 2] = 0;
        memory['h148 + 3] = 1;

        // qValue
        memory['h1C8] = 0;
        memory['h1C8 + 1] = 5;

        memory['h1C8 + 2] = 0;
        memory['h1C8 + 3] = 7; 

        // Cluster ID
        memory['hC8] = 0;
        memory['hC8 + 1] = 2;

        memory['hC8 + 2] = 0;
        memory['hC8 + 3] = 3;

        // sinkIDcount
        memory['h68E] = 0;
        memory['h68E + 1] = 2;

        memory['h68E + 2] = 0;
        memory['h68E + 3] = 2;

        // sinkIDs
        // nei_1
        memory['h248] = 0;
        memory['h248 + 1] = 5;

        memory['h248 + 2] = 0;
        memory['h248 + 3] = 10;        

        // nei_2
        memory['h248 + 16] = 0;
        memory['h248 + 16 + 1] = 13;

        memory['h248 + 16 + 2] = 0;
        memory['h248 + 16 + 3] = 22;
*/
    end

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