module rngAddress(clock, nreset, len_better_qvalue, RNG_ADDRESS);
    input clock, nreset;
    input [15:0] len_better_qvalue;
    output reg [15:0] RNG_ADDRESS;

    always @ (posedge clock) begin  
        if (!nreset) begin
            RNG_ADDRESS <= 0;
        end
        else begin
            RNG_ADDRESS <= 1;
        end
    end
endmodule