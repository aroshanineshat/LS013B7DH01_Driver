/***
*   Date: May 31th, 2021
*   Author: Arash Roshanineshat
*   top module for the LCD driver
***/

`timescale 1ns/1ps

module lcd_driver (
  input CLK,

  output wire P1B10, 
  output wire P1B4,
  output wire P1B3,
  output wire LED4,
  output wire P1B2,
  output wire LED2
);

  Sharp_Driver inst1 (
    .clk_12mhz (CLK),
    .SCLK(P1B10),
    .SI (P1B4),
    .SCS (P1B3),
    .LED (LED4),
    .EXTCOMIN(P1B2)
  );
  assign LED2 = P1B2;
endmodule 
