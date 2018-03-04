
module fixedMult(clock, nreset, left, right, out);
	input clock, nreset;
	input [15:0] left, right;

	output [31:0] out;
	reg [31:0] out_buf;

	always @ (*) begin
		out_buf = left * right;
	end

	assign out = out_buf;
endmodule