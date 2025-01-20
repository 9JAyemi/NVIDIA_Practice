//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input [3:0] pattern,       // Switches for creating pattern
	
	// Datapath Control Signals
	input     count_ns,
	input 	  rst_i,
	input	  m1,
	input	  m2,
	input	  m3,
	input	  m4,
	input 	  reset,
	input 	  count_i,

	// Datapath Outputs to Control
	output wire    right_guess,
	output wire	  i_eq_ns,
	output wire    legal,

	// External Outputs
	output wire [3:0] pattern_leds   // LED outputs for pattern
);

	// Declare Local Vars Here
	reg [5:0] ns; // number of sequences
	reg [5:0] i; // index of pattern
	wire [3:0] cur_sequence; // current pattern sequence being retrieved
	reg lvl; // level of game (0 = easy, 1 = hard)

	//----------------------------------------------------------------------
	// Internal Logic -- Manipulate Registers, ALU's, Memories Local to
	// the Datapath
	//----------------------------------------------------------------------

	always @(posedge clk) begin

		// global reset
		if (reset == 1) begin
			i <= 0;
			ns <= 0;
			lvl <= level;
		end
		else begin
			// internal updates
			if (rst_i == 1) begin
				i <= 0;
			end
			else if (count_i == 1) begin
				i <= i+1;
			end
			if (count_ns == 1) begin
				ns <= ns + 1;
			end
		end
	end

	// 64-entry 4-bit memory (from Memory.v)
	Memory mem(
		.clk     (clk),
		.rst     (reset),
		.r_addr  (i),
		.w_addr  (ns),
		.w_data  (pattern),
		.w_en    (m1),
		.r_data  (cur_sequence)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	assign pattern_leds = (m1 || m3) ? pattern : cur_sequence;
	assign legal = lvl || (pattern == 4'b0001 || pattern == 4'b0010 || pattern == 4'b0100 || pattern == 4'b1000);
	assign i_eq_ns = (i == ns);
	assign right_guess = (cur_sequence == pattern);

endmodule
