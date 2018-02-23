`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/*  Address List
 *  
 *  (1/8)       [0x0 - 0x07]        amISink/forAggregation FLAGS
 *  (2/16)      [0x8 - 0x27]        knownSinks  
 *  (2/16)      [0x28 - 0x47]       worstHops
 *  (2/64)      [0x48 - 0xC7]       neighborID
 *  (2/64)      [0xC8 - 0x147]      clusterID
 *  (2/64)      [0x148 - 0x1C7]     batteryStat
 *  (2/64)      [0x1C8 - 0x247]     qValue
 *  (2/8*64)    [0x248 - 0x658]     sinkIDs
 *  (2/8)       [0x700 - 0x709]     nextsinks
 *  (2/8)       [0x710 - 0x719]     better_qvalue
 */

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
    // INITIAL CONTENTS FOR TESTING PURPOSES ONLY
    integer i;
    initial begin
        // knownSinks
        for (i = 0; i < 15; i=i+1) begin
            memory[8 + i*2+1] = 15 - i;   // totoong value
            memory[8 + i*2] = 0;          // padding para hindi XX
        end
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