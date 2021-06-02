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
);

  Sharp_Driver inst1 (
    .clk_12mhz (CLK),
    .SCLK(P1B10),
    .SI (P1B4),
    .SCS (P1B3),
    .LED (LED4)
  );
endmodule 
