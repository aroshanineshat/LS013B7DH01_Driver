/***
    Created: Feb 07, 2021 
    Programmer: Arash Roshanineshat
***/

`timescale 1ns/1ps

module clk_divider #(
    parameter integer clk_divider  = 12
)
(
    input wire clk_12mhz,
    output wire clk_output
);

    reg clk_counter;
    reg clk_output_r;

    initial begin 
        clk_counter = 0;
    end

    always @(posedge Clk_12MHz) begin
        if (clk_counter >= (clk_divider / 2)) begin
            clk_output_r ~= clk_output_r;
            clk_counter = 1;
        end else begin
            clk_output_r = clk_output_r + 1;
        end
    end 

    assign clk_output = clk_output_r;

endmodule 