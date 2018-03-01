`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

`include "floatSubV2.v"
`include "randomGenerator.v"
`include "rngAddress.v"

module winnerPolicyV2(
    clock, 
    nreset, 
    start_winnerPolicy,
    _mybest,
    _besthop,
    _bestvalue,
    _better_qvalue,
    _bestneighborID,
    MY_NODE_ID,
    address,
    data_in,
    epsilon,
    epsilon_step,
    nexthop,
    done_winnerPolicy,
    cstate
);

    input clock, nreset, start_winnerPolicy;
    input [`WORD_WIDTH-1:0] _mybest, _besthop, _bestvalue, _better_qvalue, _bestneighborID, MY_NODE_ID, data_in, epsilon, epsilon_step;
    output [`WORD_WIDTH-1:0] address, nexthop;
    output done_winnerPolicy;
    output [7:0] cstate;

    // Registers
    reg [`WORD_WIDTH-1:0] explore_constant, which, address_count, epsilon_buf, epsilon_temp, _mybest_frac, nexthop_buf; 
    reg generate_random, done_winnerPolicy_buf;
    reg [`WORD_WIDTH-1:0] left, right;
    reg [`WORD_WIDTH-1:0] betterNeighborCount;
    reg [`WORD_WIDTH-1:0] mikko_mult_left, mikko_mult_right, mikko_sub_left, mikko_sub_right, mikko_mult_out, mikko_sub_out, mikko_add_left, mikko_add_right, mikko_add_out;
    reg mikko_sub_compare;
    reg [`WORD_WIDTH-1:0] one_right, two_right;
    reg one, two, three;
    reg done_buf;
    
    // floatSub MODULE
    wire [`WORD_WIDTH-1:0] floatSub_data_out;
    wire sub_compare;
    floatSubV2 fsub2(clock, nreset, left, right, floatSub_data_out, sub_compare);

    // randomGenerator MODULE
    wire [15:0] rng_out;
    wire [15:0] rng_out_4bit;
    randomGenerator rng1(clock, nreset, rng_out, rng_out_4bit);

    // rngAddress
    wire [`WORD_WIDTH-1:0] rng_address;
    reg start_rngAddress;
    rngAddress rng_ad1(clock, nreset, start_rngAddress, betterNeighborCount, which, rng_address, done_rng_address);

    /*
     * State Machine
     * 0 - Idle/Wait for start_winnerPolicy
     * 1 - Generate a random number (explore_constant)
     * 2 - Subtract explore_constant < epsilon
     * 3 - Evaluate 2
     * 4 - Generate a random number (which)
     * 5 - address = which * len( better_qvalue ) - 1
        epsilon = epsilon - epsilon_step
     * 
     */

    reg [7:0] state;
    always @ (posedge clock) begin
        if (!nreset) begin
            state <= 0;
            done_winnerPolicy_buf <= 0;
            nexthop_buf <= 100;     // 100 = -1 for the lack of representation on negative numbers
            epsilon_buf <= epsilon;
            done_buf = 0;
        end
        else begin
            case (state)
                4'd0: begin
                    if (start_winnerPolicy) begin
                        state <= 1;
                        explore_constant = rng_out_4bit;
                    end
                    else
                        state <= 0;
                end
                4'd1: begin
                    state <= 2;                     // floatSub( explore_constant, epsilon )
                    left = explore_constant;        // left = explore_constant;
                    right = 5;                      // right = epsilon;
                end
                4'd2: begin
                    if (sub_compare) begin
                        which = rng_out_4bit;

                        state <= 3;                 // fetch betterNeighborCount  // nexthop = _better_qvalue[int(math.ceil(which * len(_better_qvalue) - 1))]
                        address_count <= 16'h68C;   // address of betterNeighborCount
                        
                        left = epsilon_buf;         // floatSub( left, right )
                        right = epsilon_step;       // epsilon = epsilon - epsilon_step
                    end
                    else begin
                        state <= 20;                // bestvalue < (_mybest - _mybest * 0.001)
                    end
                end
                4'd3: begin
                    betterNeighborCount = data_in;
                    
                    // address = int(math.ceil(which * len(_better_qvalue) - 1))
                    state <= 4;
                    start_rngAddress = 1;

                    if (sub_compare)
                        epsilon_temp = floatSub_data_out;
                    else
                        epsilon_temp = 0;
                end
                4'd4: begin
                    if (done_rng_address)
                        state <= 5;
                    else
                        state <= 4;
                end
                4'd5: begin
                    start_rngAddress <= 0;
                    address_count = 16'h68C + rng_address;                    
                    state <= 6;                 // multiply _mybest and 0.001
                    mikko_mult_left = _mybest;
                    mikko_mult_right = 1;       // mikko_mult_out_right = 0.001 
                end
                4'd6: begin
                    nexthop_buf = data_in;
                    _mybest_frac = mikko_mult_out;
                    state <= 7;
                    mikko_sub_left = _mybest;
                    mikko_sub_right = _mybest_frac;
                end
                4'd7: begin
                    one_right = mikko_sub_out;
                    state <= 8;
                    mikko_sub_left = _besthop;
                    mikko_sub_right = one_right;
                end
                4'd8: begin
                    if (mikko_sub_compare) begin
                        state <= 11;        // Done
                        nexthop_buf = _besthop;
                        one = 0;
                    end
                    else begin
                        one = 1;
                        state <= 9;
                        mikko_add_left = _mybest;
                        mikko_add_right = _mybest_frac;
                        if (_bestneighborID != MY_NODE_ID) begin
                            three = 1;
                        end
                        else begin
                            three = 0;
                        end
                    end
                end
                4'd9: begin
                    two_right = mikko_add_out;
                    mikko_sub_left = _bestvalue;
                    mikko_sub_right = two_right;
                    state <= 10;
                end
                4'd10: begin
                    two = mikko_sub_compare;
                    if (one & two & three)
                        nexthop_buf = _besthop;
                    else
                        nexthop_buf = 100;

                    state <= 11;
                end
                4'd11: begin
                    done_buf = 1;
                end
                default:
                    state <= 10;
            endcase
        end
    end

    assign nexthop = nexthop_buf;
    assign done_winnerPolicy = done_winnerPolicy_buf;
    assign cstate = state;
endmodule