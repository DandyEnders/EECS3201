module part2(
	input Clk, D,
	output Q
);
	
	wire R, S, R_g, S_g, Qa, Qb /*synthesis keep*/;
	
	assign S = D;
	assign R = ~D;
	
	assign R_g = ~(R & Clk);
	assign S_g = ~(S & Clk);
	assign Qa = ~(S_g & Qb);
	assign Qb = ~(R_g & Qa);
	
	assign Q = Qa;

endmodule