`timescale 1 ns/10 ps

module gpioemu_tb;

reg n_reset = 1;
reg [15:0] saddress = 0;
reg srd = 0;
reg swr = 0;
reg valid = 0;
reg [31:0] sdata_in = 0;
reg [31:0] gpio_in = 0;
reg gpio_latch = 0;
reg [31:0] gpio_out = 0;
reg clk = 0;
reg [31:0] gpio_in_s_insp = 0;

integer i;

initial begin
  $dumpfile("gpioemu.vcd");
  $dumpvars(0, gpioemu_tb);
  clk = 0;
end

initial begin

for(i=0;i<500;i=i+1)
#2 clk = ~clk;

end

initial begin
  // Reset
  #5 n_reset = 0;
  #5 n_reset = 1;

  //  2*8 =16
  // arg1
  #5 sdata_in = 32'h2;
  #5 saddress = 16'h037F;
  #5 swr = 1;
  #5 swr = 0;

  // arg2
  #5 sdata_in = 32'h8;
  #5 saddress = 16'h0388;
  #5 swr = 1;
  #5 swr = 0;

  // status start
  #5 saddress = 16'h03A0;
  #5 swr = 1;
  #5 swr = 0;

  // wynik
  #30 saddress = 16'h0390;
  #5 srd = 1;
  #5 srd = 0;
  ////////////////////////////////////////////////////////////
  
  
  
  
    // Reset
  #5 n_reset = 0;
  #5 n_reset = 1;

  //  16*128 =2048
  // arg1
 
  #5 sdata_in = 32'h10;
  #5 saddress = 16'h037F;
  #5 swr = 1;
  #5 swr = 0;

  // arg2
  #5 sdata_in = 32'h80;
  #5 saddress = 16'h0388;
  #5 swr = 1;
  #5 swr = 0;

  // status start
  #5 saddress = 16'h03A0;
  #5 swr = 1;
  #5 swr = 0;

  // wynik
  #30 saddress = 16'h0390;
  #5 srd = 1;
  #5 srd = 0;
  
  
  
    ////////////////////////////////////////////////////////////
  
  
  
  
    // Reset
  #5 n_reset = 0;
  #5 n_reset = 1;

  //  8 388 608*2048 =??? test sprawdza czy zmieni się wartosć B
  // arg1
   #5 saddress = 16'h03A1;
  #5 sdata_in = 32'h80000;
  #5 saddress = 16'h037F;
  #5 swr = 1;
  #5 swr = 0;

  // arg22
  #5 sdata_in = 32'h8007;
  #5 saddress = 16'h0388;
  #5 swr = 1;
  #5 swr = 0;

  // status start
  #5 saddress = 16'h03A0;
  #5 swr = 1;
  #5 swr = 0;

  // wynik
  #30 saddress = 16'h0390;
  #5 srd = 1;
  #5 srd = 0;
  

end

wire [31:0] gpio_out_test;
wire [31:0] sdata_out_test;
wire [31:0] gpio_in_s_insp_test;

gpioemu t(n_reset,
saddress,
srd,
swr,
sdata_in,
sdata_out_test,
gpio_in,
gpio_latch,
gpio_out_test,
clk,
gpio_in_s_insp_test);

initial begin
$display("At %t, gpio_out = %h, sdata_out = %h", $time, gpio_out_test, sdata_out_test);

end



endmodule
