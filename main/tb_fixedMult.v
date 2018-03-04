`include "fixedMult.V"

module tb_fixedMult();

	reg clock, nreset;
	reg [15:0] left, right;
	wire [31:0] out;

	// fixedMult Module
	fixedMult fm1(clock, nreset, left, right, out);

	initial begin
		#20
		left = 2;
		right = 6;
	end

	initial begin
        $dumpfile("tb_fixedMult.vcd");
        $dumpvars(0, tb_fixedMult);
        #500
        $finish;
	end
endmodule