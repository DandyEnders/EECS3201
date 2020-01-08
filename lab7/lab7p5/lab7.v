/*
Author: Jinho Hwang
*/
/*
	wire Clk, R, S, Q;
	assign {Clk, R, S} = SW[2:0];
	assign LEDR[0] = Q
	
	part1(Clk, R, S, Q);
	*/
	
	/*
	wire Clk, D, Q;
	
	assign D = SW[0];
	assign Clk = SW[1];
	
	assign LEDR = {18'b0, Clk, Q};
	part2(Clk, D, Q);
	*/
	
	/*
	wire Clk, D, Q;
	
	assign D = SW[0];
	assign Clk = SW[1];
	
	assign LEDR = {18'b0, Clk, Q};
	part3(Clk, D, Q);
	*/
	
	/*
	wire Clk, D, Qa, Qb, Qc;
	
	assign D = SW[0];
	assign Clk = SW[1];
	
	assign LEDR = {18'b0, Clk, Qa, Qb, Qc};
	
	part4(Clk, D, Qa, Qb, Qc);
*/

module lab7(
	input [1:0] KEY,
	input [17:0] SW,
	output [17:0] LEDR,
	output [1:0] LEDG,
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	/*
		D = Data = SW[15:0]
		Qa = Q output for A
		Qb = Q output for B
		
	*/
	
	wire [15:0] D, Qa, Qb;
	wire ABswitch;
	wire asyncReset, clock;
	
	assign D = SW[15:0];
	
	// to check if button is pressed
	assign LEDG[1:0] = KEY[1:0]; 
	
	// A to B selector (address selector)
	// ABswitch 0 = A, 1 = B.
	assign ABswitch = SW[17];
	
	// asyncReset = 0 resets all register
	assign asyncReset = KEY[0];
	
	// clock = 0 active
	assign clock = KEY[1];
	
	part5(clock, D, ABswitch, asyncReset, Qa, Qb);
	
	fourDigTo7Seg(Qa, HEX7, HEX6, HEX5, HEX4);
	fourDigTo7Seg(Qb, HEX3, HEX2, HEX1, HEX0);

endmodule