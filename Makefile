a:
	iverilog -o costEvaluation costEvaluation.v
	vvp costEvaluation
	gtkwave costEvaluation.vcd
mem:
	rm -f mem
	iverilog -o mem mem.v
	vvp mem
	gtkwave mem.vcd
clean:
	rm -f *.vcd *.vpd
	rm -f a.out
	rm -f costEvaluation

