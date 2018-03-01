`include "rngAddress.v"

module tb_rngAddress();
	reg clock, nreset, start_rng_address;
	reg [15:0] betterNeighborCount, which;
	wire [15:0] rng_adress_out;
	wire done_rng_address;

	rngAddress rngAddress1(clock, nreset, start_rng_address, betterNeighborCount, which, rng_adress_out, done_rng_address);

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
		#15
		nreset = 1;
	end

	initial begin
        $dumpfile("tb_rngAddress.vcd");
        $dumpvars(0, tb_rngAddress);
        #500
        $finish;
	end
endmodule