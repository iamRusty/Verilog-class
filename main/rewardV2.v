`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module rewardV2(clock, nreset, start, MY_NODE_ID, MY_CLUSTER_ID, _action, _besthop, address, data_in, data_out, done);

    input clock, nreset, start;
    input [`WORD_WIDTH-1:0 ] MY_NODE_ID, MY_CLUSTER_ID, _action, _besthop, address, data_in;
    output [`WORD_WIDTH-1:0] data_out;
    output done;

    // Registers
    reg [`WORD_WIDTH-1:0] address_count;
    reg [`WORD_WIDTH-1:0] data_out_buf;
    reg done_buf;

    /*
     *  State Machine
     *  0 - IDLE/Wait for done_prev 
     *  1 - Process fsourceID
     *  2 - Process fbatteryStat
     *  3 - Process fValue
     *  4 - Process fclusterID
     *  5 - Process fdestinationID
     *  6 - done
     */

    reg [3:0] state;
    always @ (posedge clock) begin
        if (!nreset) begin
            state <= 0;
            done_buf <= 0;
        end
        else begin
            case (state)
                4'd0: begin
                    if (start)
                        state <= 1;
                    else
                        state <= 0;
                end
                4'd1: begin
                    state <= 2;
                    address_count = 16'h148 + MY_CLUSTER_ID*2;
                end
                4'd2: begin
                    state <= 3;
                    address_count =  16'h1C8 + _besthop*2;
                end
                4'd3: begin
                    state <= 4;
                end
                4'd4: begin
                    state <= 5;
                    address_count = 16'h48 + _action*2;
                end
                4'd5: begin
                    state <= 6;
                end
                default: begin
                    state <= 6;
                    done_buf <= 1;
                end
            endcase
        end
    end

    always @ (*) begin
        case (state)
            1: data_out_buf = MY_NODE_ID;
            4: data_out_buf = MY_CLUSTER_ID;
            default: data_out_buf = data_in;
        endcase
    end

    assign data_out = data_out_buf;
    assign done = done_buf;
    assign address = address_count;
endmodule