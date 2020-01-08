/*
Author: Jinho Hwang
*/
module lt2(
	input [3:0] KEY,
	input [17:0] SW,
	input CLOCK_50,
	output [17:0] LEDR,
	output [7:0] LEDG,
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	wire clear, preset, clk;
	assign {clear, preset, clk} = KEY[2:0];
	
	/*
	wire d;
	assign d = SW[0];
	
	wire [1:0] q, qb;
	assign LEDR[3:0] = {q, qb};
	
	PosEmsff	msff	(d, clk, clear, preset, q[0], qb[0]);
	PosEff 	dff	(d, clk, clear, preset, q[1], qb[1]);
	//--
	myRegN r1(SW[7:0], clk, clear, preset, LEDR[7:0]);
	//--
	muxdff(SW[1:0], SW[2], KEY[0], LEDR[0]);
	//--
	myShiftReg(SW[0], clk, clear, preset, LEDR[7:0]);
	assign LEDR[8] = SW[0];
	//--
	myShiftParLoadReg myreg(SW[8], SW[7:0], clk, clear, preset, SW[17:16], LEDR[7:0]);
	assign LEDR[8] = SW[8];
	//--
	wire [15:0] _;
	upCounter #(.n(32)) myc(SW[0], CLOCK_50, KEY[0], {LEDR[15:0], _});
	//--
	wire [15:0] _;
	updownCounter #(.n(32)) myc(SW[0], CLOCK_50, KEY[0], SW[1], {LEDR[15:0], _});
	//--
	AsyncCounter mycc(SW[0], clk, clear, preset,LEDR[7:0]);
	//--
	SyncCounter mycc(SW[0], clk, clear, preset,LEDR[7:0]);
	//--
	SyncDLoadCounter mycc(SW[0], clk, clear, preset, SW[8:1], SW[17], LEDR[7:0]);
	//--
	*/
	wire [7:0] Q;
	SyncDLoadCounter mycc(SW[0], clk, clear, preset, 0, (Q == 5), Q);
	assign LEDR[7:0] = Q;
	
endmodule