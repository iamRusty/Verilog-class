`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module learnCosts(clock, nreset, start_learnCosts, fsourceID, fbatteryStat, fValue, fclusterID, address, done_learnCosts);
	input clock, nreset, start_learnCosts;
	input [`WORD_WIDTH-1:0] fsourceID, fbatteryStat, fValue, fclusterID;
	output done_learnCosts;

	// Registers
	reg [`WORD_WIDTH-1:0] address_count;
	reg done_learnCosts_buf;

	always @ (posedge clock) begin
		if (!nreset) begin
			address_count
		end
	end



	assign done_learnCosts = done_learnCosts_buf;
endmodule