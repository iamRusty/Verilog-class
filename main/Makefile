a:
	iverilog -o testbench testbench.v
	vvp testbench
	gtkwave testbench.vcd
clean:
	rm -f a.out
	rm -f testbench
	rm -f testbench.vcd