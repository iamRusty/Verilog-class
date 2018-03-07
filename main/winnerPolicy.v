`timescale 1ns/1ps
`define MEM_DEPTH  2048
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module winnerPolicy(
	clock, 
	nrst, 
	start_winnerPolicy,
	mybest,
	besthop,
	bestvalue,
	bestneighborID,
	MY_NODE_ID,
	address,
	data_in,
	epsilon,
	epsilon_step,
	nexthop,
	done_winnerPolicy,
	rng_out,
	rng_out_4bit,
	rng_address,
	start_rngAddress,
	done_rng_address,
	betterNeighborCount,
	which
);

	input clock, nrst, start_winnerPolicy, done_rng_address;
	input [`WORD_WIDTH-1:0] mybest, besthop, bestvalue, bestneighborID, MY_NODE_ID, data_in, epsilon, epsilon_step, rng_out, rng_out_4bit, rng_address;
	output [`WORD_WIDTH-1:0] address, nexthop, betterNeighborCount, which;
	output done_winnerPolicy, start_rngAddress;
	// Registers
	reg [`WORD_WIDTH-1:0] explore_constant, which_buf, address_count, epsilon_buf, epsilon_temp, nexthop_buf; 
	reg [`WORD_WIDTH-1:0] betterNeighborCount_buf, rng_address_temp;
	reg done_winnerPolicy_buf, start_rngAddress_buf;
	reg one, two, three;
	reg [15:0] nineninenine, onezerozeroone;
	reg [31:0] _right3, _right2, _left, _right;
	reg [31:0] mybest_shifted;

	reg [4:0] state;
	always @ (posedge clock) begin
		if (!nrst) begin
			state <= 0;
			done_winnerPolicy_buf <= 0;
			nexthop_buf <= 100;     // 100 = -1 for the lack of representation on negative numbers
			epsilon_buf <= epsilon;
			start_rngAddress_buf <= 0;
			nineninenine <= 16'b1111111110111110;   	// 0.999 in binary fraction ~ 0.998992919921875 0.16
			onezerozeroone <= 16'b1000000000100000;    	// 0.001 in binary fraction ~ 0.001007080078125	1.15
		end
		else begin
			case (state)
				4'd0: begin
					if (start_winnerPolicy) begin
						state <= 1;
						explore_constant <= rng_out_4bit; // Generate explore_constant
					end
					else state <= 0;
				end
				4'd1: begin
					if (explore_constant < epsilon) begin
						state <= 2;
						address_count <= 16'h68C; // betterNeighborCount Address
					end
					else begin
						// nexthop is less than 0, or explore_constant is less than epsilon
						// Pick the best instead of exploring
						state <= 5;
					end
				end
				4'd2: begin
					which_buf <= rng_out_4bit;
					betterNeighborCount_buf <= data_in;
					
					// Compute for the address of betterNeighbor
					start_rngAddress_buf <= 1;
					state <= 3;
				end
				4'd3: begin
					if (done_rng_address) begin
						state <= 4;
						start_rngAddress_buf <= 0;
						rng_address_temp = rng_address;

						// address and index of betterNeighbor
						address_count <= 16'h668 + rng_address_temp*2;
					end
					else 
						state <= 3;
				end
				4'd4: begin
					nexthop_buf <= data_in;
					if (epsilon_buf < epsilon_step)
						epsilon_temp <= 0;
					else
						epsilon_temp <= epsilon_buf - epsilon_step;
					
					// Done winnerPolicy
					state <= 10;
				end
				4'd5: begin            
					/*
					 *  [15:0] bestvalue   - 11 bits whole, 5 bits fraction
					 *  [15:0] mybest      - 11 bits whole, 5 bits fraction
					 *  [15:0] nineninenine  - 16 bits fraction
					 *  _left, _right = 11 bits whole, 21 bits fraction
					 */
					_left = {bestvalue, 16'b0};
					_right = mybest * nineninenine;
					state <= 6;
				end
				4'd6: begin
					// Malayong mas malaki ang mybest kaysa bestvalue 
					if (_left < _right) begin
						one <= 0;
						nexthop_buf <= besthop;

						// Done winnerPolicy
						state <= 10;
					end
					else begin
						one <= 1;
						state <= 7;
					end
				end
				4'd7: begin
					/*
					 *  [15:0] bestvalue   - 11 bits whole, 5 bits fraction
					 *  [15:0] mybest      - 11 bits whole, 5 bits fraction
					 *  [15:0] onezerozeroone - 1 bit whole, 15 bits fraction
					 *  _left, _right2 = 12 bits whole, 20 bits fraction
					 */
					_right2 = mybest * onezerozeroone; // 12 bits whole, 20 bits fraction 
					mybest_shifted = {mybest, 15'b0};
					_right3 = _right2 + mybest_shifted;
					state <= 8;
				end
				4'd8: begin
					if (_left < _right3) 
						two <= 1;
					else
						two <= 0;

					if (bestneighborID == MY_NODE_ID)
						three <= 0;
					else
						three <= 1;

					state <= 9;
				end
				4'd9: begin
					if (one & two & three) begin
						nexthop_buf <= besthop;
					end
						state <= 10;
				end
				4'd10: begin
					done_winnerPolicy_buf <= 1;
				end
				default
					state <= 10;                 
			endcase
		end
	end

	assign nexthop = nexthop_buf;
	assign done_winnerPolicy = done_winnerPolicy_buf;
	assign address = address_count;
	assign start_rngAddress = start_rngAddress_buf;
	assign betterNeighborCount = betterNeighborCount_buf;
	assign which = which_buf;
endmodule