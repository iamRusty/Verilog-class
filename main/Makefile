r:
	iverilog -o tb_rewardV2 tb_rewardV2.v
	vvp tb_rewardV2
	gtkwave tb_rewardV2.vcd

wp:
	iverilog -o tb_winnerPolicy tb_winnerPolicy.v
	vvp tb_winnerPolicy
	gtkwave tb_winnerPolicy.vcd

rng:
	iverilog -o tb_randomGenerator tb_randomGenerator.v
	vvp tb_randomGenerator
	gtkwave tb_randomGenerator.vcd

rnga:
	iverilog -o tb_rngAddress tb_rngAddress.v
	vvp tb_rngAddress
	gtkwave tb_rngAddress.vcd

lc:
	iverilog -o tb_learnCosts tb_learnCosts.v
	vvp tb_learnCosts
	gtkwave tb_learnCosts.vcd	

clean:
	rm -f a.out
	rm -f tb_reward
	rm -f tb_reward.vcd
	rm -f tb_randomGenerator.vcd
	rm -f tb_randomGenerator
	rm -f tb_rngAddress
	rm -f tb_rngAddress.vcd
	rm -f tb_winnerPolicy.vcd
	rm -f tb_winnerPolicy
	rm -f tb_learnCosts
	rm -f tb_learnCosts.vcd
