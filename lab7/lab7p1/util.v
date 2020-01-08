/*
	Author: Jinho Hwang
*/

module sevenSeg(
	input [3:0] hex,
	output reg [0:6] led
	);
	/*
	From lecture slide Combination Building Blocks Pg 52 
	with modification on 0 being LED on.
	
	Takes 4bit binary vector hex to decode as 7 segment display
	*/
	
	always @(hex)
		case(hex)
			0: led = 7'b0000001;
			1: led = 7'b1001111;
			2: led = 7'b0010010;
			3: led = 7'b0000110;
			4: led = 7'b1001100;
			5: led = 7'b0100100;
			6: led = 7'b0100000;
			7: led = 7'b0001111;
			8: led = 7'b0000000;
			9: led = 7'b0000100;
			10: led = 7'b0001000;
			11: led = 7'b1100000;
			12: led = 7'b0110001;
			13: led = 7'b1000010;
			14: led = 7'b0110000;
			15: led = 7'b0111000;
		endcase
endmodule

module twoDigTo7Seg(
	input [7:0] D,
	output [0:6] ledBig, ledSmall
	);
	/*
	sevenSeg for two sets of 4bit binary vectors.
	*/
	sevenSeg DBig(D[7:4], ledBig);
	sevenSeg DSmall(D[3:0], ledSmall);
endmodule

module fourDigTo7Seg(
	input [15:0] D,
	output [0:6] ledBig, ledLessBig, ledLessSmall, ledSmall
	);
	/*
	sevenSeg for four sets of 4bit binary vectors.
	*/
	twoDigTo7Seg(D[15:8], ledBig, ledLessBig);
	twoDigTo7Seg(D[7:0], ledLessSmall, ledSmall);
endmodule