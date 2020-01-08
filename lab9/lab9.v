/*
Author: Jinho Hwang
*/

module secCounter(
	input clk, En, reset,
	output reg [31:0] seconds
	);
	/*
	Clock frequency time counter.
	Default setting is every 50M clock, a seconds is increased.
	Seconds are default to be 32bit binary number.
	
	Every clock cycle we add 1 to clkCount.
	If clkCount = freq, we reset clkCount to be 0 and add 1 seconds.
	*/
	parameter freq = 50000000;
	integer clkCount = 0;

	
	always@(posedge reset, posedge clk)
	begin
		if (reset)
		begin
			clkCount = 0;
			seconds = 0;
		end
		else if (En)
		begin
			if (clkCount == freq)
			begin
				seconds = seconds + 1;
				clkCount = 0;
			end
			else
				clkCount = clkCount + 1;
		end
	end
endmodule

module fireSecDelay(
	input clk,
	input fire,
	input [31:0] delay,
	output reg pulseActive
	);
	/*
	Clock frequency delay pulser.
	This module enables(fires) counter and wait until delay (in seconds)
	and sends a pulse as pulseActive.
	*/
	parameter freq = 50000000;
	
	reg reset = 0;
	wire [31:0] seconds;
	
	secCounter #(.freq(freq)) sc (clk, fire, reset, seconds);
	
	// when counting seconds == delay, we reset with a pulse active = 1
	always@(posedge clk)
	begin
		if(seconds < delay | pulseActive == 1)
			begin
				reset = 0;
				pulseActive = 0;
			end
		else if (seconds >= delay | delay == 0)
		begin
			reset = 1;
			pulseActive = 1;
		end
	end
	
endmodule

module lab9(
	input [3:0] KEY,
	input [17:0] SW,
	input CLOCK_50,
	output [0:0] GPIO_0, 
	output [17:0] LEDR,
	output [7:0] LEDG
	);
	/*
	Lab 9.
	Realization of traffic signal lights in the intersection with main highway
	and secondary road with pedestrian crossing.
	*/
	
	// Variables, wires, input / output related
	//-----------------------------------------------------------------
	// timings
	parameter t_green = 6;
	parameter t_yellow = t_green / 2; // integer div. $floor(t_green / 2)
	
	// requests, things we can change
	wire r_pedestrian = ~KEY[3]; // 0 is active. so make active ~0 = 1.
	wire r_secondary = SW[0];
	
	wire reset = ~KEY[0];
	wire clk = CLOCK_50;
	
	// red, yellow, green lights
	reg [3:1] light_highway, light_secondroad, light_pedestrian;
	assign {LEDR[8], LEDR[10], LEDG[4]} = light_highway;
	assign {LEDR[4], LEDR[6], LEDG[2]} = light_secondroad;
	assign {LEDR[0], LEDR[2], LEDG[0]} = light_pedestrian;
	
	// states, current states.
	reg s_pedestrian_request = 0;
	reg s_secondary_request = 0;
	reg [2:1] s_last_request_order = S_NO_REQUEST;
	
	// y = s_current, Y = s_next
	reg [4:1] s_current = S_HWY_GL, 
				 s_next = S_HWY_GL;
				 
	reg [31:0] delay = 0;
	reg fire = 0;
	wire delayTrigger;
	
	fireSecDelay #(.freq(50000000)) fsc(clk, fire, delay, delayTrigger);
	
	
	// Enumerations
	//-----------------------------------------------------------------
	// current state
	// format : (S)tate_(place)_(light type)
	// ex: S_HWY_GL = State Highway Green Light
	parameter [4:1] 
	 S_HWY_GL = 0,
	 S_HWY_YL = 1,
	 
	 S_PED_GL = 2,
	 S_PED_YL = 3,
	 
	 S_SEC_GL = 4,
	 S_SEC_GL_MAX = 5,
	 S_SEC_YL = 6;
	
	// previous request
	parameter [2:1] 
	 S_NO_REQUEST = 2'b00,
	 S_PEDESTRIAN_FIRST = 2'b10,
	 S_SECONDARY_ROAD_FIRST = 2'b01;
	
	// light
	parameter [3:1] 
	 L_RED = 3'b100, 
	 L_YELLOW = 3'b010,
	 L_GREEN = 3'b001;
	
	
	// Time setting
	//-----------------------------------------------------------------
	parameter minGreenTime_HWY = t_green;
	// parameter maxGreenTime_HWY = infinity;
		
	parameter minGreenTime_SECONDARY = t_yellow;
	//parameter maxGreenTime_SECONDARY = t_green; t_yellow twice
	
	parameter maxGreenTime_PED = t_green;
	// parameter minGreenTime_PED = t_yellow;
	
	
	// Debug
	//-----------------------------------------------------------------

	// good for request indication
	assign LEDR[17] = s_secondary_request;
	assign LEDR[16] = s_pedestrian_request;
	
	assign GPIO_0[0] = LEDR[10];
	
	
	// Sequencial circuit
	//-----------------------------------------------------------------		
	// if reset triggers, go back to reset.
	// the pulseActive output will trigger current state to change. 
	always@(posedge reset, posedge delayTrigger)
	begin
		if(reset) 
			s_current <= S_HWY_GL;
		else if (delayTrigger) 
			s_current <= s_next;
	end
	
	// if s_next changes, fire the timer.
	always@(s_next)
	begin
		if(s_next != s_current)
			fire = 1;
		else
			fire = 0;
	end
	
	always@(posedge clk)
	begin
	// request and initialization of s_last_request_order. 
	/*
	if pedestrian makes a request, turn s_pedestrian_request to 1. 
	if no request was made previously, indicate pedestrian ordered first now.
	*/
	if(r_pedestrian)
	begin
		s_pedestrian_request = 1;
		if (s_last_request_order == S_NO_REQUEST)
			s_last_request_order = S_PEDESTRIAN_FIRST;
	end
	/*
	if car on secondary road makes a request, turn s_secondary_request to 1 .
	if no request was made previously, indicate car on secondary road ordered 
	first now.
	*/
	if(r_secondary)
	begin
		s_secondary_request = 1;
		if (s_last_request_order == S_NO_REQUEST)
			s_last_request_order = S_SECONDARY_ROAD_FIRST;
	end
	
	// current state processing
	//-----------------------------------------------------------------
	if(s_current == s_next)
	case(s_current)
	// Highway states
	S_HWY_GL:begin
		// light changes
		light_highway <= L_GREEN; 
		light_secondroad <= L_RED;
		light_pedestrian <= L_RED;
		
		delay <= minGreenTime_HWY;
		// wait until predestrian or secondary road request comes in.
		// when s_next changes, counter starts, and the counter counts 
		// until "delay" seconds. 
		// once seconds count == delay, c_current goes to s_next state.
		if(s_pedestrian_request | s_secondary_request)
			s_next <= S_HWY_YL;
			
		end
	S_HWY_YL:begin
		light_highway <= L_YELLOW;
		
		delay <= t_yellow;
		// when both requests are up, process the opposite of previous start
		if (s_secondary_request & s_pedestrian_request)
		begin
			if(s_last_request_order == S_PEDESTRIAN_FIRST)
			begin
				s_secondary_request <= 0;
				s_last_request_order <= S_SECONDARY_ROAD_FIRST;
				s_next <= S_SEC_GL;
			end
			else // if (s_last_request_order == S_SECONDARY_ROAD_FIRST)
			begin
				s_pedestrian_request <= 0;
				s_last_request_order <= S_PEDESTRIAN_FIRST;
				s_next <=  S_PED_GL;
			end
		end
		// when secondary request alone is up, process it
		else if(s_secondary_request)
		begin
			s_secondary_request <= 0;
			s_last_request_order <= S_SECONDARY_ROAD_FIRST;
			s_next <= S_SEC_GL;
		end
		// when pedestrian request alone is up, process it
		else // if(s_pedestrian_request)
		begin
			s_pedestrian_request <= 0;
			s_last_request_order <= S_PEDESTRIAN_FIRST;
			s_next <=  S_PED_GL;
		end
		
		end


	// Pedestrian states
	S_PED_GL:begin
		light_highway <= L_RED; 
		light_secondroad <= L_RED;
		light_pedestrian <= L_GREEN;
		
		delay <= maxGreenTime_PED;
		s_next <= S_PED_YL;
		end
	S_PED_YL:begin
		light_pedestrian <= L_YELLOW;
		
		delay <= t_yellow;
		s_next <= S_HWY_GL;
		end

	// Secondary road states
	S_SEC_GL:begin
		light_highway <= L_RED; 
		light_secondroad <= L_GREEN;
		light_pedestrian <= L_RED;
		
		delay <= minGreenTime_SECONDARY;
		s_next <= S_SEC_GL_MAX;
		end
	S_SEC_GL_MAX:begin
		if (s_secondary_request)
		begin
			s_secondary_request <= 0;
			delay <= minGreenTime_SECONDARY;
		end
		else
			delay <= 0;
		s_next <= S_SEC_YL;
		end
	S_SEC_YL:begin
		light_secondroad <= L_YELLOW;
		
		delay <= t_yellow;
		s_next <= S_HWY_GL;
		end
	endcase
	end
	
endmodule