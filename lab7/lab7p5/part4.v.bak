module part3(
	input Clock, D,
	output Q
);
	wire Qm;
	
	part2 master(~Clock, D, Qm);
	part2 slave(Clock, Qm, Q);
	

endmodule