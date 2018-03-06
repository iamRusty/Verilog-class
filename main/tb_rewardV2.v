`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

/*  Address List
 *  
 *  (1/8)       [0x0 - 0x07]        amISink/forAggregation FLAGS
 *  (2/16)      [0x8 - 0x27]        knownSinks  
 *  (2/16)      [0x28 - 0x47]       worstHops
 *  (2/64)      [0x48 - 0xC7]       neighborID
 *  (2/64)      [0xC8 - 0x147]      clusterID
 *  (2/64)      [0x148 - 0x1C7]     batteryStat
 *  (2/64)      [0x1C8 - 0x247]     qValue
 *  (2/8*64)    [0x248 - 0x647]     sinkIDs
 *  (2/16)      [0x648 - 0x657]     Hop Count Multiplier (Constants)
 *  (2/16)      [0x658 - 0x668]     betterNeighbors
 *
 *  (2/8)       [0x700 - 0x709]     nextsinks
 *  (2/8)       [0x710 - 0x719]     better_qvalue
 *
 */

`include "memory.v"
`include "rewardV2.v"

module tb_rewardV2();
    reg clock, nreset;

    // MEMORY MODULE
    wire [`WORD_WIDTH-1:0] address, mem_data_in;
    wire [`WORD_WIDTH-1:0] mem_data_out;
    reg wr_en;
    mem m2 (clock, address, wr_en, mem_data_in, mem_data_out);

    // REWARD MODULE
    reg start_reward, en;
    reg [`WORD_WIDTH-1:0] MY_NODE_ID, MY_CLUSTER_ID, _action, _besthop;
    wire [`WORD_WIDTH-1:0] reward_data_out;
    wire done_reward;
    reward r2 (clock, nreset, en, start_reward, MY_NODE_ID, MY_CLUSTER_ID, _action, _besthop, address, mem_data_out, reward_data_out, done_reward);

    // REWARD MODULE INITIAL
    initial begin
        MY_NODE_ID = 1;
        MY_CLUSTER_ID = 5;
        _action = 3;
        _besthop = 4; 

        #25 start_reward = 1;
    end

    // Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
        nreset = 1;
        en = 0;
        #10
        nreset = 0;
        #10 
        nreset = 1;
        #55
        en = 1;
        #20
        en = 0;
        #180 
        en = 1;
        #180
        en = 0;
    end

    initial begin
        $dumpfile("tb_rewardV2.vcd");
        $dumpvars(0, tb_rewardV2);
        #400
        $finish; 
    end

endmodule