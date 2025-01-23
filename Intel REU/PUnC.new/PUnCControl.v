//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// outputs to the datapath
	output reg [1:0] extend,
	output reg op2,
	output reg ir_ld,
	output reg [1:0] op1,
	output reg [2:0] result,
	output reg rf_w_en,
	output reg decode,
	output reg [1:0] pc_select,
	output reg branch,
	output reg [2:0] mem_read_loc,
	output reg [1:0] mem_write_loc,
	output reg mem_w_en,

	// input from the datapath
	input wire [3:0] opcode, 
	input bitfive,
	input biteleven,
	input [2:0] pc_instr,
	input br_enable
);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_FETCH = 5'd0;
	localparam STATE_DECODE = 5'd1;
	localparam STATE_ADD1 = 5'd2;
	localparam STATE_ADD2 = 5'd3;
	localparam STATE_AND1 = 5'd4;
	localparam STATE_AND2 = 5'd5;
	localparam STATE_BR = 5'd6;
	localparam STATE_JMPRET = 5'd7;
	localparam STATE_JSR = 5'd8;
	localparam STATE_JSRR = 5'd9;
	localparam STATE_LD = 5'd10;
	localparam STATE_LDI1 = 5'd11;
	localparam STATE_LDI2 = 5'd12;
	localparam STATE_LDR = 5'd13;
	localparam STATE_LEA = 5'd14;
	localparam STATE_NOT = 5'd15;
	localparam STATE_ST = 5'd16;
	localparam STATE_STI = 5'd17;
	localparam STATE_STR = 5'd18;
	localparam STATE_HALT = 5'd19;

	// State, Next State
	reg [4:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		decode = 0;
		extend = `extend_pc6;
		op1 = `op1_base_r;
		op2 = `op2_r_data1;
		ir_ld = 0;
		result = 0;
		rf_w_en = 0;
		branch = 0;
		pc_select = 2'b00;
		mem_read_loc = 0;
		mem_write_loc = 0;
		mem_w_en = 0;

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				ir_ld = 1;
			end
			STATE_DECODE: begin
				decode = 1;
			end
			STATE_ADD1: begin
				op1 = `op1_r_data0;
				op2 = `op2_r_data1;
				rf_w_en = 1;
				result = `result_sum;
			end
			STATE_ADD2: begin
				extend = `extend_imm5;
				op1 = `op1_r_data0;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_sum;
			end
			STATE_AND1: begin
				op1 = `op1_r_data0;
				op2 = `op2_r_data1;
				rf_w_en = 1;
				result = `result_and;
			end
			STATE_AND2: begin
				extend = `extend_imm5;
				op1 = `op1_r_data0;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_and;
			end
			STATE_BR: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				result = `result_pc;
				if (br_enable == 1) begin
					pc_select = `pc_select_jsr;
				end
				else begin
					pc_select = 0;
				end
			end
			STATE_JMPRET: begin
				op1 = `op1_base_r;
				pc_select = `pc_select_jmp;
			end
			STATE_JSR: begin
				extend = `extend_pc11;
				op1 = `op1_pc;
				rf_w_en = 1;
				op2 = `op2_extended;
				result = `result_pc;
				pc_select = `pc_select_jsr;
			end
			STATE_JSRR: begin
				op1 = `op1_base_r;
				rf_w_en = 1;
				result = `result_pc;
				pc_select = `pc_select_jsrr;
			end
			STATE_LD: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_mem;
				mem_read_loc = `mem_read_loc_ld;
				mem_w_en = 1;
			end
			STATE_LDI1: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_mem;
				mem_read_loc = `mem_read_loc_ldi1;
				mem_w_en = 1;
			end
			STATE_LDI2: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_mem;
				mem_read_loc = `mem_read_loc_ldi2;
				mem_w_en = 1;
			end
			STATE_LDR: begin
				extend = `extend_pc6;
				op1 = `op1_base_r;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_mem;
				mem_read_loc = `mem_read_loc_ldr;
				mem_w_en = 1;
			end
			STATE_LEA: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				rf_w_en = 1;
				result = `result_sum;
			end
			STATE_NOT: begin
				op1 = `op1_r_data0;
				rf_w_en = 1;
				result = `result_not;
			end
			STATE_ST: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				result = `result_sum;
				mem_write_loc = `mem_write_loc_st;
				mem_w_en = 1;
			end
			STATE_STI: begin
				extend = `extend_pc9;
				op1 = `op1_pc;
				op2 = `op2_extended;
				result = `result_sum;
				mem_write_loc = `mem_write_loc_sti;
				mem_w_en = 1;
			end
			STATE_STR: begin
				extend = `extend_pc6;
				op1 = `op1_base_r;
				op2 = `op2_extended;
				result = `result_sum;
				mem_write_loc = `mem_write_loc_str;
				mem_w_en = 1;
			end
			STATE_HALT: begin
				
			end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;

		// Add your next-state logic here
		case (state)
			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end
			STATE_DECODE: begin
				case (opcode) 
					4'b0001 : begin
						if (bitfive == 0) begin
							next_state = STATE_ADD1;
						end 
						else if (bitfive == 1) begin
							next_state = STATE_ADD2;
						end
					end
					4'b0101 : begin
						if (bitfive == 0) begin
							next_state = STATE_AND1;
						end 
						else if (bitfive == 1) begin
							next_state = STATE_AND2;
						end
					end
					4'b0000 : begin
						next_state = STATE_BR;
					end
					4'b1100: begin
						next_state = STATE_JMPRET;
					end
					4'b0100 : begin
						if (biteleven == 0) begin
							next_state = STATE_JSRR;
						end 
						else if (biteleven == 1) begin
							next_state = STATE_JSR;
						end
					end
					4'b0010 : begin
						next_state = STATE_LD;
					end
					4'b1010 : begin
						next_state = STATE_LDI1;
					end
					4'b0110 : begin
						next_state = STATE_LDR;
					end
					4'b1110 : begin
						next_state = STATE_LEA;
					end
					4'b1001 : begin
						next_state = STATE_NOT;
					end
					4'b0011 : begin
						next_state = STATE_ST;
					end
					4'b1011 : begin
						next_state = STATE_STI;
					end
					4'b0111 : begin
						next_state = STATE_STR;
					end
					4'b1111 : begin
						next_state = STATE_HALT;
					end
				endcase
			end
			STATE_HALT: begin
				next_state = STATE_HALT;
			end
			STATE_LDI1: begin
				next_state = STATE_LDI2;
			end
			default: begin
				next_state = STATE_FETCH;
			end
		endcase
	end


	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Add your initial state here
			state <= STATE_FETCH;
		end
		else begin
			// Add your next state here
			state <= next_state;
		end
	end

endmodule