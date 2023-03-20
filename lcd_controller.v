`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AKSHI TECHNOLOGIES PVT LTD.
// Engineer: KISHORE BACHU	
// 
// Create Date: 06:44:36 02/02/2023 
// Design Name: LCD Controller
// Module Name: lcd_controller 
// Project Name: SPARTAN-3E FPGA BOARD
// Target Devices: XC3SE
// Tool versions: ISE 14.7
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lcd_controller(
				SLOW_CLK,			//Slow Clock, 1Mhz
				SYS_RST,				//Active High System Reset, Push BTN SOUTH
				LCD_RS,				//LCD Register select. 0 = Instruction register during write. 1 = Data Regisfor read or write
				LCD_RW,				//LCD Read/Write Control. 0 = Write, LCD accepts data. 1 = Read, LCD presents data
				LCD_E,				//LCD Read/Write Enable Pulse. 0 = Disabled. 1 = Read/Write operation enabled
				LCD_DATA,			//4-bit LCD Data Bus
				LCD_N,
				LCD_P
    );

	//Input Ports
	input SLOW_CLK;
	input SYS_RST;
	
	//Output Ports
	output LCD_RS;
	output LCD_RW;
	output LCD_E;
	output [7:4]LCD_DATA;
	output LCD_N;
	output LCD_P;
	
	//Data Types
	reg LCD_RS;
	reg LCD_E;
	reg [7:4]LCD_DATA;
	
	//Internal Registers
	reg [5:0]state_current;
	reg [5:0]state_next;
	
	assign LCD_N = 0;
	assign LCD_P = 1;
	assign LCD_RW = 0;	//LCD write access only
	
	//Code begins
	always @ (posedge SLOW_CLK or posedge SYS_RST)
	begin
		if (SYS_RST == 1'b1) state_current <= 0;
		else state_current <= state_next;
	end
	
	always @ (*)
	begin
		case (state_current)
			//Spartan-3E Starter kit Board User Guide. UG230 (v1.0)
			//Table 5-3: LCD Character Display Command Set
		
			//--------------------Instruction register (LCD_RS=0)------------------//
					//------------------Clear Display--------------------------//
			0:  begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0000; state_next <= 1; end //Upper Nibble	
			1:  begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000; state_next <= 2; end
			2:  begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0001; state_next <= 3; end //Lower Nibble
			3:  begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0001; state_next <= 4; end
			
					//-----------------Entry Mode Set---------------------------//
			4:  begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0000; state_next <= 5; end //Upper Nibble
			5:  begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000; state_next <= 6; end
			6:  begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0110; state_next <= 7; end //Lower Nibble(01I/DS). I/D=1. S=0.	
			7:  begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0110; state_next <= 8; end
			
					//-----------------Display On/Off---------------------------//
			8:  begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0000; state_next <= 9; end 	//Upper Nibble
			9:  begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000; state_next <= 10; end
			10: begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b1100; state_next <= 11; end	//Lower Nibble(1DCB). D=1. C=0. B=1.
			11: begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b1100; state_next <= 12; end
			
					//-------------------Function set---------------------------//
			12: begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0010; state_next <= 13; end //Upper Nibble
			13: begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0010; state_next <= 14; end
			14: begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b1000; state_next <= 15; end	//Lower Nibble(10DB1DB0). DB1=0. DB0=0.
			15: begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b1000; state_next <= 16; end
			
			//Spartan-3E Starter kit Board User Guide. UG230 (v1.0)
			//Figure 5-4: LCD Character Set
			
			 //-----------------data register (LCD_RS=1)-------------------//
					//------------------write A------------------------//
			16: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 17; end	//Upper Data Nibble 'A'
			17: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 18; end	
			18: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0001; state_next <= 19; end	//Lower Data Nibble 'A'
			19: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0001; state_next <= 20; end
					//------------------write K------------------------//
			20: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 21; end	//Upper Data Nibble 'K'
			21: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 22; end
			22: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b1011; state_next <= 23; end	//Lower Data Nibble 'K'
			23: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b1011; state_next <= 24; end
					//------------------write S------------------------//
			24: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0101; state_next <= 25; end	//Upper Data Nibble 'S'
			25: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0101; state_next <= 26; end
			26: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0011; state_next <= 27; end	//Lower Data Nibble 'S'
			27: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0011; state_next <= 28; end
					//------------------write H------------------------//
			28: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 29; end	//Upper Data Nibble 'H'
			29: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 30; end
			30: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b1000; state_next <= 31; end	//Lower Data Nibble 'H'
			31: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b1000; state_next <= 32; end
					//------------------write I------------------------//
			32: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 33; end	//Upper Data Nibble 'I'
			33: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 34; end
			34: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b1001; state_next <= 35; end	//Lower Data Nibble 'I'
			35: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b1001; state_next <= 36; end
			
					//------------------space-------------------------//
			36: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b1010; state_next <= 37; end	//Upper Data Nibble ' '
			37: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b1010; state_next <= 38; end
			38: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0000; state_next <= 39; end	//Lower Data Nibble ' '
			39: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0000; state_next <= 40; end
			
					//------------------write T------------------------//
			40: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0101; state_next <= 41; end	//Upper Data Nibble 'T'
			41: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0101; state_next <= 42; end
			42: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 43; end	//Lower Data Nibble 'T'
			43: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 44; end
					//------------------write E------------------------//
			44: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 45; end	//Upper Data Nibble 'E'
			45: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 46; end
			46: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0101; state_next <= 47; end	//Lower Data Nibble 'E'
			47: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0101; state_next <= 48; end
					//------------------write C------------------------//
			48: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 49; end	//Upper Data Nibble 'C'
			49: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 50; end
			50: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0011; state_next <= 51; end	//Lower Data Nibble 'C'
			51: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0011; state_next <= 52; end
					//------------------write H------------------------//
			52: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0100; state_next <= 53; end	//Upper Data Nibble 'H'
			53: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0100; state_next <= 54; end
			54: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b1000; state_next <= 55; end	//Lower Data Nibble 'H'
			55: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b1000; state_next <= 56; end
			
					//------------------Next Line-------------------------//
			56: begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b1100; state_next <= 57; end	//Upper Data Nibble
			57: begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b1100; state_next <= 58; end			
			58: begin LCD_RS <= 0; LCD_E <= 1; LCD_DATA <= 4'b0000; state_next <= 59; end //Lower Data Nibble
			59: begin LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000; state_next <= 0; end 
						
//					//------------------write w--------------------------//
//			60: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0111; state_next <= 61; end	//Upper Data Nibble 'w'
//			61: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0111; state_next <= 62; end
//			62: begin LCD_RS <= 1; LCD_E <= 1; LCD_DATA <= 4'b0111; state_next <= 63; end	//Lower Data Nibble 'w'
//			63: begin LCD_RS <= 1; LCD_E <= 0; LCD_DATA <= 4'b0111; state_next <= 0; end
			
			default: begin state_next <= 0; LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000; end
		endcase	
	end
endmodule
