module part4(
	input Clock, D,
	output reg Qa, Qb, Qc
);
	
	always@(Clock)
		if (Clock == 1) 
			Qa = D;
	
	always@(posedge Clock) Qb = D;
	
	always@(negedge Clock) Qc = D;

endmodule