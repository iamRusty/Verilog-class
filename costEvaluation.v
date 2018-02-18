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
 *  2. Use sequence indicators to make a sequential circuits between modules
 */

module amiSink(clock, reset, knownSinks, argID, iamSink, goToForwardNode);
    input clock, reset;
    input [10*5-1 : 0] knownSinks;
    input [5:0] argID;

    reg [4:0] count;
    output iamSink, goToForwardNode; 

    // Reset the circuit
    always @ (posedge reset)
    begin
        count <= 5'd0;
    end

    reg [4:0] knownSinks_ph; // current sink value
    reg iamSink_ph, goToForwardNode_ph;
    initial begin
        goToForwardNode_ph = 0;
    end
    // Every clock
    always @ (posedge clock) begin
        knownSinks_ph = knownSinks[5*count +: 5];
        if (knownSinks_ph == argID)
            iamSink_ph = 1;
        else
            iamSink_ph = 0;

        count = count + 1;
        if (count == 10)
            goToForwardNode_ph = 1;
    end
/*
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
*/
    // amiSink output
    assign iamSink = iamSink_ph;

    // done in amiSink? output
    assign goToForwardNode = goToForwardNode_ph;


endmodule

module knownSinks_test(clock, reset, knownSinks_a);
    input clock, reset;
    output [10*5-1 : 0] knownSinks_a;

    reg [10*5-1 : 0] knownSinks_a_a;
    reg [5:0] i;
    always @ (posedge reset)
        for (i = 0; i < 10; i=i+1)
            knownSinks_a_a[5*i +: 5] = i;

    assign knownSinks_a = knownSinks_a_a;
endmodule

module arrayParser(clock, reset, knownSinks, value);
    input clock, reset;
    input [10*5-1 : 0] knownSinks;

    reg [5:0] reg_knownSinks[0:9];
    reg [4:0] count;
    reg [4:0] hello;

    output [4:0] value;

    always @ (posedge reset)
    begin
        count <= 5'd0;
    end 

    always @ (posedge clock)
    begin
        hello = knownSinks[5*count +: 5];
        count = count + 1;
    end

    assign value = hello;
endmodule

module general_testbench();
    reg clock, reset;

    //reg knownSinks, argID;
    reg [10*5-1 : 0] knownSinks;
    reg [5:0] argID;
    
    wire iamSink_bool, goToForwardNode_bool;
    amiSink ais1(clock, reset, knownSinks, argID, iamSink_bool, goToForwardNode_bool);
    
    //reg [10*5-1 : 0] knownSinks_a;
    //knownSinks_test ks1(clock, reset, knownSinks_a);

    wire [4:0] arrayParserValue;
    arrayParser ap1(clock, reset, knownSinks, arrayParserValue);

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
/*
    // knownSinks
    initial begin
        knownSinks = 1;
        #50 knownSinks = 0;
        #50 knownSinks = 1;
        #50 knownSinks = 0;
    end
*/
    // knownSinks vector
    reg [4:0] i;
    initial begin
        for(i = 0; i < 10; i=i+1)
            knownSinks[5*i +: 5] = i;
    end

    // argID
    initial begin
        argID = 1;
        //#100 argID = 1;
        //#100 argID = 0;
    end

    initial begin
        $dumpfile("costEvaluation.vcd");
        $dumpvars(0, general_testbench);
        #200 $finish;
    end

endmodule


