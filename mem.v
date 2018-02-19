`define MEM_DEPTH   2048
`define MEM_WIDTH   8
`define WORD_WIDTH  16
module mem(clock, address, wr_en, data_in, data_out);
    input clock, wr_en;
    input [`WORD_WIDTH-1:0] address, data_in;
    output [`WORD_WIDTH-1:0] data_out;

    reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

    initial begin
        memory[0] <= 0;
        memory[1] <= 1;
        memory[2] <= 2;
        memory[3] <= 3;
        memory[4] <= 4;
        memory[5] <= 5;
    end

    // Read
    reg [`WORD_WIDTH-1:0] data_out_ph;
    always @ (*)
        data_out_ph <= {memory[address], memory[address + 1]};

    // Write 
    always @ (posedge clock)
    begin
        if (wr_en) begin
            memory[address] <= data_in[15:8];
            memory[address + 1] <= data_in[7:0]; 
        end
    end

    assign data_out = data_out_ph;
endmodule


/*
 *  Testbench
 *
 *
 */
`define CLOCK_PD 10;
`define DELAY_IN 3
module tb_mem();
    reg clock, reset;
    reg [15:0] address;
    reg [15:0] data_in;
    wire [15:0] data_out;
    reg wr_en;

    mem mem1(clock, address, wr_en, data_in, data_out);

    // Clock
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Address
    initial begin
        address = 0;
        #10 address = 2;
        #20 address = 3;
        #20 address = 2;
        #20 address = 3;
        //forever #5 address = address + 1;
    end

    // Write
    initial begin
        data_in = 15;
        wr_en = 0; 
        #15 wr_en = 1;
        #2 wr_en = 0;
    end

    // Display initial contents of memory
    integer i;
    initial begin
        #1
        for (i = 0; i < 5; i=i+1) begin
            $display("hello");
            $display("%X", mem1.memory[i]);
            $display(i);
        end
    end

    initial begin
        $dumpfile("mem.vcd");
        $dumpvars(0, tb_mem);
        #200
        $finish;
    end    
endmodule