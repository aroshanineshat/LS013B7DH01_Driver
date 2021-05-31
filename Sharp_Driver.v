/***
* Created: Feb 07, 2021 
* Programmer: Arash Roshanineshat
*
* This IP drives a LS013B7DH01
***/

/*
    There are 4 states for LS013B7DH01
    1- Mode selection state
    2- Gate line address state
    3- Data writing state
    4- Dummy data writing state
*/


`timescale 1ns/1ps

module Sharp_Driver(
    input wire clk_12mhz,

    output wire SCLK,
    output wire SI,
    output wire SCS
);

    localparam integer mode_bit_count = 8; 
    localparam integer address_bit_count = 8;
    localparam integer data_bit_count = 144;
    localparam integer dummy_bit_count = 8;

    localparam integer STATE_SETUP          = 5;
    localparam integer STATE_SELECT_MODE    = 0;
    localparam integer STATE_SELECT_ADDRESS = 1;
    localparam integer STATE_TRANSF_DATA    = 2;
    localparam integer STATE_TRANSF_DUMMY   = 3;
    localparam integer STATE_HOLD           = 4;

    localparam integer MODE_STATIC  = 'h00; // 0hxxxxx000 M0->0, M1->0, M2->0 -> Static mode
    localparam integer MODE_UPDATE  = 'h01; // 0hxxxxx001 M0->1, M1->0, M2->0 -> Update mode

    wire clk_1mhz;

    reg [2:0] CURRENT_STATE;
    reg [2:0] CURRENT_MODE;
    reg [7:0] ADDR_r;
    reg [2:0] DATA_r;

    reg SCLK_r;
    reg SCS_r;
    reg SI_r;

    //===============================
    //State Counter (32 bit)
    //===============================
    //the counter will count the number of clocks
    //to keep track of the state 
    //there are 6 states
    //State 0 ->   8 clks for tsSCS (setup)
    //State 1 ->   8 clks for modes
    //State 2 ->   8 clks for row address
    //State 3 -> 144 clks for data
    //State 4 ->  16 clks for dummy data
    //State 5 ->   8 clks for thSCS (hold)
    reg [31:0] clk_counter;

    //================================
    //Initialization of Vars
    //================================
    initial begin
        SCS_r = 0;
        SCLK_r = 0;
        SI_r  = 0;

        ADDR_r = 'd50;
        DATA_r = 'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF; //dummy data for the image
        clk_counter = 0;

        CURRENT_STATE = STATE_SETUP;
        CURRENT_MODE  = MODE_STATIC;
    end
    //================================

    //================================
    //Create a 1 MHz clock
    //================================
    clk_divider #(
      .clk_divider (12) // Divide the 12MHz clock by 12 to create 1 MHz clock
    ) clk1mhz (
        .clk_12mhz (clk_12mhz),
        .clk_output (clk_1mhz)
    );
    //================================

    /*
        Select Mode options:
            bits: <M0><M1><M2><><><><><>
            M0, 1 for Data update. 0 for data maintain
            M1, 1 for vcom=1, 0 for vcom=0
            M2, all clear
            the rest bits is recommended to be 0
    */
    always @(posedge clk_1mhz) begin
        case (CURRENT_STATE)
	          STATE_SETUP: begin // state 0 - 8 clks
              if (clk_counter == 8) begin
                CURRENT_STATE = STATE_SELECT_MODE;
              end
	          end
            STATE_SELECT_MODE: begin // state 1 - 8 clks
              if (clk_counter == 16) begin
                CURRENT_STATE = STATE_SELECT_ADDRESS;
              end
            end
            STATE_SELECT_ADDRESS: begin // state 2 - 8clks
              if (clk_counter == 24) begin
                CURRENT_STATE = STATE_TRANSF_DATA;
              end
                
            end
            STATE_TRANSF_DATA: begin // state 3 - 144 clks
              if (clk_counter == 168) begin
                CURRENT_STATE = STATE_TRANSF_DUMMY;
              end
                
            end
	          STATE_TRANSF_DUMMY:begin // state 4 - 16 clks
              if (clk_counter == 184) begin
                CURRENT_STATE = STATE_HOLD;
              end
	          end
	          STATE_HOLD: begin // state 5 -  4 clks
              if (clk_counter == 188) begin
                CURRENT_STATE = STATE_SETUP;
              end
	          end
            default: begin
              CURRENT_STATE = STATE_HOLD;
            end
        endcase
    end 

    always @(posedge clk_1mhz) begin
	    if (clk_counter < 188) begin
		    clk_counter <= clk_counter + 1;
	    end else begin 
        clk_counter <= 1;
      end
    end

    assign SCLK = SCLK_r;
    assign SCS  = SCS_r;
    assign SI   = SI_r;

endmodule
