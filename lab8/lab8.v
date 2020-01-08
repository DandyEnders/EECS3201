/*
Author: Jinho Hwang
*/

module SRGatedLatch(
	input s, r, clk,
	output Q, Qb
	);
	
	wire s_w, r_w;
	
	assign s_w = ~(s & clk);
	assign r_w = ~(r & clk);
	assign Q = ~(s_w & Qb);
	assign Qb = ~(r_w & Q);
endmodule

module myDLatch(
	input D, clk,
	output Q, Qb
	);
	
	wire s, r;
	
	assign s = D;
	assign r = ~D;
	
	SRGatedLatch latch(s, r, clk, Q, Qb);
endmodule

module MasterSlaveDPosEdgeFlipFlop(
	input D, clk,
	output Q, Qb
	);
	
	wire Q_m, _;
	myDLatch master(D, ~clk, Q_m, _);
	myDLatch slave(Q_m, clk, Q, Qb);
endmodule

/*
module TFlipFlop(
	input T, clk,
	output Q, Qb
	);
	
	wire D;
	
	assign D = (~T & Q) | (T & Qb);
	
	MasterSlaveDPosEdgeFlipFlop ff (D, clk, Q, Qb);
endmodule
*/

module TFlipFlop(
	input T, clk,
	output reg Q, Qb
	);
	
	always @ (posedge clk)
		if(T == 1)
		begin
			Q <= ~Q;
			Qb <= Q;
		end

endmodule

module AsyncCounterT(
	input En, clk,
	output [n-1:0] Q
	);
	parameter n = 4;
	wire [0:n] QbClk;
	assign QbClk[0] = clk;
	
	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: TFF
			TFlipFlop ff(En, QbClk[i], Q[i], QbClk[i+1]);
		end
	endgenerate
endmodule

module AsyncCounterTRTL(
	input En, clk,
	output reg [n-1:0] Q
	);
	parameter n = 4;
	
	always@(posedge clk)
	begin
		if(En == 1)
			Q = Q + 1;
	end
endmodule

module AsyncCounterTLPM(
	input En, clk,
	output reg [n-1:0] Q
	);
	parameter n = 4;
	
	lpm_counter counter(.q(Q), .clock(clk), .cnt_en(En));
	defparam counter.lpm_width = n;
endmodule

module LFSR(
	input clock,
	input asyncPreset, shiftLoad,
	input [n-1:0] parallelIn,
	output reg [n-1:0] Q
	);
	parameter n = 5;
	integer i;
	
	always @(negedge asyncPreset, posedge clock)
	begin
		if(asyncPreset == 0)
			Q <= ~0;
		else // clock == 1
			begin
				if(shiftLoad == 0)
					begin
						Q[0] <= Q[1] ^ Q[n-1];
						for(i = 0; i < n-1; i = i + 1)
							Q[i+1] <= Q[i];
					end
				else // shiftLoad == 1
					begin
						Q <= parallelIn;
					end
			end
	end
	
endmodule

module SyncCounter(
	input En, Clock,
	output [n-1:0] Q, z
	);
	parameter n = 4;
	
	wire [n:0] T;
	
	assign T[0] = En;
	
	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: syncc
			TFlipFlop(T[i], Clock, Q[i]);
			assign T[i+1] = (Q[i] & T[i]);
		end
	endgenerate
	
	assign z = T[n];
	
endmodule

module lab8(
	input [3:0] KEY,
	input [17:0] SW,
	input CLOCK_50,
	output [17:0] LEDR,
	output [1:0] LEDG,
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	wire clk;
	wire [2:0] En;
	
	assign clk = CLOCK_50;
	assign En = SW[2:0]; 
	
	//AsyncCounterT t (En[0], clk, LEDR[3:0]);
	//AsyncCounterTRTL trtl (En[1], clk, LEDR[7:4]);
	//AsyncCounterTLPM tlpm (En[2], clk, LEDR[11:8]);
	
	wire [7:0] Q;
	wire z;
	wire z2 /*synthesis keep*/;
	
	SyncCounter #(.n(4)) scf1(En[0], clk, Q[3:0], z);
	SyncCounter #(.n(4)) scf2(En[0], z, Q[7:4], z2);
	
	assign LEDR[7:0] = Q[7:0];
	
	LFSR lfsr(KEY[1], KEY[0], SW[17], SW[16:12], LEDR[16:12]);
	
	
endmodule