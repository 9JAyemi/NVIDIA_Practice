//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,            // Reset

	// Datapath Inputs
	output reg    count_ns,
	output reg 	  rst_i,
	output reg	  m1,
	output reg	  m2,
	output reg	  m3,
	output reg	  m4,
	output reg 	  count_i,
	output reg 	  reset,

	// Datapath Control Outputs
	input     right_guess,
	input	  i_eq_ns,
	input	  legal,

	// External Outputs
	output reg [2:0] mode_leds
);

	// Declare Local Vars Here
	reg [1:0] state;
	reg [1:0] next_state;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
	localparam INPUT = 2'd0;
	localparam PLAYBACK = 2'd1;
	localparam REPEAT = 2'd2;
	localparam DONE = 2'd3;

	// Output Combinational Logic
	always @( * ) begin
		// Set defaults
		m1 = 0;
		m2 = 0;
		m3 = 0;
		m4 = 0;
		count_ns = 0;
		rst_i = 0;
		count_i = 0;
		reset = 0;

		if (rst) begin
			reset = 1;
		end

		case (state)
			INPUT: begin
				mode_leds = LED_MODE_INPUT;
				m1 = 1;
				if (legal) begin
					rst_i = 1;
				end
			end
			PLAYBACK: begin
				mode_leds = LED_MODE_PLAYBACK;
				m2 = 1;
				count_i = 1;
				if (i_eq_ns) begin
					rst_i = 1;
				end
			end
			REPEAT: begin
				mode_leds = LED_MODE_REPEAT;
				m3 = 1;
				count_i = 1;
				if (right_guess & i_eq_ns) begin
					count_ns = 1;
				end
				else if (!right_guess) begin
					rst_i = 1;
				end
			end
			DONE: begin
				mode_leds = LED_MODE_DONE;
				m4 = 1;
				if (i_eq_ns) begin
					rst_i = 1;
				end
				else begin
					count_i = 1;
				end
			end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		next_state = state;
		
		case (state)
		INPUT: begin
			if (legal) begin
				next_state = PLAYBACK;
			end
		end
		PLAYBACK: begin
			if (i_eq_ns) begin
				next_state = REPEAT;
			end
		end
		REPEAT: begin
			if (right_guess & i_eq_ns) begin
				next_state = INPUT;
			end
			else if (!right_guess) begin
				next_state = DONE;
			end
		end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			state <= INPUT;
		end
		else begin
			// Update state to next state
			state <= next_state;
		end
	end

endmodule
