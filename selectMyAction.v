`define WORD_WIDTH 16

/* Possible Actions
 * random hop (explore hop)
 * besthop
 * nextsink
 * self (CH role)
 */

module selectMyAction(clock, nrst, en, start, address, wr_en, nexthop, nextsinks, action, data_out, forAggregation, done);
	input clock, nrst, en, start;
	input [`WORD_WIDTH-1:0] nexthop, nextsinks;
	output forAggregation, done, wr_en;
	output [`WORD_WIDTH-1:0] action, address, data_out;

	// Registers
	reg forAggregation_buf, done_buf, wr_en_buf;
	reg [`WORD_WIDTH-1:0] action_buf, address_count, data_out_buf;
	reg [2:0] state;

	always @ (posedge clock) begin
		if (!nrst) begin
			done_buf = 0;
			wr_en_buf = 0;
			forAggregation_buf = 0;
			state = 5;
		end
		else begin
			case (state)
				0: begin
					if (start) begin
						action_buf = nexthop;
						state = 1;
					end
					else state = 0;
				end

				1: begin
					if (nextsinks != 16'd65) begin
						action_buf = nextsinks;
						//$display("Send pkt to neighbor sink in my cluster!");
					end
					state = 2;
				end

				2: begin
					if (action_buf == 300) begin
						forAggregation_buf = 1;
						data_out_buf = 16'h1;
						address_count = 16'h2; // forAggregation (FLAG) address
						wr_en_buf = 1;
						//$display("No better in-cluster head. Schedule aggregation!");
					end
					else forAggregation_buf = 0;

					state = 3;
				end

				3: begin
					wr_en_buf = 0;
					state = 4;
				end

				4: begin
					done_buf = 1;
					state = 5;
				end

				5: begin
					if (en) begin
						done_buf = 0;
						wr_en_buf = 0;
						forAggregation_buf = 0;
						state = 0;
					end
					else state = 5;
				end

				default: state = 5;
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