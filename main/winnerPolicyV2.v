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
    reg [8:0] nineninenine;
    reg [24:0] _left, _right;
    reg [5:0] onezerozeroone;
    reg [31:0] _left2, _right2;
    reg [31:0] _mybest_shifted;

    
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
    reg [15:0] rng_address_temp;
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
            start_rngAddress = 0;
            nineninenine <= 9'b111111111;   // 0.999 in bnary fraction
            onezerozeroone <= 6'b100001;    // 0.001 in binary fraction
        end
        else begin
            case (state)
                4'd0: begin
                    if (start_winnerPolicy) begin
                        // Generate explore_constant
                        state <= 1;
                        explore_constant <= rng_out_4bit;
                    end
                    else
                        state <= 0;
                end
                4'd1: begin
                    if (explore_constant < epsilon) begin
                        state <= 2;

                        // betterNeighborCount Address
                        address_count <= 16'h68C; 
                    end
                    else begin
                        // nexthop is less than 0, or explore_constant is less than epsilon
                        // Pick the best instead of exploring
                        state <= 5;
                    end
                end
                4'd2: begin
                    which <= rng_out_4bit;
                    betterNeighborCount <= data_in;
                    
                    // Compute for the address of betterNeighor
                    start_rngAddress = 1;
                    state <= 3;
                end
                4'd3: begin
                    if (done_rng_address) begin
                        state <= 4;
                        start_rngAddress <= 0;
                        rng_address_temp = rng_address;

                        // address and index of betterNeighbor
                        address_count <= 16'h668 + rng_address_temp*2;
                    end
                    else
                        state <= 3;
                end
                4'd4: begin
                    nexthop_buf <= data_in;
                    if (epsilon_buf < epsilon_step)
                        epsilon_temp <= 0;
                    else
                        epsilon_temp <= epsilon_buf - epsilon_step;
                    
                    // Done winnerPolicy
                    done_winnerPolicy_buf = 1;
                    state <= 8;
                end
                4'd5: begin            
                    /*
                     *  [15:0] _bestvalue   - 12 bits whole, 4 bits fraction
                     *  [15:0] _mybest      - 12 bits whole, 4 bits fraction
                     *  [8:0] nineninenine  - 9 bits fraction
                     *  _left, _right = 12 bits whole, 13 bits fraction
                     */
                    _left = {_bestvalue, 9'b0};
                    _right = _mybest * nineninenine;

                    // Malayong mas malaki ang mybest kaysa bestvalue 
                    if (_left < _right) begin
                        one <= 0;
                        nexthop_buf <= _besthop;

                        // Done winnerPolicy
                        done_winnerPolicy_buf <= 1;
                        state <= 8;
                    end
                    else begin
                        one = 1;
                        state <= 6;
                    end
                end
                4'd6: begin
                    /*
                     *  [15:0] _bestvalue   - 12 bits whole, 4 bits fraction
                     *  [15:0] _mybest      - 12 bits whole, 4 bits fraction
                     *  [8:0] onezerozeroone - 15 bits fraction
                     *  _left, _right = 12 bits whole, 19 bits fraction
                     */
                    _left2 = {_bestvalue, 15'b0};
                    _right2 = _mybest * onezerozeroone; // 12 bits whole, 10 bits fraction 
                    _mybest_shifted = {_mybest, 19'b0};
                    _right2 = _right2 + _mybest_shifted;

                    if (_left2 < _right2) 
                        two <= 1;
                    else
                        two <= 2;

                    if (_bestneighborID == MY_NODE_ID)
                        three <= 0;
                    else
                        three <= 1;

                    state <= 7;
                end
                4'd7: begin

                    if (one & two & three) begin
                        nexthop_buf <= _besthop;
                    end

                    done_winnerPolicy_buf <= 1;
                    state <= 8;
                end
                default
                    state <= 8;
                
/*                4'd3: begin
                    betterNeighborCount = data_in;
                    
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
*/                    
            endcase
        end
    end

    assign nexthop = nexthop_buf;
    assign done_winnerPolicy = done_winnerPolicy_buf;
    assign cstate = state;
    assign address = address_count;
endmodule