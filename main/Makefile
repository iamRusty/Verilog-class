reward:
	iverilog -o tb_reward tb_reward.v
	vvp tb_reward
	gtkwave tb_reward.vcd

r2:
	iverilog -o tb_rewardV2 tb_rewardV2.v
	vvp tb_rewardV2
	gtkwave tb_rewardV2.vcd

amisink:
	iverilog -o testbench testbench.v
	vvp testbench
	gtkwave testbench.vcd

wp:
	iverilog -o tb_winnerPolicy tb_winnerPolicy.v
	vvp tb_winnerPolicy
	gtkwave tb_winnerPolicy.vcd

rng:
	iverilog -o tb_randomGenerator tb_randomGenerator.v
	vvp tb_randomGenerator
	gtkwave tb_randomGenerator.vcd

wp2:
	iverilog -o tb_winnerPolicyV2 tb_winnerPolicyV2.v
	vvp tb_winnerPolicyV2
	gtkwave tb_winnerPolicyV2.vcd

rnga:
	iverilog -o tb_rngAddress tb_rngAddress.v
	vvp tb_rngAddress
	gtkwave tb_rngAddress.vcd

clean:
	rm -f a.out
	rm -f testbench
	rm -f testbench.vcd
	rm -f tb_reward
	rm -f tb_reward.vcd
	rm -f tb_winnerPolicy.vcd
	rm -f tb_winnerPolicy
	rm -f tb_rewardV2.vcd
	rm -f tb_rewardV2
	rm -f tb_winnerPolicyV2.vcd
	rm -f tb_winnerPolicyV2
	rm -f tb_randomGenerator.vcd
	rm -f tb_randomGenerator
	rm -f tb_rngAddress
	rm -f tb_rngAddress.vcd