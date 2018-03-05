`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/*
 * Multiplexer
 * 0: learnCost
 * 1: amISink
 * 2: fixSinkList
 * 3: neighborSinkInOtherCluster
 * 4: findMyBest
 * 5: betterNeighborsInMyCluster
 * 6: winnerPolicy
 * 7: selectMyAction
 */

module mux(select, out, in0, in1, in2, in3);
	input[1:0] select;
	input[`WORD_WIDTH-1:0] in0, in1, in2, in3;
	output[`WORD_WIDTH-1:0] out;

	reg [`WORD_WIDTH-1:0] out_buf;

	always @(*) begin
	   case(select)
	       0 : out_buf = in0;
	       1 : out_buf = in1;
	       2 : out_buf = in2;
	       3 : out_buf = in3;
	   endcase
	end
	assign out = out_buf;
endmodule