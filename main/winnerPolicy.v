`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "floatRNG.v"

module winnerPolicy(
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
    nexthop
    );

    input clock, nreset;
    input [15:0] epsilon;           // float
    input [15:0] _mybest;           // float
    input [15:0] _besthop;          // neighborID
    input [15:0] _bestvalue;        // float
    input [15:0] _bestneighborID;   // neighborID
    input [15:0] MY_NODE_ID;

    input done_prev;
    output done;
    output [15:0] nexthop;

    reg [15:0] explore_constant;    // float

    // floatRNG Module
    reg [15:0] rng_data_out_buf;
    reg call;
    wire [15:0] rng_data_out;
    floatRNG (clock, nreset, call, rng_data_out);

    // explore_constant generator
    always @ (posedge clock) begin
        if (!nreset)
            explore_constant <= 0;
        else
            explore_constant <= rng_data_out_buf;
    end    

    reg [15:0] which;
    // which generator
    always @ (posedge clock) begin
        if (!nreset)
            which <= 0;
        else
            which <= rng_data_out_buf;
    end

    // Tick Counter
    always @ (posedge clock) begin
        if (!nreset)
            tick <= 0;
        else
            if (state == 0)
                tick <= 0;
            else
                tick = tick + 1;
    end

    // Tick More
    always @ (posedge done_prev)
        tick <= 0;

    /*
     *  State Machine
     *      0: IDLE - Wait for done_prev
     *      1: Generate explore_constant
     */  

endmodule