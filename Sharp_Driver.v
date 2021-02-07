/***
* Created: Feb 07, 2021 
* Programmer: Arash Roshanineshat
***/

`timescale 1ns/1ps

module Sharp_Driver(
    input wire Clk_12MHz,
    input wire load,

    output wire SCK,
    output wire SI,
    output wire SCS
);


    localparam integer clk_divider =  6; // 12 / 2, This will produce 1MHz signal
    localparam integer mode_reg_count = 8; 
    localparam integer address_reg_count = 8;
    localparam integer data_reg_count = 144;
    localparam integer idle_reg_count = 8;

    localparam integer STATE_IDLE           = 0;
    localparam integer STATE_SELECT_MODE    = 0;
    localparam integer STATE_SELECT_ADDRESS = 1;
    localparam integer STATE_TRANSF_DATA    = 2;

    localparam integer MODE_STATIC  = 0x00; // 0hxxxxx000 M0->0, M1->0, M2->0 -> Static mode
    localparam integer MODE_DYNAMIC = 0x01; // 0hxxxxx001 M0->1, M1->0, M2->0 -> Dynamic mode


    reg [5:0] CURRENT_STATE;
    reg [0+:mode_reg_count]    CURRENT_MODE;
    reg [0+:address_reg_count] ADDR_r;
    reg [0+:data_reg_count]    DATA_r;

    reg SCK_r;
    reg SCS_r;
    reg [0+:32] clock_counter;
    reg [0+:32] dummy_counter;

    initial begin
        SCS_r = 0;
        SCK_r = 0;
        clock_counter = 0;
        ADDR_r = 'd50;
        DATA_r = 0hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
        dummy_counter = 0;
        CURRENT_STATE = STATE_IDLE
        CURRENT_MODE  = MODE_STATIC;
    end

    always @(posedge Clk_12MHz) begin
        if (clock_counter >= clk_divider) begin
            clock_counter <= 0; 
            SCK_r <= ~SCK_r;
        end else begin
            clock_counter <= clock_counter + 1;
        end
    end

    always @(posedge Clk_12MHz) begin
        case (CURRENT_STATE) begin
            case (STATE_IDLE): begin
                
            end
            case (STATE_SELECT_MODE) begin
                
            end
            case (STATE_SELECT_ADDRESS) begin
                
            end
            case (STATE_TRANSF_DATA) begin
                
            end
        endcase
    end 

    assign SCS = SCR_r;

endmodule