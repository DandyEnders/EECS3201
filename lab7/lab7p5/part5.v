module CPDLatch(
	input Clk, D,
	output Q,
	input preset, clear
	);
	// Clear-preset D Latch
	
	wire R, S, R_g, S_g, Qa, Qb;
	
	assign S = D;
	assign R = ~D;
	
	assign R_g = ~(R & Clk);
	assign S_g = ~(S & Clk);
	assign Qa = ~(S_g & Qb & preset);
	assign Qb = ~(R_g & Qa & clear);
	
	assign Q = Qa;
endmodule

module CPMSDFlipFlop(
	input Clock, D,
	output Q,
	input preset, clear
	);
	// Clear-preset Master Slave D Flip Flop
	wire Qm;
	
	CPDLatch master(~Clock, D, Qm, preset, clear);
	CPDLatch slave(Clock, Qm, Q, preset, clear);
	
endmodule


module part5(
	input Clock,
	input [15:0] D,
	input ABswitch,
	input asyncReset,
	output [15:0] Qa, Qb
	);
	wire Aclock, Bclock;
	
	assign Aclock = ~ABswitch ? Clock : 1'b1;
	assign Bclock = ~ABswitch ? 1'b1 : Clock;
	
	CPMSDFlipFlop ffA[15:0](Aclock, D, Qa, 1'b1, asyncReset);
	CPMSDFlipFlop ffB[15:0](Bclock, D, Qb, 1'b1, asyncReset);

endmodule