`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "winnerPolicy.v"

module tb_winnerPolicy();
    reg clock, nreset;


    // winnerPolicy Module
    reg [15:0] epsilon;           // float
    reg [15:0] _mybest;           // float
    reg [15:0] _besthop;          // neighborID
    reg [15:0] _bestvalue;        // float
    reg [15:0] _bestneighborID;   // neighborID
    reg [15:0] MY_NODE_ID;
    reg done_prev;
    wire done;
    wire [15:0] nexthop;
    reg [15:0] epsilon_step;
    wire [15:0] epsilon_out;
    winnerPolicy wp1(
        clock, 
        nreset,
        epsilon,
        _mybest,
        _besthop,       
        _bestvalue,
        _bestneighborID,
        MY_NODE_ID,
        done_prev, 
        done,
        nexthop,
        epsilon_step,
        epsilon_out
    );

    // CLOCK
    initial begin
        clock = 0;
        forever #(`CLOCK_PD/2) clock = ~clock;
    end

    initial begin
        nreset = 0;
        done_prev = 0;
        #11
        nreset = 1;
        #20 
        done_prev = 1;
    end

    // Initial Values
    initial begin
        epsilon = 1;
        _mybest = 2;
        _besthop = 3;
        _bestvalue = 4;
        _bestneighborID = 5;
        MY_NODE_ID = 6;
    end

    // DUMP and MAIN SETTINGS
    initial begin
        $dumpfile("tb_winnerPolicy.vcd");
        $dumpvars(0, tb_winnerPolicy);
        #800
        $finish; 
    end
endmodule