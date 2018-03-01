module randomGenerator(clock, nreset, rng_out, rng_out_3bit);
    input clock, nreset;
    output [7:0] rng_out;
    output [2:0] rng_out_3bit;

    reg [7:0] rng_out_buf;
    reg feedback;

    integer i;

    // RNG
    always @ (posedge clock) begin
        if (!nreset) begin
            rng_out_buf <= 0;
            i <= 0;
        end
        else begin
            $display("%X", i);
            i = i + 1;
            rng_out_buf = {rng_out_buf[6:0], feedback};
        end
    end

    // Feedback
    always @ (*) begin
        feedback = ~(rng_out_buf[7] ^ rng_out_buf[5] ^ rng_out_buf[4] ^ rng_out_buf[3]);
    end

    assign rng_out = rng_out_buf;
    assign rng_out_3bit = rng_out_buf[2:0];
endmodule
