reward:
	iverilog -o tb_reward tb_reward.v
	vvp tb_reward
	gtkwave tb_reward.vcd

amisink:
	iverilog -o testbench testbench.v
	vvp testbench
	gtkwave testbench.vcd

clean:
	rm -f a.out
	rm -f testbench
	rm -f testbench.vcd
	rm -f tb_reward
	rm -f tb_reward.vcd