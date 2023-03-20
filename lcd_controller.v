`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Kishore Bachu	
// Create Date: 06:44:36 02/02/2023 
// Design Name: LCD Controller
// Module Name: lcd_controller.v
// Target Board: SPARTAN-3E FPGA BOARD
// Target Devices: XC3SE
// Tool versions: ISE 14.7
// Description: 
// 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lcd_controller(
				SYS_CLK_50M,		//Global Clock, GCLK10 = 50Mhz
				SYS_RST,				//Active High System Reset, Push BTN SOUTH
				LCD_RS,				//LCD Register select. 0 = Instruction register during write. 1 = Data Regisfor read or write
				LCD_RW,				//LCD Read/Write Control. 0 = Write, LCD accepts data. 1 = Read, LCD presents data
				LCD_E,				//LCD Read/Write Enable Pulse. 0 = Disabled. 1 = Read/Write operation enabled
				LCD_DATA,			//4-bit LCD Data Bus
				SF_OE,				//Strata Flash Chip Enable
				SF_CE,				//Strata Flash Chip Enable
				SF_WE					//Strata Flash Write Enable
    );

	//Input Ports
	input SYS_CLK_50M;
	input SYS_RST;
	
	//Output Ports
	output LCD_RS;
	output LCD_RW;
	output LCD_E;
	output [7:4]LCD_DATA;
	output SF_OE;
	output SF_CE;
	output SF_WE;
	
	//Data Types
	reg LCD_RS;
	reg LCD_E;
	reg [7:4]LCD_DATA;
	
	//Internal Registers
	reg [5:0]state;
	reg [20:0]timer;
	
	assign LCD_RW = 0;	//LCD write access only
	
	//Strata Flash must be disabled to prevent it conflicting with LCD 
	assign SF_OE = 1'b1;
	assign SF_CE = 1'b1;
	assign SF_WE = 1'b1;
	
	//Code begins
	always @ (posedge SYS_CLK_50M or posedge SYS_RST)
	begin
		if (SYS_RST == 1'b1) 
			begin 
				timer <= 0; 
				state <= 0; 
				LCD_E <= 0;
				LCD_RS <= 0;
				LCD_DATA <= 4'b0000;
			end
		else
			begin
				case (state)
					//Spartan-3E Starter kit Board User Guide. UG230 (v1.0)
				
					//--------------------Power-On Initialization------------------//
					0: begin
							LCD_RS <= 0; LCD_E <= 0; LCD_DATA <= 4'b0000;
							if (timer == 750000) 	//Wait 15ms (750000 clock cycles). Set timer = 75 for simulation.
								begin 
									LCD_E <= 1;
									LCD_DATA <= 4'b0011;		//Write 0x3 
									timer <= 0;	state <= state + 1; end
							else	timer <= timer + 1;
						end	//end state 0
					
					1: begin
							if (timer == 12)				//wait 12 clock cycles
								begin 
									LCD_E <= 0; 			//LCD_E Low after 12 clock cycles
									LCD_DATA <= 4'b0000;		//Write 0x0
									timer <= 0; state <= state + 1; 
								end
							else timer <= timer + 1;
						end	//end state 1
					
					2: begin			
							if (timer == 205000)		//wait 4.1ms (timer = 205000). Set timer = 205 for simulation.
								begin 
									LCD_E <= 1;
									LCD_DATA <= 4'b0011;		//Write 0x3
									timer <= 0; state <= state + 1; 
								end
							else	timer <= timer + 1;
						end	//end state 2
					
					3:	begin
							if (timer == 12)			//wait 12 clock cycles	
								begin
									LCD_E <= 0;					//LCD_E Low after 12 clock cycles
									LCD_DATA <= 4'b0000;		//Write 0x0
									timer <= 0; state <= state + 1; 
								end
							else	timer <= timer + 1;
						end	//end state 3
					
					4: begin
							if (timer == 5000)		//wait 100us (timer = 5000). Set timer = 50 for simulation.
								begin
									LCD_E <= 1;
									LCD_DATA <= 4'b0011; 	//Write 0x3
									timer <= 0; state <= state + 1;	
								end
							else	timer <= timer + 1;
						end	//end state 4
							
					5: begin
							if (timer == 12)			//wait 12 clock cycles
								begin 
									LCD_E <= 0; 				//LCD_E Low after 12 clock cycles
									LCD_DATA <= 4'b0000;		//Write 0x0
									timer <= 0;	state <= state + 1; 
								end
							else	timer <= timer + 1;
						end	//end state 5
					
					6: begin
							if (timer == 2000)		//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin	
									LCD_E <= 1;
									LCD_DATA <= 4'b0010;		//Write 0x2
									timer <= 0;	state <= state + 1;	
								end
							else	timer <= timer + 1;
						end	//end state 6
					
					7: begin
							if (timer == 12)			//wait 12 clock cycles
								begin	
									LCD_E <= 0;				//LCD_E Low after 12 clock cycles
									LCD_DATA <= 4'b0000;		//Write 0x0
									timer <= 0; state <= state + 1;	
								end
							else	timer <= timer + 1;
						end	//end state 7
					
					//--------------------Display Configuration (LCD_RS=0)------------------------//
							//-------------------Function set (0x28)---------------------------//
					8:	begin
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin	
									LCD_E <= 1; 
									LCD_DATA <= 4'b0010; //Upper Nibble
									timer <= 0; state <= state + 1; 
								end
							else	timer <= timer + 1;
						end	//end state 8
										
					9: begin
							LCD_E <= 0;				
							if (timer == 50)		//wait 1us
								begin 
									LCD_E <= 1; 
									LCD_DATA <= 4'b1000; //Lower Nibble(10DB1DB0). DB1=0. DB0=0.
									timer <= 0; state <= state + 1; 
								end  
							else	timer <= timer + 1;
						 end	//end state 9
						
						//-----------------Entry Mode Set (0x06)---------------------------//
						
					10: begin
							LCD_E <= 0; 
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin 
									LCD_E <= 1; 
									LCD_DATA <= 4'b0000; //Upper Nibble
									timer <= 0; state <= state + 1; end  
							else	timer <= timer + 1;
						end	//end state 10	
					
					11: begin 
							LCD_E <= 0;
							if (timer == 50) //wait 1us
								begin 
									LCD_E <= 1;
									LCD_DATA <= 4'b0110; //Lower Nibble(01I/DS). I/D=1. S=0.
									timer <= 0; state <= state + 1; 
								end
							else timer <= timer + 1;
						 end	//end state 11
					
						//-----------------Display On/Off (0x0C)---------------------------//
						
					12: begin
							LCD_E <= 0;		
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin 
									LCD_E <= 1;
									LCD_DATA <= 4'b0000; //Upper Nibble
									timer <= 0;  timer <= 0; state <= state + 1; 
								end  
							else	timer <= timer + 1;
						 end	//end state 12
		
					13: begin
							LCD_E <= 0; 
							if (timer == 50)	//wait 1us
								begin	
									LCD_E <= 1;
									LCD_DATA <= 4'b1100; //Lower Nibble(1DCB). D=1. C=0. B=0.
									timer <= 0; state <= state + 1; end  
							else	timer <= timer + 1;
						 end	//end state 13	
						
						//------------------Clear Display (0x01)--------------------------//
						
					14: begin 
							LCD_E <= 0;  
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin 
									LCD_E <= 1; 
									LCD_DATA <= 4'b0000; //Upper Nibble
									timer <= 0; state <= state + 1; end
							else timer <= timer + 1;
						 end	//end state 14
					
					15: begin
							LCD_E <= 0;					
							if (timer == 50)		//wait 1us
								begin 
									LCD_E <= 1; 
									LCD_DATA <= 4'b0001; //Lower Nibble
									timer <= 0; state <= state + 1; end  
							else	timer <= timer + 1;
						 end	//end state 15		
						
			//Spartan-3E Starter kit Board User Guide. UG230 (v1.0)
			//Figure 5-4: LCD Character Set
			
					//------------------Set DD RAM address (0x80)------------------------//	
					16: begin 
							LCD_E <= 0; 
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin
									LCD_E <= 1; 
									LCD_DATA <= 4'b1000; //Upper Nibble
									timer <= 0; state <= state + 1;
								end
							else timer <= timer + 1;
						end	//end state 16
				
					17: begin
							LCD_E <= 0;				
							if (timer == 50)		//wait 1us
								begin 
									LCD_E <= 1; 
									LCD_DATA <= 4'b0000; //Lower Nibble
									timer <= 0; state <= state + 1; 
								end  
							else	timer <= timer + 1;
						 end	//end state 17	
			
			 //-----------------Writing Data to the Display (LCD_RS=1)-------------------//
					//------------------write A------------------------//		
					18: begin 
							LCD_E <= 0;
							if (timer == 2000)	//wait 40us (timer = 2000). Set timer = 20 for simulation.
								begin
									LCD_RS <= 1; LCD_E <= 1;
									LCD_DATA <= 4'b0100; //Upper Nibble 'A'
									timer <= 0; state <= state + 1; 
								end
							else timer <= timer + 1;
						 end	//end state 18
					
					19: begin
							LCD_E <= 0;				
							if (timer == 50)		//wait 1us
								begin timer <= 0; LCD_E <= 1; LCD_DATA <= 4'b0001; state <= 0; end  //Lower Nibble 'A'
							else	timer <= timer + 1;
						 end	//end state 19		
					
				endcase	
			end	//end else
	end	//end always
endmodule
