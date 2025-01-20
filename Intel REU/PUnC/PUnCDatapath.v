//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

	// input from controller
	input wire [1:0] extend,
	input op2,
	input ir_ld,
	input wire [1:0] op1,
	input wire [1:0] result,
	input rf_w_en,
	input pc_select,
	input pc_replace,
	input decode,
	input call,
	input return,

	// output to controller
	output wire [4:0] opcode 
);

	// Local Registers
	reg  [15:0] pc;
	reg  [15:0] ir;

	// Declare other local wires and registers here MOVE TO DEFINE.V
	`define extend_pc6  2'b00
	`define extend_pc9  2'b01
	`define extend_pc11  2'b10

	`define op2_r_data1 1'b0
	`define op2_extended 1'b1

	`define op1_base_r 2'b00
	`define op1_r_data0	 2'b01
	`define op1_pc 		2'b10

	`define result_sum 2'b00
	`define result_and 2'b01
	`define result_not 2'b10

	`define pc_select_baser 1'b0
	`define pc_select_r7 1'b1


	// internal registers
	wire [15:0] pc_load;
	wire [15:0] ir_temp;
	wire [10:0] pc11;
	wire [3:0] dr_adr;
	wire [3:0] sr1_adr;
	wire [3:0] sr2_adr;
	wire [4:0] imm5;
	wire [8:0] pc9;
	wire [3:0] baser;
	wire [5:0] pc6;
	wire [15:0] to_extend;
	wire [15:0] extended;
	wire [15:0] op2_out;
	wire [15:0] op1_out;
	wire [15:0] r_data_0;
	wire [15:0] r_data_1;
	wire [15:0] r_addr_0;
	wire [15:0] r_addr_1;
 	wire [15:0] op_sum;
	wire [15:0] op_and;
	wire [15:0] w_data;
	wire [15:0] w_addr;
	wire n;
	wire p;
	wire z;

	// Assign PC debug net
	assign pc_debug_data = pc;


	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (pc),
		.r_addr_1 (mem_debug_addr),
		.w_addr   (),
		.w_data   (),
		.w_en     (),
		.r_data_0 (ir_temp),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (r_addr_0),
		.r_addr_1 (sr2_adr), 
		.r_addr_2 (rf_debug_addr),
		.w_addr   (w_addr),
		.w_data   (w_data),
		.w_en     (rf_w_en),
		.r_data_0 (r_data_0),
		.r_data_1 (r_data_1),
		.r_data_2 (rf_debug_data)
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------
	always @(posedge clk) begin
		// pc logic
		if (decode == 1) begin
			if (pc_replace == 1) begin
				pc <= pc_load;
			end
			else begin
				pc <= pc + 1;
			end
		end

		// ir logic
		if (rst == 1) begin
			ir <= 0;
		end
		else if (ir_ld == 1) begin
			ir <= ir_temp;
		end
	end

	// combinational logic
	assign opcode = ir[15:12];
	assign pc11 = ir[10:0];
	assign dr_adr = ir[11:9];
	assign sr1_adr = ir[8:6];
	assign sr2_adr = ir[2:0];
	assign imm5 = ir[4:0];
	assign pc9 = ir[8:0];
	assign baser = ir[8:6];
	assign pc6 = ir[5:0];

	assign op_sum = op1_out + op2_out;
	assign op_and = op1_out & op2_out;

	assign to_extend = (extend == `extend_pc6) ? pc6 :
					(extend == `extend_pc9) ? pc9 :
					(extend == `extend_pc11) ? pc11 :
											0;
	assign extended = (extend == `extend_pc6) ? {{11{pc6[5]}}, {1{pc6[4:0]}}} :
					(extend == `extend_pc9) ? {{8{pc9[8]}}, {1{pc9[7:0]}}}:
					(extend == `extend_pc11) ? {{6{pc11[10]}}, {1{pc11[9:0]}}} :
											0;
	assign op1_out = (op1 == `op1_base_r) ? baser :
					(op1 == `op1_r_data0) ? r_data_0 :
					(op1 == `op1_pc) ? pc :
										0;

	assign op2_out = (op2 == `op2_r_data1) ? r_data_1 :
					(op2 == `op2_extended) ? extended :
											0;
	
	assign w_data = (result == `result_sum) ? op_sum :
					(result == `result_and) ? op_and :
					(result == `result_not) ? ~(r_data_0) :
											0;

	assign r_addr_0 = (return == 0) ? sr1_adr :
						(return == 1) ? 3'd7 :
										0;

	assign w_addr = (call == 0) ? dr_adr :
					(call == 1) ? 3'd7 :
								0;

	assign pc_load = (pc_select == `pc_select_baser) ? baser :
					(pc_select == `pc_select_r7) ? r_data_0 :
												0;

	assign n = w_data[15];
	assign p = ~w_data[15] & (w_data != 0);
	assign z = (w_data == 0);

endmodule
