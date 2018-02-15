module fibonacci(clock, reset, value);
    input clock, reset;
    output [31:0] value;

    reg [31:0] previous, current;
    reg [5:0] counter;

    // Reset the circuit 
    always @ (posedge reset)
    begin
      previous <= 32'd0;
      current <= 32'd1;
      counter <= 6'd1;
    end

    always @ (posedge clock)
    begin
        // Increment current index 
        counter = counter + 1;
        current = current + previous;
        previous = current - previous;
    end

    // Read the value of the nth fibonacci number
    assign value = previous;
endmodule


module fibtb();
    reg clock, reset;
    wire [31:0] value;
    fibonacci f1(clock, reset, value);
    
    initial begin
        reset = 1;
        #10 reset = 0;
        #400 reset = 1;
        #10 reset = 0;
    end

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("fib.vcd");
        $dumpvars(0, fibtb);
        #1000 $finish;
    end

    initial
        $monitor("At time %t, value = %h (%0d)", $time, value, value);


endmodule