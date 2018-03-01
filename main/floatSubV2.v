`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 16
`define CLOCK_PD 20

module floatSubV2(clock, nreset, left, right, floatSub_data_out, sub_compare);
    input clock, nreset;
    input [`WORD_WIDTH-1:0] left, right;
    output [`WORD_WIDTH-1:0] floatSub_data_out;
    output sub_compare;

    // Registers
    reg [`WORD_WIDTH-1:0] floatSub_data_out_buf;
    reg sub_compare_buf;

    always @ (posedge clock) begin
        if (!nreset) begin
            floatSub_data_out_buf = 0;
            sub_compare_buf = 0;
        end
        else begin
            floatSub_data_out_buf = left - right;
            if (left < right) //if (floatSub_data_out_buf < 0)
                sub_compare_buf = 1;
            else
                sub_compare_buf = 0;
        end
    end

    assign sub_compare = sub_compare_buf;
    assign floatSub_data_out = floatSub_data_out_buf;
endmodule