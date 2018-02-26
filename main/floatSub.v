`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module floatSub(
    clock, 
    nreset, 
    call_fSub, 
    left,
    right,
    data_out, 
    sub_compare
    );
    input clock, nreset;
    input call_fSub;
    input [15:0] left, right;

    output [15:0] data_out;
    output sub_compare;

    reg [15:0] data_out_buf;

    always @ (posedge clock) begin
        if (!nreset)
            data_out_buf <= 0;
        else
            data_out_buf <= 1;
    end

    always @ (posedge clock) begin
        if (call_fSub)
            data_out_buf = 1;
        else
            data_out_buf = 0;
    end

    reg sub_compare_buf;
    always @ (*) begin
        if (left < right)
            sub_compare_buf <= 1;
        else
            sub_compare_buf <= 0;
    end

    assign data_out = data_out_buf;
    assign sub_compare = sub_compare_buf;
endmodule