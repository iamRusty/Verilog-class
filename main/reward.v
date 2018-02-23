`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module reward(clock, reset, _action, _besthop, address, data_in, data_out, MY_NODE_ID, MY_CLUSTER_ID, done_prev, done);
    input clock, reset;
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
    output [80 - 1: 0] data_out;
    reg [80 - 1: 0] data_out_buf;   // data_out buffer

    // fsourceID
    input [`WORD_WIDTH-1:0] MY_NODE_ID;

    // fclusterID
    input [`WORD_WIDTH-1:0] MY_CLUSTER_ID;

    input done_prev;
    output done;

    // Done buffer
    reg done_buf;

    // Address Buffer
    reg [`WORD_WIDTH-1:0] address_count;

    // Tick register
    reg [9:0] tick;

    // Reset
    always @ (posedge reset) begin
        done_buf <= 0;
        data_out_buf <= 0;
        tick <= 0;
        address_count <= 8;
    end
/*
    // Tick counter
    always @ (posedge) begin
        tick = tick + 1;
    end

    // State machine
    always @ (posedge clock) begin

    end
*/
    reg [`WORD_WIDTH-1:0] fsourceID;
    reg [`WORD_WIDTH-1:0] fbatteryStat;
    reg [`WORD_WIDTH-1:0] fValue;
    reg [`WORD_WIDTH-1:0] fclusterID;
    reg [`WORD_WIDTH-1:0] fdestinationID;

    always @ (posedge done_prev) begin
        if (done_buf == 0) begin
            // Get all the components, store in registers
            // and then concatenate
            
            // fsourceID
            #(`CLOCK_PD);
            fsourceID = MY_NODE_ID;
            #(`CLOCK_PD);        
            
            // fbatteryStat
            address_count = 328 + MY_NODE_ID;   // 0x148 + MY_NODE_ID
            #(`CLOCK_PD);
            fbatteryStat = data_in;
            #(`CLOCK_PD);
            
            // fValue
            address_count = 456 + _besthop;     // 0x1C8 + _besthop
            #(`CLOCK_PD);
            fValue = data_in;
            #(`CLOCK_PD);

            // fclusterID
            fclusterID = MY_CLUSTER_ID;
            #(`CLOCK_PD);

            // fdestinationID
            address_count = 72 + _action;       // 0x48 + _action
            #(`CLOCK_PD);
            fdestinationID = data_in;
            #(`CLOCK_PD);

            // Concatenate
            data_out_buf = {fsourceID, fbatteryStat, fValue, fclusterID, fdestinationID};
            #(`CLOCK_PD);

            // Invoke done
            done_buf = 1;
        end
    end 

    assign address = address_count;
    assign done = done_buf;
    assign data_out = data_out_buf;
endmodule