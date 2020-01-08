module mux2to1 (
	input w0, w1, s,
	output reg f
	);
	
	always @(w0, w1, s)
	begin
		f = s ? w1 : w0;
	end
endmodule

module mux4to1 (
	input [0:3] w,
	input [1:0] s,
	output reg f
	);
	
	always @(w0, w1, s)
	begin
		f = s[1] ? (s[0] ? w[3] : w[2]) : (s[0] ? w[1] : w[0])
	end
endmodule

module mux2to1if (
	input w0, w1, s,
	output reg f
	);
	
	always @(w0, w1, s)
	begin
		if(s == 0)
			f = w0;
		else
			f = w1;
	end
endmodule

module mux4to1if (
	input [0:3] w,
	input [1:0] s,
	output reg f
	);
	
	always @(*)
	begin
		if (s == 2'b00)
			f = w[0];
		else if (s == 2'b01)
			f = w[1];
		else if (s == 2'b10)
			f = w[2];
		else
			f = w[3];
	end
endmodule

module mux16to1 (
	input [0:15] w,
	input [3:0] s,
	output f
	);
	wire [0:3] m;
	
	mux4to1 mux1(w[0:3], s[1:0], m[0]);
	mux4to1 mux2(w[4:7], s[1:0], m[1]);
	mux4to1 mux3(w[8:11], s[1:0], m[2]);
	mux4to1 mux4(w[12:15], s[1:0], m[3]);
	
	mux4to1 mux11(m[0:3], s[3:2], f);
endmodule

module mux4to1case(
	input [0:3] w,
	input [1:0] s,
	output f
	);
	
	always @(w, s)
		case (S)
			0: f = w[0];
			1: f = w[1];
			2: f = w[2];
			3: f = w[3];
		endcase
endmodule

module dec2to4(
	input [1:0] W,
	input En,
	output reg [0:3] Y
	);
	
	always @(W, En)
		case({En, W})
			3'b100: Y = 4'b1000;
			3'b101: Y = 4'b0100;
			3'b110: Y = 4'b0010;
			3'b111: Y = 4'b0001;
			default: Y = 4'b0000;
		endcase
endmodule

module dec2to4if(
	input [1:0] W,
	input En,
	output reg [0:3] Y
	);
	
	always @(W, En)
		if (En == 0)
			Y = 4'b0000;
		else
			case(W)
				0: Y = 4'b1000;
				1: Y = 4'b0100;
				2: Y = 4'b0010;
				3: Y = 4'b0001;
			endcase
endmodule

module dec4to16 (
	input [3:0] W,
	input En,
	output [0:15] Y
	);
	wire [0:3] M;
	
	dec2to4 leftDec(W[3:2], En, M);
	
	dec2to4 dec1(W[1:0], En, Y[0:3]);
	dec2to4 dec2(W[1:0], En, Y[4:7]);
	dec2to4 dec3(W[1:0], En, Y[8:11]);
	dec2to4 dec4(W[1:0], En, Y[12:15]);
	
endmodule

module labtestpract(
	input x, y
	);
	
endmodule