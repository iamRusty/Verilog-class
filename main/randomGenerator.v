/*
 *  Linear Feedback Shift Register
 *  
 *  Reference: https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
 */

//`include "memory.v"

module randomGenerator(clock, nreset, rng_out, rng_out_4bit);
    input clock, nreset;
    output [15:0] rng_out;
    output [15:0] rng_out_4bit;

    reg [15:0] global_feedback;

    reg [15:0] rng_out_buf;
    reg feedback;

    // Memory Module
    reg wr_en;
    reg [15:0] data_in, address;
    wire [15:0] data_out;
    mem mem3(clock, address, wr_en, data_in, data_out);

    // RNG
    reg [2:0] state;
    always @ (posedge clock) begin
        if (!nreset) begin
            rng_out_buf <= 5;
            state <= 1;
            address <= 16'h7FE;
        end
        else begin
            case (state)
                3'd1: begin
                    // Read RNG_SEED in Memory
                    rng_out_buf <= data_out;
                    state <= 2;
                end
                3'd2: begin
                    rng_out_buf <= {rng_out_buf[14:0], feedback};
                    state <= 2;
                end
                default: 
                    state <= 2;
            endcase
        end
    end

    // Feedback
    always @ (*) begin
        feedback = ~(rng_out_buf[15] ^ rng_out_buf[14] ^ rng_out_buf[12] ^ rng_out_buf[3]);
    end

    assign rng_out = rng_out_buf;
    assign rng_out_4bit = {12'd0, rng_out_buf[3:0]};
endmodule
