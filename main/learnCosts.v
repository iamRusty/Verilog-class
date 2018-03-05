`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module learnCosts(clock, nreset, start, fsourceID, fbatteryStat, fValue, fclusterID, address, wr_en, data_in, data_out, reinit, done);
	input clock, nreset, start;
	input [`WORD_WIDTH-1:0] fsourceID, fbatteryStat, fValue, fclusterID, data_in;
	output done, reinit;
	output [`WORD_WIDTH-1: 0] address, data_out, wr_en;

	// Registers
	reg [`WORD_WIDTH-1:0] address_count, data_out_buf, neighborCount, knownSinkCount, cur_nID, cur_knownSink, cur_qValue, sinkID_address_buf;
	reg done_buf, found, reinit_buf, wr_en_buf;
	reg [`WORD_WIDTH-1:0] n, k;
	reg [4:0] state;

	always @ (posedge clock) begin
		if (!nreset) begin
			done_buf <= 0;
			address_count <= 16'h68A; // neighborCount address
			state <= 0;
			found <= 0;
			reinit_buf <= 0;
			n <= 0;
			k <= 0;
		end
		else begin
			case (state)
				0: begin
					state <= 1;
					address_count <= 16'h68A; // neighborCount address
				end
				1: begin
					neighborCount <= data_in;
					state <= 2;
					address_count <= 16'h688; // knownSinkCount address
				end
				2: begin
					knownSinkCount <= data_in;
					state <= 3;
				end
				3: begin
					// if not found, add a new neighbor
					if (n == neighborCount)
						state <= 11;
					else begin
						address_count <= 16'h48 + n*2; // neighborID address 
						state <= 4;
					end
				end
				4: begin
					cur_nID <= data_in;	// current neighborID

					// if found, update the routingTable values
					if (cur_nID == fsourceID) begin
						found <= 1;
						state <= 5;

						// para hindi multiply nang multiply sa state
						sinkID_address_buf <= 16'h248 + 16*n;
					end
					else
						n = n + 1;
				end
				5: begin
					if (k == knownSinkCount) begin
						data_out_buf <= fbatteryStat;
						address_count <= 16'h148 + n*2; // batteryStat address
						wr_en_buf <= 1;
						state <= 8;
					end
					else begin
						address_count <= 16'h8 + k*2; // knownSinks address
						state <= 6;
					end
				end
				6: begin
					cur_knownSink = data_in; // current knownSink
					data_out_buf = cur_knownSink;
					address_count <= sinkID_address_buf + k*2;	// sinkIDs address
					wr_en_buf = 1;
					state <= 7;
				end
				7: begin
					wr_en_buf <= 0;
					k = k + 1;
					state <= 5;
				end
				8: begin
					wr_en_buf <= 0;
					address_count = 16'h1C8 + n*2; // qValue address
					state <= 9;
				end
				9: begin
					cur_qValue <= data_in;
					data_out_buf <= cur_qValue;
					wr_en_buf <= 1;

					if (cur_qValue < fValue) begin
						reinit_buf <= 1;
						state <= 10;
						done_buf <= 1;
					end
					else
						reinit_buf <= 0;
				end
				10: begin
					done_buf <= 1;
					state <= 10;
				end
				11: begin
					address_count <= 16'h48 + neighborCount*2; // neighborID address
					data_out_buf <= fsourceID;
					wr_en_buf <= 1;
					state <= 12;
				end
				12: begin
					//wr_en_buf <= 0;
					address_count <= 16'h148 + neighborCount*2; // batteryStat address
					data_out_buf <= fbatteryStat;
					wr_en_buf <= 1;
					state <= 13;	
				end
				13: begin
					address_count <= 16'h1C8 + neighborCount*2; // qValue address
					data_out_buf <= fValue;
					wr_en_buf <= 1;
					state <= 14;
				end
				14: begin
					address_count <= 16'hC8 + neighborCount*2;
					data_out_buf <= fclusterID;
					wr_en_buf <= 1;
					k <= 0;

					// Para hindi multiply nang multiply sa state 16
					sinkID_address_buf <= 16'h248 + 16*neighborCount;
					
					state <= 15; 
				end
				15: begin
					if (k == knownSinkCount) begin
						state <= 10;
						done_buf <= 1;
						//reinit <= 0;
					end
					else begin
						address_count <= 16'h8 + k*2; // knownSinks address
						state <= 16;
					end
				end
				16: begin
					cur_knownSink <= data_in;
					data_out_buf <= cur_knownSink;
					address_count <= sinkID_address_buf + 2*k;
					wr_en_buf <= 1;
				end
				17: begin
					wr_en_buf <= 0;
					k = k + 1;
					state <= 15;
				end
				default: 
					state <= 10;
			endcase
		end
	end

	assign done = done_buf;
	assign address = address_count;
	assign data_out = data_out_buf;
	assign reinit = reinit_buf;
endmodule