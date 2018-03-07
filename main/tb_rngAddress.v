`include "rngAddress.v"
`include "randomGenerator.v"

module tb_rngAddress();
	reg clock, nreset, start_rng_address;
	reg [15:0] betterNeighborCount, which, rng_out_4bit;
	wire [15:0] rng_address_out, rng_out;
	wire done_rng_address;

	rngAddress rngAddress1(clock, nreset, start_rng_address, betterNeighborCount, rng_out_4bit, rng_address_out, done_rng_address);

	// Initial Values
	initial begin
		betterNeighborCount = 5;
		rng_out_4bit = 5;
		start_rng_address = 1;
		#200;
	end

	// Clock
	initial begin
		clock = 0;
		forever #10 clock = ~clock;
	end

	// Reset
	initial begin
		nreset = 0;
		#25
		nreset = 1;
	end

	initial begin
        $dumpfile("tb_rngAddress.vcd");
        $dumpvars(0, tb_rngAddress);
        #500
        $finish;
	end
endmodule