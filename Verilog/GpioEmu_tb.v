`timescale 1ns / 1ps

module gpioemu_tb();

    reg clk;
    reg reset;
    reg [23:0] A1;
    reg [23:0] A2;
    wire [31:0] W;
    wire [23:0] L;
	wire ready;
    wire [1:0] B;
    wire valid;
    wire [15:0] gpio;

    gpioemu gpioemu_inst (
        .clk(clk),
        .reset(reset),
        .A1(A1),
        .A2(A2),
        .W(W),
        .L(L),
        .B(B),
        .valid(valid),
		.ready,
        .gpio(gpio)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
	$dumpfile("GpioEmu.vcd");
    $dumpvars(0, gpioemu_tb);
        clk = 0;
        reset = 1;
        A1 = 0;
        A2 = 0;
        #10 reset = 0;

        @(posedge clk) begin
            A1 = 24'h123456;
            A2 = 24'h789abc;
        end

        repeat (60) @(posedge clk);

        @(posedge clk) begin
            A1 = 24'h1;
            A2 = 24'h2;
        end

        repeat (60) @(posedge clk);

        @(posedge clk) begin
            A1 = 24'h3;
            A2 = 24'h4;
        end

        repeat (60) @(posedge clk);

        $finish;
    end

    initial begin
        $monitor("%d: A1 = %h, A2 = %h, W = %h, L = %h, ready = %b, valid = %b, B = %b, gpio = %h",
                 $time, A1, A2, W, L,ready,valid,B, gpio);
    end

endmodule
