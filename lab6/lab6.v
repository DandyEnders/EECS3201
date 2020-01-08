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

module fulladder(
	input a, b, cin, 
	output s, cout
	);
	/*
	Full adder.
	*/
	assign s = a ^ b ^ cin;
	assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module adder8(
	input [7:0] a, b,
	input cin,
	output [7:0] s,
	output cout
	);
	/*
	8 bits full adder.
	*/
	
	wire [7:1] w;
	
	fulladder f0(cin, a[0], b[0], s[0], w[1]);
	fulladder f1(w[1], a[1], b[1], s[1], w[2]);
	fulladder f2(w[2], a[2], b[2], s[2], w[3]);
	fulladder f3(w[3], a[3], b[3], s[3], w[4]);
	fulladder f4(w[4], a[4], b[4], s[4], w[5]);
	fulladder f5(w[5], a[5], b[5], s[5], w[6]);
	fulladder f6(w[6], a[6], b[6], s[6], w[7]);
	fulladder f7(w[7], a[7], b[7], s[7], cout);
	
endmodule

module bus16mux(
	/*
	Mux for 16bit inputs w0 and w1.
	*/
	input [15:0] w0, w1, 
	input s, 
	output [15:0] f
	);
	assign f = s ? w1 : w0;
endmodule

module multiply8to1(
	input [7:0] A,
	input b,
	output [7:0] s
	);
	/*
	Intermediate product. 8 bits A * one bit b.
	*/

	assign s[0] = A[0] & b;
	assign s[1] = A[1] & b;
	assign s[2] = A[2] & b;
	assign s[3] = A[3] & b;
	assign s[4] = A[4] & b;
	assign s[5] = A[5] & b;
	assign s[6] = A[6] & b;
	assign s[7] = A[7] & b;

endmodule

module multiply8to8(
	input [7:0] A, B,
	output [63:0] s
	);
	/*
	Multiplying 8 bits to 8 bits. 
	Multiply 8 bits A to each digits of B and stores each result in S
	by 8 bits. (A[i*8+7:i*8] * B[i] = S[i*8+7:i*8] where 0 <= i < n)
	*/
	
	genvar i;
	//sum gen
	generate
		for(i=0; i<=7;i=i+1)
			begin: mult
				multiply8to1 ab1(A, B[i], s[i*8+7:i*8]);
			end
	endgenerate
	
endmodule


module add8Serial(
	input [63:0] s,
	output [15:0] res
	);
	/*
	Adding the sum serially.
	
	For each level of partial product sum, we take LSB of the sum as res[i],
	where 0 <= i <= 6, and let the carry out with last partial product be res[15:7].
	*/
	wire [63:8] isum;
	wire [63:8] osum;
	wire [7:1] cout;
	
	
	// s[n][7:1] passed as addition, s[0] as previous(zero start)
	// 0a7a6...a0
	assign isum[15:8] = {1'b0, s[7:1]};
	assign res[0] = s[0];
	
	// first cin = 0
	assign cout[1] = 0;

	genvar i;
	//sum gen
	generate
		for(i=1; i<=6;i=i+1)
			begin: adders
				adder8(isum[i*8+7:i*8], s[i*8+7:i*8], 0, osum[i*8+7:(i)*8], cout[i+1]);
				assign res[i] = osum[i*8];
				assign isum[(i+1)*8+7:(i+1)*8] = {cout[i+1], osum[i*8+7:i*8+1]};
			end
	endgenerate
	
	adder8 ab1(isum[63:56], s[63:56], 0, res[14:7], res[15]);
	
endmodule

module add8Paralell(
	input [63:0] s,
	output [15:0] res
	);
	/*
	Adding sum parallely.
	
	Partial product sum s is PPS(i). 
	PPS(i)= s[i*8+7, i*8] where 0 <= i < 8.
	
	We logical bit shifts PPS(i) i times,
	then adds PPS(i) by groups of two three times.
	*/

	wire [15:0] osum1, osum2, osum3, osum4;
	wire [15:0] osum11, osum12;
	
	assign osum1[15:0] = (s[15:8] << 1) + s[7:0];
	assign osum2[15:0] = (s[31:24] << 3) + (s[23:16] << 2);
	assign osum3[15:0] = (s[47:40] << 5) + (s[39:32] << 4);
	assign osum4[15:0] = (s[63:56] << 7) + (s[55:48] << 6);
	
	assign osum11[15:0] = osum2 + osum1;
	assign osum12[15:0] = osum4 + osum3;
	
	assign res[15:0] = osum12 + osum11;
	
endmodule

module partA(
	input [7:0] A, B,
	output [15:0] res
	);
	/*
	Part A of the lab5.
	It does A * B and return res but addes intermediate sums serially.
	*/
	
	wire [63:0] isum;
	multiply8to8 m88(A, B, isum);
	add8Serial(isum, res);

endmodule

module partB(
	input [7:0] A, B,
	output [15:0] res
	);
	/*
	Part B of the lab5.
	It does A * B and return res but addes intermediate sums parallely.
	*/
	wire [63:0] isum;
	multiply8to8 m88(A, B, isum);
	add8Paralell(isum, res);

endmodule

module lab6(
	input [17:0] SW,
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	input CLOCK_50,
	output [1:0] GPIO_0
	);
	/*
	SW[15:0] for A, B
	SW[17] for switch between partA and B 
	*/
	
	wire [7:0] A, B;
	wire partABswitch;
	wire [15:0] resPartA, resPartB;
	wire [15:0] res/*synthesis keep*/;
	
	assign A = SW[15:8];
	assign B = SW[7:0];
	
	assign partABswitch = SW[17];
	
	// Actual lab
	
	// Get results from part A and B
	partA lab5a(A, B, resPartA);
	partB lab5b(A, B, resPartB);
	
	// MUX it using ABswitch
	bus16mux resMux(resPartA, resPartB, partABswitch, res);
	
	// display A to HEX76, B to HEX54, res to HEX3210.
	twoDigTo7Seg displayA(A, HEX7, HEX6);
	twoDigTo7Seg displayB(B, HEX5, HEX4);
	fourDigTo7Seg displayRes(res, HEX3, HEX2, HEX1, HEX0);
	
	assign GPIO_0[0] = SW[0];
	assign GPIO_0[1] = res[15];
	
endmodule