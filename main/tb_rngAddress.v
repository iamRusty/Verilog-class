`include "rngAddress.v"
`include "randomGenerator.v"

module tb_rngAddress();
	reg clock, nreset, start_rng_address;
	reg [15:0] betterNeighborCount, which;
	wire [15:0] rng_adress_out, rng_out, rng_out_4bit;
	wire done_rng_address;

	rngAddress rngAddress1(clock, nreset, start_rng_address, betterNeighborCount, rng_out_4bit, rng_adress_out, done_rng_address);
	randomGenerator rng1(clock, nreset, rng_out, rng_out_4bit);

	// Initial Values
	initial begin
		betterNeighborCount = 4;
		which = 15;
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
		#15;
		nreset = 1;
		#100;
		nreset = 0;
		#20;
		nreset = 1;
	end

	initial begin
        $dumpfile("tb_rngAddress.vcd");
        $dumpvars(0, tb_rngAddress);
        #500
        $finish;
	end
endmodule