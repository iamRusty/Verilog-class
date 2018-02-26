`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module floatSub(clock, nreset, call_fRNG, data_out, sub_compare);
    input clock, nreset;
    input call_fRNG;

    output [15:0] data_out;

    reg [15:0] data_out_buf;

    always @ (posedge clock) begin
        if (!nreset)
            data_out_buf <= 0;
        else
            data_out_buf <= 1;
    end

    always @ (posedge clock) begin
        if (call_fRNG)
            data_out_buf = 1;
        else
            data_out_buf = 0;
    end

    assign data_out = data_out_buf;
endmodule