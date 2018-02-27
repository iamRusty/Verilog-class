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
    epsilon_step,
    epsilon_out
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
    output [15:0] epsilon_out;

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

    reg [15:0] which;
    // (COMBINATIONAL) explore_constant and which generator 
    always @ (*) begin
        if (call_fRNG) begin
            explore_constant = rng_data_out;
            which = rng_data_out;
        end
        else begin
            explore_constant <= 0;
            which <= 0;
        end
    end      

    // (COMBINATIONAL) call_fRNG Generator
    always @ (*) begin
        case (state)
            1: call_fRNG <= 1;
            5: call_fRNG <= 1;
            default:    call_fRNG <= 0;
        endcase
    end

    // explore_constant < epsilon ?
    // (COMBINATIONAL) Compare explore_constant and epsilon
    // Already taken care of by FSM

    // state12_reg
    reg [15:0] state12_reg;
    always @ (*) begin
        if (state == 13)
            state12_reg = fSub_data_out;
        else
            state12_reg = 0;
    end

    // state15_reg_sub
    reg [15:0] state15_reg_sub;
    reg [15:0] state15_reg_add;
    always @ (*) begin
        if (state == 15) begin
            state15_reg_sub = 1; // Output of floatSub
            state15_reg_add = 1; // Output of floatAdd
        end
        else begin
            state15_reg_sub = 1; // Arbitrary
            state15_reg_add = 1; // Arbitrary
        end
    end

    // Simplifying the long if
    reg one, two, three;
    always @ (*) begin
        case (state)
            16: begin
                if (_bestneighborID != MY_NODE_ID)
                    three = 1;
                else
                    three = 0;

                if (sub_compare)
                    one = 0;
                else
                    one = 1;
            end
            17: 
                if (sub_compare)
                    two = 1;
                else
                    two = 0;
            default: begin
                one = 0;
                two = 0;
                three = 0;
            end
        endcase
    end

    reg inside;
    always @ (*) begin
        if (one & two & three)
            inside = 1;
        else
            inside = 0;
    end

    // (COMBINATIONAL) call_fSub Generator and Arguments
    always @ (*) begin
        case (state)
            2:  begin
                left = explore_constant;
                right = epsilon_buf;
                call_fSub = 1;
            end
            7:  begin
                left = epsilon_buf;
                right = epsilon_step;
                call_fSub = 1;
            end
            10: begin
                left = nexthop_buf;
                right = 0;
                call_fSub = 1;
            end
            12: begin
                left = _mybest;
                right = _mybest * 1; // floatMult(_mybest * 0.001)
                call_fSub = 1;
            end
            13: begin
                left = _bestvalue;
                right = state12_reg;
                call_fSub = 1;
            end
            15: begin
                left = _mybest;
                right = _mybest * 1; // floatMult(_myest * 0.001)
                call_fSub = 1;
                // call_fAdd;
            end
            16: begin
                left = _bestvalue;
                right = state15_reg_sub;
                call_fSub = 1;
            end
            17: begin
            end
            default: call_fSub <= 0;
        endcase
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


    // SEEMS WRONG
    // (COMBINATIONAL) epsilon -= epsilon_step
    reg [15:0] epsilon_temp, epsilon_buf;
/*
    always @ (*) begin
        if (state == 7)
            epsilon_temp = epsilon_buf - epsilon_step;  // Replace with floatSub
        else
            epsilon_temp <= 0;
    end
*/


    reg [7:0] tick;
    // Tick Counter
    always @ (posedge clock) begin
        if (!nreset)
            tick <= 0;
        else
            if (state == 0)
                tick <= 0;
            else
                tick <= tick + 1;
    end

    // Tick More
    always @ (posedge done_prev)
        tick <= 0;
 
    reg [4:0] state;
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
                3:  // Wait for floatSub
                    if (tick < 9) begin
                        state <= 3;
                        call_fSub <= 0;
                    end
                    else
                        state <= 4;
                4:  // Make decision for 1st if
                    if (sub_compare == 0)   // Get Out!
                        state <= 11;    // if (nexthop < 0)
                    else
                        state <= 5;
                5:  // Which generator
                    if (tick < 15)
                        state <= 5;
                    else
                        state <= 6;
                6:  // nexthop = _better_qvalue[int(math.ceil(which * len(_better_qvalue) - 1))]
                    if (tick < 18)
                        state <= 6;
                    else
                        state <= 7;
                7:  // epsilon -= epislon_step
                    if (tick < 21)
                        state <= 7;
                    else
                        state <= 8;
                8:  // wait for floatSub
                    if (tick < 24) begin
                        state <= 8;
                        call_fSub <= 0;
                    end
                    else
                        state <= 9;
                9:  // if (epsilon < 0)
                    if (sub_compare == 1) begin
                        //state <= 10;    // epsilon = float(0)
                        epsilon_temp <= 0;   // separate this later
                    end
                    else
                        state <= 11;    // if (nexthop < 0)
                10: // wait for floatSub
                    if (tick < 27)  
                        state <= 10;
                    else
                        state <= 11;
                11: // if (nexthop < 0)
                    if (sub_compare == 1) begin
                        state <= 12;
                        call_fSub <= 0;
                    end
                    else
                        state <= 19;
                12: // _mybest - _mybest * 0.001
                    if (tick < 33) 
                        state <= 12;
                    else
                        state <= 13;
                13: // wait for fSub
                    if (tick < 36) begin
                        state <= 13;
                        call_fSub <= 0;
                    end
                    else
                        state <= 14;
                14: // if (_bestvalue < (_mybest - _mybest * 0.001))
                    if (sub_compare == 1) begin
                        nexthop_buf = _besthop;
                        state <= 19; 
                    end
                    else
                        state <= 15;
                15: // _mybest - _mybest * 0.001 and _mybest + _mybest * 0.001
                    if (tick < 42)
                        state <= 15;
                    else
                        state <= 16;
                16: // (_bestvalue > ( (_mybest - _mybest * 0.001) and (_bestneighborID != MY_NODE_ID)
                    if (tick < 45)
                        state <= 16;
                    else
                        state <= 17;
                17: // (_bestvalue < (_mybest + _mybest * 0.001))
                    if (tick < 48)
                        state <= 17;
                    else
                        state <= 18; // done
                18: // Pinakahuling if
                    if (inside) begin
                        nexthop_buf = _besthop;
                        state <= 19;
                    end
                    else 
                        state <= 19; 
                default:
                    state <= 19;    // done
            endcase
        end
    end

    assign done = (state == 19) ? 1:0;
endmodule