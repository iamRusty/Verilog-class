`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16

/*  Register bank
 *  0x0 - iamSink
 */

module amISink(clock, reset, address, data_in, MY_NODE_ID, iamSink, done);
    input clock, reset;
    input [`WORD_WIDTH-1:0] data_in, MY_NODE_ID;
    output iamSink, done;
    output [`WORD_WIDTH-1:0] address;

    // Registers
    reg iamSink_buf, done_buf;
    reg [`WORD_WIDTH-1:0] address_count;
    initial begin
        iamSink_buf <= 0;
        done_buf <= 0;
        address_count <= 16'h8;
    end

    // Reset
    // Kailangan ang reset kung tapos na ang isang loop ng 
    // buong CLIQUE CostEvaluation until Reward Module  
    always @ (posedge reset) begin
        iamSink_buf <= 0;
        done_buf <= 0;
        address_count <= 16'h8;
    end

    always @ (posedge clock) begin
        if (!done_buf) begin // Break loop after done
            if (MY_NODE_ID == data_in) begin
                iamSink_buf = 1;
                done_buf = 1;
            end

            address_count = address_count + 2; // +2 dahil every 2 bytes

            // Kapag tapos na lahat ng knownSinks array
            if (address_count == 40)
                done_buf = 1;
        end
    end

    assign iamSink = iamSink_buf;
    assign done = done_buf;
    assign address = address_count;
endmodule