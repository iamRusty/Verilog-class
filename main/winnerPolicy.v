`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "floatRNG.v"
`include "floatSub.v"

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
    nexthop,
    epsilon_step
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
    input [15:0] epsilon_step;

    reg [15:0] explore_constant;    // float

    // floatRNG Module
    reg call_fRNG;
    wire [15:0] rng_data_out;
    floatRNG fRNG1(clock, nreset, call_fRNG, rng_data_out);

    // floatSub Module
    reg call_fSub;
    wire [15:0] fSub_data_out;
    wire sub_compare;
    reg [15:0] left, right;
    floatSub fSub1(clock, nreset, call_fSub, left, right, fSub_data_out, sub_compare);

    // (COMBINATIONAL) explore_constant generator 
    always @ (*) begin
        if (call_fRNG)
            explore_constant <= rng_data_out;
        else
            explore_constant <= 0;
    end    

    reg [15:0] which;
    // (COMBINATIONAL) which generator
    always @ (*) begin
        if (call_fRNG)
            which <= rng_data_out;
        else
            which <= 0;
    end    

    // (SEQUENTIAL) call_fRNG Generator
    always @ (posedge clock) begin
        if (!nreset) begin
            call_fRNG <= 0;
        end
        else begin
            case(state)
                1:  // explore_constant generator  
                    call_fRNG <= 1;  
                4:  // which generator
                    call_fRNG <= 1;  
                default: 
                    call_fRNG <= 0;
            endcase
        end
    end

    // explore_constant < epsilon ?
    // (COMBINATIONAL) Compare explore_constant and epsilon
    // Already taken care of by FSM

    // (SEQUENTIAL) call_fSub Generator
    always @ (posedge clock) begin
        if (!nreset)
            call_fSub <= 0;
        else begin
            case(state)
                2:  // Compare explore_constant and epsilon
                    call_fSub <= 1;
                default: 
                    call_fSub <=0;
            endcase
        end
    end

    // NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT
    // NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT
    // NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT
    // NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT
    // NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT NOT
    // nexthop = _better_qvalue[int(math.ceil(which * len(_better_qvalue) - 1))]
    // Must be Combinational
    reg [15:0] nexthop_buf;
    always @ (posedge clock) begin
        if (!nreset)
            nexthop_buf <= 0;
        else begin
            nexthop_buf <= 1;
        end
    end

    
    // (COMBINATIONAL) epsilon -= epsilon_step
    reg [15:0] epsilon_temp;
    always @ (*) begin
        if (state == 6)
            epsilon_temp = epsilon - epsilon_step;
        else
            epsilon_temp <= 0;
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
                2:  // Compare explore_constant and epsilon
                    if (tick < 6)
                        state <= 2;
                    else
                        state <= 3;
                3:  // Make decision for 1st if
                    if (sub_compare == 0)   // Get Out!
                        state <= 11;    // TBD TBD TBD TBD TBD
                    else
                        state <= 4;
                4:  // Which generator
                    if (tick < 12)
                        state <= 4;
                    else
                        state <= 5;
                5:  // nexthop = _better_qvalue[int(math.ceil(which * len(_better_qvalue) - 1))]
                    if (tick < 15)
                        state <= 5;
                    else
                        state <= 6;
                6:  // epsilon -= epislon_step
                    if (tick < 15)
                        state <= 6;
                    else
                        state <= 7;
                default:
                    state <= 0;
            endcase
        end
    end
endmodule