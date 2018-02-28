`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module reward(clock, nreset, _action, _besthop, address, data_in, MY_NODE_ID, MY_CLUSTER_ID, done_prev, done, new_data_out);
    input clock, nreset;
    input [`WORD_WIDTH-1:0] _action;
    input [`WORD_WIDTH-1:0] _besthop;

    // Various Memory Access
    output [`WORD_WIDTH-1:0] address;
    input [`WORD_WIDTH-1:0] data_in; 

    /*  Feedback Structure
     *
     *      fsourceID       (2 bytes)
     *      fbatteryStat    (2 bytes)
     *      fValue          (2 bytes)
     *      fclusterID      (2 bytes)
     *      fdestinationID  (2 bytes)
     *
     *  Total = 10 bytes or 80 bits
     */

    // fsourceID
    input [`WORD_WIDTH-1:0] MY_NODE_ID;

    // fclusterID
    input [`WORD_WIDTH-1:0] MY_CLUSTER_ID;

    input done_prev;
    output done;
    output [15:0] new_data_out;

    // Done buffer
    reg done_buf;

    // Address Buffer
    reg [`WORD_WIDTH-1:0] address_count;

    // Tick register
    reg [9:0] tick;

    // Negative Reset
    always @ (negedge nreset) begin
        done_buf <= 0;
        tick <= 0;
        address_count <= 8;
    end

    // Tick counter
    always @ (posedge clock) begin
        if (!nreset)
            tick <= 0;
        else
            if (state == 0)
                tick <= 0;
            else
                tick <= tick + 1;
    end

    // Tick more
    always @ (posedge done_prev) begin
        tick <= 0;
    end

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

    // Next state
    reg [3:0] state;
    always @ (posedge clock) begin
        if (!nreset) begin
            state <= 0;
        end
        else begin
            case(state)
                4'd0: begin
                    if (done_prev)
                        state <= 1;
                    else
                        state <= 0;
                end
                4'd1:
                    state <= 2;
                4'd2: begin
                    address_count = 'h148 + MY_NODE_ID*2;
                    state <= 3;
                end
                4'd3: begin
                    address_count = 'h1C8 + _besthop*2;
                    state <= 4;                
                end
                4'd4: 
                    state <= 5;
                4'd5: begin
                    address_count = 'h48 + _action*2;
                    state <= 6;     
                end     
                default: state <= 6;
            endcase
        end
    end

    // Output Data
    reg [15:0] new_data_out_buf;
    always @ (*) begin
        case (state)
            1:  new_data_out_buf = MY_NODE_ID;
            4:  new_data_out_buf = MY_CLUSTER_ID;
            default: new_data_out_buf = data_in;
        endcase
    end

    assign new_data_out = new_data_out_buf;

    assign address = address_count;
   
    assign done = (state == 6) ? 1:0;
endmodule