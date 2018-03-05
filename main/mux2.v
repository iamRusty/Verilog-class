`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/*
 * Address Multiplexer (8:1)
 * 0: RNG AKO BOSS
 * 1: WINNERPOLICY AKO BOSS
 */

module mux(select, out, in0, in1);
	input select;
	input[`WORD_WIDTH-1:0] in0, in1;
	output[`WORD_WIDTH-1:0] out;

	reg [`WORD_WIDTH-1:0] out_buf;

	always @(*) begin
		case(select)
			0 : out_buf = in0;
			1 : out_buf = in1;
			2 : out_buf = in2;
			3 : out_buf = in3;
			4 : out_buf = in4;
			5 : out_buf = in5;
			6 : out_buf = in6;
			7 : out_buf = in7;
		endcase
	end
	assign out = out_buf;
endmodule