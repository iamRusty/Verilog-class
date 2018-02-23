`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "memory.v"
`include "reward.v"

module tb_reward();
    reg clock, reset;

    // MEMORY MODULE
    wire [`WORD_WIDTH-1:0] mem_data_out; 
    reg [`WORD_WIDTH-1:0] mem_data_in;
    wire [`WORD_WIDTH-1:0] address;
    mem mem1(clock, address, wr_en, mem_data_in, mem_data_out);

    // REWARD MODULE
    reg [`WORD_WIDTH-1:0] _action, _besthop;
    wire [80 - 1:0] reward_data_out;
    reg [`WORD_WIDTH-1:0] MY_NODE_ID, MY_CLUSTER_ID;
    reg done_prev;  //wire done_prev;
    wire done_reward;
    reward r1(
        clock, 
        reset, 
        _action, 
        _besthop, 
        address, 
        mem_data_out, 
        reward_data_out, 
        MY_NODE_ID, 
        MY_CLUSTER_ID, 
        done_prev,      // to be renamed
        done_reward
    );

    // CLOCK
    initial begin
        clock = 0;
        forever #(`CLOCK_PD/2) clock = ~clock;
    end

    // RESET    
    initial begin
        reset = 1; 
        #1;
        reset = 0;
    end

    // REWARD ARGUMENTS
    initial begin
        done_prev <= 0;
        MY_NODE_ID <= 2;
        MY_CLUSTER_ID <=3;
        _action <= 5;
        _besthop <= 6;
        
        #10 done_prev = 1;
    end

    // DUMP and MAIN SETTINGS
    initial begin
        $dumpfile("tb_reward.vcd");
        $dumpvars(0, tb_reward);
        #400;
        done_prev = 0;
        #20;
        $finish; 
    end

endmodule