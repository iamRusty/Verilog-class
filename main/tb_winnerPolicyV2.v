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
`include "winnerPolicyV2.v"

module tb_winnerPolicyV2();
    reg clock, nreset;

    // MEMORY MODULE
    wire [`WORD_WIDTH-1:0] address, mem_data_in;
    wire [`WORD_WIDTH-1:0] mem_data_out;
    reg wr_en;
    mem m2 (clock, address, wr_en, mem_data_in, mem_data_out);

    // WINNERPOLICY MODULE
    reg start_winnerPolicy;
    reg [`WORD_WIDTH-1:0] _mybest, _besthop, _bestvalue, _better_qvalue, _bestneighborID, MY_NODE_ID, epsilon, epsilon_step;
    wire [`WORD_WIDTH-1:0] winnerPolicy_nexthop;
    wire done_winnerPolicy;
    wire [7:0] cstate;
    winnerPolicyV2 wp2 (clock, nreset, start_winnerPolicy, _mybest, _besthop, _bestvalue, _better_qvalue, _bestneighborID, MY_NODE_ID, address, mem_data_out, epsilon, epsilon_step, winnerPolicy_nexthop, done_winnerPolicy, cstate);


    reg [3:0] state;
    always @ (posedge done_winnerPolicy) begin
        
        case (state)
            0: begin //testcase 2
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                _mybest = 20;
                _bestvalue = 5;
                _besthop = 32;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
                state <= 1;
            end
            1: begin // testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon = 2;
                epsilon_step = 1;
                _mybest = 5;
                _bestvalue = 20;
                _besthop = 50;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
            default: begin //testcase 3
                #10 nreset = 0;
                #20 nreset = 1;
                epsilon_step = 1;
                _mybest = 5;
                _bestvalue = 20;
                _besthop = 50;
                _better_qvalue = 3;
                _bestneighborID = 4;   
                MY_NODE_ID = 5;
            end
        endcase

        state = state + 1;
    end

    // REWARD MODULE INITIAL
    initial begin
        state <= 0;
        // testcase 1 - until 1st if lang po
        
        epsilon = 7;
        epsilon_step = 1;
        _mybest = 1;
        _besthop = 50;
        _better_qvalue = 3;
        _bestneighborID = 4;   
        MY_NODE_ID = 5;
        _bestvalue = 8;
        

        // testcase 2 - hindipasok sa 1st if pero pasok sa 2nd if
        /*epsilon = 2;
        epsilon_step = 1;
        _mybest = 20;
        _bestvalue = 5;
        _besthop = 32;
        _better_qvalue = 3;
        _bestneighborID = 4;   
        MY_NODE_ID = 5;
        */

        // testcase 3 - hindipasok sa 1st and 2nd if pero pasok sa 3rd if
        /*epsilon = 2;
        epsilon_step = 1;
        _mybest = 5;
        _bestvalue = 20;
        _besthop = 50;
        _better_qvalue = 3;
        _bestneighborID = 4;   
        MY_NODE_ID = 5;
        */
        #25 start_winnerPolicy = 1;
    end

    // Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Reset
    initial begin
        nreset = 1;
        #5 nreset = 0;
        #10 nreset = 1;
    end

    initial begin
        $dumpfile("tb_winnerPolicyV2.vcd");
        $dumpvars(0, tb_winnerPolicyV2);
        #600
        $finish; 
    end

endmodule