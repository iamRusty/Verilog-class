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
    floatRNG fRNG1(clock, nreset, call, rng_data_out);

    // (COMBINATIONAL) explore_constant generator 
    always @ (*) begin
        if (call)
            explore_constant <= rng_data_out_buf;
        else
            explore_constant <= 0;
    end    

    reg [15:0] which;
    // (COMBINATIONAL) which generator
    always @ (*) begin
        if (call)
            which <= rng_data_out_buf;
        else
            which <= 0;
    end    

    // (SEQUENTIAL) Call Generator
    always @ (posedge clock) begin
        if (!nreset) begin
            call <= 0;
        end
        else begin
            case(state)
                1:  // explore_constant generator  
                    call <= 1;  
                3:  // which generator
                    call <= 1;  
                default: 
                    call <= 0;
            endcase
        end
    end

    reg [7:0] tick;
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
    reg [3:0] state;
    always @ (posedge clock) begin
        if (!nreset)
            state <=0;
        else begin
            case(state)
                0:  // Idle
                    if (done_prev)
                        state <= 1;
                    else
                        state <= 0;
                1:  // Generate explore_constant
                    if (tick < 3)
                        state <= 1;
                    else
                        state <= 2;
                default:
                    state <= 0;
            endcase
        end
    end
endmodule