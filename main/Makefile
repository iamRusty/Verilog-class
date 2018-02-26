reward:
	iverilog -o tb_reward tb_reward.v
	vvp tb_reward
	gtkwave tb_reward.vcd

amisink:
	iverilog -o testbench testbench.v
	vvp testbench
	gtkwave testbench.vcd

fsm:
	iverilog -o tb_try_fsm tb_try_fsm.v
	vvp tb_try_fsm
	gtkwave tb_try_fsm

clean:
	rm -f a.out
	rm -f testbench
	rm -f testbench.vcd
	rm -f tb_reward
	rm -f tb_reward.vcd