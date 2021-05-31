/***
*   Date: May 31st, 2021
*   Author: Arash Roshanineshat
*   Module: Sharp Display Test Bench
***/

`timescale 1ns/1ps

module tb;

  reg clk; 

  wire tSCLK;
  wire tSI;
  wire tSCS;

  //=====================
  //Generating the clock
  //=====================
  initial begin
    clk = 0;
    forever begin
      #1 clk = ~clk;
    end
  end
  //--------------------

  Sharp_Driver inst1(
    .clk_12mhz (clk),
    .SCLK (tSCLK),
    .SI   (tSI),
    .SCS  (tSCS)
  );

  initial begin
      #5000 $finish;
  end

  initial
  begin
      $dumpfile("test.vcd");
      $dumpvars(0,tb);
  end
endmodule
