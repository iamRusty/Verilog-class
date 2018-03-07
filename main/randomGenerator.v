/*
 *  Linear Feedback Shift Register
 *  Reference: https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
 */

module randomGenerator(clock, nrst, mem_data_out, address, rng_out, rng_out_4bit, internalmux_select);
	input clock, nrst;
	input [15:0] mem_data_out;
	output [15:0] address, rng_out, rng_out_4bit;
	reg [15:0] rng_out_buf, address_count;
	reg feedback, internalmux_select_buf;
	output internalmux_select;

	// RNG
	reg [2:0] state;
	always @ (posedge clock) begin
		if (!nrst) begin
			rng_out_buf <= 5;
			state <= 1;
			address_count <= 16'h7FE;
			internalmux_select_buf <= 1;
		end
		else begin
			case (state)
				3'd1: begin
					// Read RNG_SEED in Memory
					rng_out_buf <= mem_data_out;
					state <= 2;
					internalmux_select_buf <= 0;
				end
				3'd2: begin
					rng_out_buf <= {rng_out_buf[14:0], feedback};
					state <= 2;
				end
				default: 
					state <= 2;
			endcase
		end
	end

	// Feedback
	always @ (*) begin
		feedback = ~(rng_out_buf[15] ^ rng_out_buf[14] ^ rng_out_buf[12] ^ rng_out_buf[3]);
	end

	assign rng_out = rng_out_buf;
	assign rng_out_4bit = {12'd0, rng_out_buf[3:0]};
	assign address = address_count;
	assign internalmux_select = internalmux_select_buf;
endmodule