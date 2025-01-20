//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

`include "SimonDatapath.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

	// Local Vars
	reg clk = 0;
	reg level = 0;
	reg [3:0] pattern = 4'b0000;
	reg count_ns = 0;
	reg rst_i = 0;
	reg m1 = 0;
	reg m2 = 0;
	reg m3 = 0;
	reg m4 = 0;
	reg reset = 0;
	reg count_i = 0;
	wire right_guess = 0;
	wire i_eq_ns = 0;
	wire legal = 0;
	wire [3:0] pattern_leds = 4'b0000;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	integer idx;
	initial begin
		$dumpfile("SimonDatapathTest.vcd");
		$dumpvars;
		for (idx = 0; idx < 64; idx = idx + 1) begin
			$dumpvars(0, dpath.mem.mem[idx]);
		end
	end

	// Simon Control Module
	SimonDatapath dpath(
		.clk     (clk),
		.level   (level),
		.pattern (pattern),
		.count_ns (count_ns),
		.rst_i (rst_i),
		.m1 (m1),
		.m2 (m2),
		.m3 (m3),
		.m4 (m4),
		.reset (reset),
		.count_i (count_i),
		.right_guess (right_guess),
		.i_eq_ns (i_eq_ns),
		.legal (legal),
		.pattern_leds (pattern_leds)
	);

	// Main Test Logic
	initial begin
		$finish;
	end

endmodule
