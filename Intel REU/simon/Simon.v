//==============================================================================
// Simon Module for Simon Project
//==============================================================================

`include "ButtonDebouncer.v"
`include "SimonControl.v"
`include "SimonDatapath.v"

module Simon(
	input        sysclk,
	input        pclk,
	input        rst,
	input        level,
	input  [3:0] pattern,

	output [3:0] pattern_leds,
	output [2:0] mode_leds
);

	// Declare local connections here
	wire count_ns;
	wire rst_i;
	wire m1;
	wire m2;
	wire m3;
	wire m4;
	wire count_i;
	wire right_guess;
	wire i_eq_ns;
	wire legal;
	wire reset;

	//============================================
	// Button Debouncer Section
	//============================================

	//--------------------------------------------
	// IMPORTANT!!!! If simulating, use this line:
	//--------------------------------------------
	wire uclk = pclk;
	//--------------------------------------------
	// IMPORTANT!!!! If using FPGA, use this line:
	//--------------------------------------------
	//wire uclk;
	//ButtonDebouncer debouncer(
	//	.sysclk(sysclk),
	//	.noisy_btn(pclk),
	//	.clean_btn(uclk)
	//);

	//============================================
	// End Button Debouncer Section
	//============================================

	// Datapath -- Add port connections
	SimonDatapath dpath(
		.clk           (uclk),
		.level         (level),
		.pattern       (pattern),
		.count_ns	(count_ns),
		.rst_i	(rst_i),
		.m1	(m1),
		.m2 (m2),
		.m3	(m3),
		.m4	(m4),
		.reset (reset),
		.count_i	(count_i),
		.right_guess	(right_guess),
		.i_eq_ns	(i_eq_ns),
		.legal	(legal),
		.pattern_leds	(pattern_leds)
	);

	// Control -- Add port connections
	SimonControl ctrl(
		.clk           (uclk),
		.rst           (rst),
		.count_ns	(count_ns),
		.rst_i	(rst_i),
		.m1	(m1),
		.m2	(m2),
		.m3	(m3),
		.m4	(m4),
		.reset (reset),
		.count_i	(count_i),
		.right_guess	(right_guess),
		.i_eq_ns	(i_eq_ns),
		.legal	(legal),
		.mode_leds	(mode_leds)
	);

endmodule
