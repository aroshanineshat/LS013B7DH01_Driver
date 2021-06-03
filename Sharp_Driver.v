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
    output wire SCS,
    output wire LED,
    output wire EXTCOMIN
);

    localparam integer mode_bit_count = 8; 
    localparam integer address_bit_count = 8;
    localparam integer data_bit_count = 144;
    localparam integer dummy_bit_count = 8;

    localparam integer STATE_SETUP          = 0;
    localparam integer STATE_SELECT_MODE    = 1;
    localparam integer STATE_SELECT_ADDRESS = 2;
    localparam integer STATE_TRANSF_DATA    = 3;
    localparam integer STATE_TRANSF_DUMMY   = 4;
    localparam integer STATE_HOLD           = 5;

    reg [2:0] MODE_STATIC  = 3'b000; // 0hxxxxx000 M0->0, M1->0, M2->0 -> Static mode
    reg [2:0] MODE_UPDATE  = 3'b001; // 0hxxxxx001 M0->1, M1->0, M2->0 -> Update mode

    wire clk_1mhz;

    reg [2:0] CURRENT_STATE;
    reg [2:0] CURRENT_MODE;
    reg [7:0] ADDR_r;
    reg [143:0] DATA_r;

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
    //------------------------------

    //===============================
    //Data Buffer
    //===============================
    reg [143:0] outputBuffer; 
    //-------------------------------

  

    //================================
    //Initialization of Vars
    //================================
    initial begin
        SCS_r = 1;
        SCLK_r = 0;
        SI_r  = 0;
        outputBuffer = 0;

        ADDR_r = 'd0;
        DATA_r = 'hFFFF_0000_0000_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF; //dummy data for the image
        clk_counter = 0;

        CURRENT_STATE = STATE_SETUP;
        CURRENT_MODE  = MODE_UPDATE;
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
		clk_divider #(
	  	.clk_divider (12000000)
		) clk1hz (
			.clk_12mhz (clk_12mhz),
			.clk_output (LED)
		);

	//================================
	//Generating EXTCOMIN Signal (60Hz)
	//================================
	clk_divider #(
		.clk_divider (200000)
	) clk_60hz (
		.clk_12mhz(clk_12mhz),
		.clk_output(EXTCOMIN)
	);
	

    /*
        Select Mode options:
            bits: <M0><M1><M2><><><><><>
            M0, 1 for Data update. 0 for data maintain
            M1, 1 for vcom=1, 0 for vcom=0
            M2, all clear
            the rest bits is recommended to be 0
    */
    always @(posedge clk_1mhz) begin
              SI_r <= outputBuffer[0];
    end

    always @(posedge clk_1mhz) begin
        case (CURRENT_STATE)
	          STATE_SETUP: begin // state 0 - 8 clks
              if (clk_counter == 8) begin //8
                CURRENT_STATE <= STATE_SELECT_MODE;
                outputBuffer <= CURRENT_MODE;
              end else begin
                outputBuffer <= outputBuffer >> 1;
              end
	          end
            STATE_SELECT_MODE: begin // state 1 - 8 clks
              if (clk_counter == 16) begin // 16
                CURRENT_STATE <= STATE_SELECT_ADDRESS;
                outputBuffer <= ADDR_r;
              end else begin
                outputBuffer <= outputBuffer >> 1;
              end

            end
            STATE_SELECT_ADDRESS: begin // state 2 - 8clks
              if (clk_counter == 24) begin // 24
                CURRENT_STATE <= STATE_TRANSF_DATA;
                outputBuffer <= DATA_r;
              end else begin
                outputBuffer <= outputBuffer >> 1;
              end

                
            end
            STATE_TRANSF_DATA: begin // state 3 - 144 clks
              if (clk_counter == 168) begin // 168
                CURRENT_STATE <= STATE_TRANSF_DUMMY;
                outputBuffer <= 0;
              end else begin
                outputBuffer <= outputBuffer >> 1;
              end 
            end
	          STATE_TRANSF_DUMMY:begin // state 4 - 16 clks
              if (clk_counter == 184) begin//184
                CURRENT_STATE <= STATE_HOLD;
                SCS_r <= 0;
                if (ADDR_r < 168) begin
	                ADDR_r <= ADDR_r + 1;
                end else begin
	                ADDR_r <= 0;
                end
                
                outputBuffer <= 0;
              end
	          end
	          STATE_HOLD: begin // state 5 -  4 clks
              if (clk_counter == 188) begin // 188
                CURRENT_STATE <= STATE_SETUP;
                SCS_r <= 1;
              end
	          end
            default: begin
              CURRENT_STATE <= STATE_HOLD;
            end
        endcase
        //outputBuffer <= outputBuffer >> 1;
    end 

		always @(clk_1mhz) begin
			SCLK_r <= clk_1mhz;
		end

    always @(posedge clk_1mhz) begin
      
			if (clk_counter < 188) begin //188
				clk_counter <= clk_counter + 1;
			end else begin 
    			clk_counter <= 1;
			end
    end

    assign SCLK = SCLK_r;
    assign SCS  = SCS_r;
    assign SI   = SI_r;

endmodule
