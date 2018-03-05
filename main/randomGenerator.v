/*
 *  Linear Feedback Shift Register
 *  
 *  Reference: https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
 */

//`include "memory.v"

module randomGenerator(clock, nreset, mem_data_out, address, rng_out, rng_out_4bit, ako_boss);
    input clock, nreset;
    input [15:0] mem_data_out;
    output [15:0] address, rng_out, rng_out_4bit;
    reg [15:0] rng_out_buf, address_count;
    reg feedback, ako_boss_buf;
    output ako_boss;

/*
    // Memory Module
    reg wr_en;
    reg [15:0] data_in, address;
    wire [15:0] data_out;
    mem mem3(clock, address, wr_en, data_in, data_out);
*/

    // RNG
    reg [2:0] state;
    always @ (posedge clock) begin
        if (!nreset) begin
            rng_out_buf <= 5;
            state <= 1;
            address_count <= 16'h7FE;
            ako_boss_buf <= 1;
        end
        else begin
            case (state)
                3'd1: begin
                    // Read RNG_SEED in Memory
                    rng_out_buf <= mem_data_out;
                    state <= 2;
                    ako_boss_buf <= 0;
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
    assign address = address_count;
    assign ako_boss = ako_boss_buf;
endmodule
