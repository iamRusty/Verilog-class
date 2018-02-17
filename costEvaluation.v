/*
 *  Function: amiSink
 *  Description: Check if i am a sink
 *  clk         :   Clock
 *  reset       :   Reset
 *  knownSinks  :   flattened array of size [10][5 bits]
 *  argID       :   flatted array of size [10][5 bits]
 *  iamSink     :   return value (boolean 1 or 0) 
 *
 *  Suggestions:
 *      instead of passing 
 */

module amiSink(clock, reset, knownSinks, argID, iamSink);
    input clock, reset;
    //input [4:0] knownSinks[0:9];    // 10 * 5 bit regs
    //input [4:0] argID[0:9];         // 10 * 5 bit regs
    input knownSinks;
    input argID;
    output iamSink;

    reg [4:0] count;
    reg iamSink_ph; // iamSink placeholder 

    // Reset the circuit
    always @ (posedge reset)
    begin
        count <= 5'd0;
    end

    // Every clock 
    always @ (posedge clock)
    begin
        if (knownSinks == argID) begin
            iamSink_ph = 1'd1;
        end
        else begin
            iamSink_ph = 1'd0;
        end
    end

    // Read the value of iamSink_ph
    assign iamSink = iamSink_ph;
endmodule

module general_testbench();
    reg clock, reset;
    wire iamSink_bool;

    reg knownSinks, argID;

    amiSink ais1(clock, reset, knownSinks, argID, iamSink_bool);

    // Initial Reset
    initial begin
        reset = 1;
        #2 reset = 0;
    end

    // Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // knownSinks
    initial begin
        knownSinks = 1;
        #50 knownSinks = 0;
        #50 knownSinks = 1;
        #50 knownSinks = 0;
    end

    // argID
    initial begin
        argID = 0;
        #100 argID = 1;
        #100 argID = 0;
    end

    initial begin
        $dumpfile("costEvaluation.vcd");
        $dumpvars(0, general_testbench);
        #200 $finish;
    end
endmodule


