a:
	iverilog -o costEvaluation costEvaluation.v
	vvp costEvaluation
	gtkwave costEvaluation.vcd
clean:
	rm -f *.vcd *.vpd
	rm -f a.out
	rm -f costEvaluation

