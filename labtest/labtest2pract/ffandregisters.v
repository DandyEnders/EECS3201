module gatedSRlatch(
	input s, r, clk, clear, preset,
	output reg q, qb
);

always@(clk, clear, preset)
begin
	if(clear == 0)
		{q, qb} = 2'b01;
	else if(preset == 0)
		{q, qb} = 2'b10;
	else if(clk)
		if(s)
			{q, qb} = 2'b10;
		else if(r)
			{q, qb} = 2'b01;
end

endmodule

module ddlatch(
	input d, clk, clear, preset,
	output q, qb
);

	wire s = d;
	wire r = ~d;
	gatedSRlatch lat(s, r, clk, clear, preset, q, qb);

endmodule

module PosEmsff(
	input d, clk, clear, preset,
	output q, qb
);
	
	wire qm, _;

	ddlatch master	(d, ~clk, clear, preset, qm, _);
	ddlatch slave	(qm, clk, clear, preset, q, qb);

endmodule

module MyTff(
	input t, clk, clear, preset,
	output q, qb
);

	wire J = t;
	wire K = ~t;
	
	wire d = (J & qb) | (K & q);
	PosEmsff ff (d, clk, clear, preset, q, qb);
endmodule


module PosEff(
	input d, clk, clear, preset,
	output reg q, qb
);

always@(posedge clk, negedge clear, negedge preset)
begin
	if(clear == 0)
		{q, qb} = 2'b01;
	else if (preset == 0)
		{q, qb} = 2'b10;
	else if (clk)
		{q, qb} = {d, ~d};
end
endmodule

module myRegN(
	input [n-1:0] D, 
	input clk, clear, preset,
	output reg [n-1:0] Q
);
parameter n = 8;

always@(posedge clk, negedge clear, negedge preset)
begin
	if(!clear)
		Q <= 0;
	else if(!preset)
		Q <= ~0;
	else
		Q <= D;
end


endmodule

module muxdff(
	input [1:2] D,
	input sel, clk,
	output reg q
);
	wire d = sel ? D[1] : D[2];

	always@(posedge clk)
		q <= d;

endmodule

// registers
//-----------------------------------------------------------

module myShiftReg(
	input in, clk, clear, preset,
	output [1:n] Q
);
	parameter n = 8;
	
	wire [0:n] inQ;
	
	assign inQ = {in, Q};
	
	genvar i;
	generate
		for (i = 1; i <= n; i = i + 1)
		begin: myshifter
			PosEff ff(inQ[i-1], clk, clear, preset, Q[i]);
		end
	endgenerate


endmodule

module myShiftParLoadReg(
	input serialIn,
	input [n-1:0] parallelIn,
	input clk, clear, preset, 
	input [1:0] shiftLoad,
	output reg [n-1:0] Q
);
	parameter n = 8;
	
	always@(posedge clk, negedge clear, negedge preset)
	begin
		if(!clear)
			Q <= 0;
		else if(!preset)
			Q <= ~0;
		else
			case(shiftLoad)
				0: Q <= Q;
				1:	Q <= {serialIn, Q[n-1:1]};
				2:	Q <= {Q[n-2:0], serialIn};
				3: Q <= parallelIn;
			endcase
	end


endmodule


module upCounter(
	input enable, clk, reset,
	output reg [n-1:0] Q
);	
	parameter n = 16;
	
	always@(posedge clk, negedge reset) begin
		if(!reset)
			Q <= 0;
		else if(enable)
			Q <= Q + 1;
	end
	

endmodule

module updownCounter(
	input enable, clk, reset, updown,
	output reg [n-1:0] Q
);	
	parameter n = 16;
	
	always@(posedge clk, negedge reset) begin
		if(!reset)
			Q <= 0;
		else if(enable)
			Q <= Q + (updown ? 1 : -1);
	end
endmodule

module AsyncCounter(
	input enable, clk, clear, preset,
	output [n-1:0] Q
);
	parameter n = 8;
	
	//module Tff(input t, clk, clear, preset, output q, qb

	wire [n:0] Qb;
	
	assign Qb[0] = clk;

	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: myTffcount
			MyTff myff(enable, Qb[i], clear, preset, Q[i], Qb[i+1]);
		end
	endgenerate
endmodule

module SyncCounter(
	input enable, clk, clear, preset,
	output [n-1:0] Q
);
	parameter n = 8;
	
	wire [n:0] T;
	assign T[0] = enable;

	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: myTffSyncCount
			wire _;
			MyTff myff(T[i], clk, clear, preset, Q[i], _);
			assign T[i+1] = Q[i] & T[i];
		end
	endgenerate
	

endmodule

module SyncDCounter(
	input enable, clk, clear, preset,
	output [n-1:0] Q
);
	parameter n = 8;

	wire [n:0] D, In;
	assign In[0] = enable;

	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: myDffSyncCount
			assign D[i] = In[i] ^ Q[i];
			PosEmsff mydff(D[i], clk, clear, preset, Q[i], _);
			assign In[i+1] = In[i] & Q[i];
		end
	endgenerate
	

endmodule

module SyncDLoadCounter(
	input enable, clk, clear, preset,
	input [n-1:0] parallelIn, load,
	output [n-1:0] Q
);
	parameter n = 8;

	wire [n:0] D, In;
	assign In[0] = enable;

	genvar i;
	generate
		for(i = 0; i < n; i = i + 1)
		begin: myDffSyncCount
			assign D[i] = load ? parallelIn[i] : In[i] ^ Q[i];
			PosEmsff mydff(D[i], clk, clear, preset, Q[i], _);
			assign In[i+1] = In[i] & Q[i];
		end
	endgenerate
endmodule