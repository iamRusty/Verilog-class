`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/* Possible Actions
 * random hop (explore hop)
 * besthop
 * nextsink
 * self (CH role)
 */

module selectMyAction(clock, nrst, start, address, wr_en, nexthop, nextsinks, rng_in, action, data_out, forAggregation, done);
	input clock, nrst, start;
	input [`WORD_WIDTH-1:0] nexthop, nextsinks, rng_in;
	output forAggregation, done, wr_en;
	output [`WORD_WIDTH-1:0] action, address, data_out;

	// Registers
	reg forAggregation_buf, done_buf, wr_en_buf;
	reg [`WORD_WIDTH-1:0] action_buf, address_count, data_out_buf;
	reg [2:0] state;

	always @ (posedge clock) begin
		if (!nrst) begin
			done_buf <= 0;
			wr_en_buf <= 0;
			forAggregation_buf <= 0;
			action_buf <= nexthop;
			state <= 0;
		end
		else begin
			case (state)
				0: begin
					if (start)
						state = 1;
					else 
						state = 0;
				end

				1: begin
					if (nextsinks != 65) begin	// nosink = 65 // change 65 to 300+
						action_buf = nextsinks;
						state = 4;
						$display("Send pkt to neighbor sink in my cluster!");
					end
					else 
						state = 2;

					if (action_buf == 65) begin
						forAggregation_buf = 1;
						state = 2;
						data_out_buf = 16'h1;
						address_count = 16'h2; // forAggregation (FLAG) address
						wr_en_buf = 1;
						$display("No better in-cluster head. Schedule aggregation!");
					end
					else 
						forAggregation_buf = 0;

					state = 3;
				end

				2: begin
					wr_en_buf = 0;
					state = 3;
					data_out_buf = rng_in;
					address_count = 16'h7FE;	// rngSeed address
					wr_en_buf = 1;
				end

				3: begin
					wr_en_buf = 0;
					state = 4;
				end

				4: begin
					done_buf = 1;
				end

				default: state = 4;
			endcase
		end
	end

	assign done = done_buf;
	assign address = address_count;
	assign wr_en = wr_en_buf;
	assign data_out = data_out_buf;
	assign forAggregation = forAggregation_buf;
	assign action = action_buf;
endmodule