module winnerPolicy(clock, reset, value);
    input clock, reset;
    output [31:0] value;

    reg [31:0] a, b, c;
    reg [5:0] count;

    // Reset the circuit
    always @ (posedge reset)
    begin
        a <= 31'd0;
        b <= 31'd1;
        count <= 6'd0;
    end

    // Every clock
    always @ (posedge clock)
    begin 
        a = a * 2;
        count = count + 1;
    end

    // Read the value of a and assign to value
    assign value = a;
endmodule

module winnerPolicy_tb();
    reg clock, reset;
    wire [31:0] value;

    winnerPolicy wp1(clock, reset, value);

    initial begin
        reset = 1;
        #10 reset = 0;
        #100 reset = 1;
        #100 reset = 0;
    end

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("winnerPolicy.vcd");
        $dumpvars(0, winnerPolicy_tb);
        #200 $finish;
    end
endmodule