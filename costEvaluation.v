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
 *  1. (TBD) instead of passing all the values, pass the memory address instead
 */

module amiSink(clock, reset, knownSinks, argID, iamSink);
    input clock, reset;
    input [10*5-1 : 0] knownSinks;
    input [10*5-1 : 0] argID;
    reg [4:0] reg_knownSinks[0:9];  // 10 * 5 bits reg 
    reg [4:0] reg_argID[0:9];       // 10 * 5 bits reg

    reg [4:0] count;
    reg iamSink_ph; // iamSink placeholder
        
    output iamSink; 

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

module asdasd(clock, reset, knownSinks_a);
    input clock, reset;
    output [10*5-1 : 0] knownSinks_a;

    reg [10*5-1 : 0] knownSinks_a_a;
    reg [5:0] i;
    always @ (posedge reset)
        for (i = 0; i < 10; i=i+1)
            knownSinks_a_a[5*i +: 5] = i;

    assign knownSinks_a = knownSinks_a_a;
endmodule

module general_testbench();
    reg clock, reset;
    wire iamSink_bool;

    //reg knownSinks, argID;
    reg [10*5-1 : 0] knownSinks;
    reg [10*5-1 : 0] argID;
    wire [10*5-1 : 0] knownSinks_a;

    amiSink ais1(clock, reset, knownSinks, argID, iamSink_bool);
    asdasd asd1(clock, reset, knownSinks_a);

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


