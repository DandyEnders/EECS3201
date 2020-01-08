/*
Author: Jinho Hwang
*/


module lab7(
	input [0:0] KEY,
	input [15:0] SW,
	output [17:0] LEDR,
	output [7:1] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	//sevenSeg(SW[3:0], HEX7);
	
	
	
	wire Clk, R, S, Q;
	assign {Clk, R, S} = SW[2:0];
	assign LEDR[0] = Q;
	
	part1(Clk, R, S, Q);
	
	
	/*
	wire Clk, D, Q;
	
	assign D = SW[0];
	assign Clk = SW[1];
	
	assign LEDR = {18'b0, Clk, Q};
	part2(Clk, D, Q);
	*/
	

endmodule