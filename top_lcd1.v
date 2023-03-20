`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AKSHI TECHNOLOGIES PVT LTD.
// Engineer: KISHORE BACHU
// 
// Create Date:  11:42:57 02/01/2023 
// Design Name: 
// Module Name:  LCD TOP MODULE 
// Project Name: SPARTAN-3E FPGA BOARD
// Target Devices: XC3SE
// Tool versions: ISE 14.7

// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// Title: Main Entity
//	
//	Inputs: 	4	: SYS_CLK_50M, SYS_RST
//	Outputs: 6	: LCD_RS, LCD_RW, LCD_E, LCD_DATA, LCD_N, LCD_P
//	Description	:
//		Display "AKSHI TECH" on LCD
//
//////////////////////////////////////////////////////////////////////////////////
module top_lcd1(
			SYS_CLK_50M,		//Global Clock, GCLK10 = 50Mhz
			SYS_RST,				//Active High System Reset, Push BTN SOUTH
			LCD_RS,				//LCD Register select. 0 = Instruction register during write. 1 = Data Regisfor read or write
			LCD_RW,				//LCD Read/Write Control. 0 = Write, LCD accepts data. 1 = Read, LCD presents data
			LCD_E,				//LCD Read/Write Enable Pulse. 0 = Disabled. 1 = Read/Write operation enabled
			LCD_DATA,			//4-bit LCD Data Bus
			LCD_N,
			LCD_P
    );

	//Input Ports
	input SYS_CLK_50M;
	input SYS_RST;
	
	//Output Ports
	output LCD_RS;
	output LCD_RW;
	output LCD_E;
	output [7:4]LCD_DATA;
	output LCD_N;
	output LCD_P;
	
	//lcd_slow_clk module instantiation
	//Generates a Slow Clock of 1Hz freq.
	lcd_slow_clk u3 (
					.SYS_CLK_50M(SYS_CLK_50M),
					.SYS_RST(SYS_RST),
					.SLOW_CLK(SLOW_CLK)
				);
	
	//lcd_controller module instantiation
	lcd_controller u4 (
					.SLOW_CLK(SLOW_CLK),
					.SYS_RST(SYS_RST),
					.LCD_RS(LCD_RS),
					.LCD_RW(LCD_RW),
					.LCD_E(LCD_E),
					.LCD_DATA(LCD_DATA),
					.LCD_N(LCD_N),
					.LCD_P(LCD_P)
				);

endmodule
