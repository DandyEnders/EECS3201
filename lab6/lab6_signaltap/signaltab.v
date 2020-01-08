module signaltabFIRST(
	input [7:0] SW,
	input CLOCK_50,
	output reg [7:0] LEDR
	);
	
	always @ (posedge CLOCK_50)
		LEDR [7:0] <= SW [7:0];
	
endmodule 

module signaltab(
	input [2:0] SW,
	input CLOCK_50,
	output reg [0:0] LEDR
	);
	
	wire ab, abc /*synthesis keep*/;
	assign ab = SW[0] & SW[1];
	assign abc = ab & SW[2];
	
	always @ (posedge CLOCK_50)
	begin
		LEDR[0] <= abc;
	end
	
endmodule 