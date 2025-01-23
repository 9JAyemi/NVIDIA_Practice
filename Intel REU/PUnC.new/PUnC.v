//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here

	// outputs from the controller to the datapath
	wire [1:0] extend;
	wire op2;
	wire ir_ld;
	wire [1:0] op1;
	wire [2:0] result;
	wire rf_w_en;
	wire decode;
	wire [1:0] pc_select;
	wire branch;
	wire [2:0] mem_read_loc;
	wire [1:0] mem_write_loc;

	// input from the datapath to the controller
	wire [3:0] opcode;
	wire bitfive;
	wire biteleven;
	wire br_enable;
	wire [2:0] pc_instr;
	wire mem_w_en;


	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		.extend(extend),
		.op2(op2),
		.ir_ld(ir_ld),
		.op1(op1),
		.result(result),
		.rf_w_en(rf_w_en),
		.decode(decode),
		.pc_select(pc_select),
		.branch(branch),

		.opcode (opcode),
		.bitfive (bitfive),
		.biteleven (biteleven),
		.br_enable(br_enable),
		.pc_instr(pc_instr),
		.mem_read_loc(mem_read_loc),
		.mem_write_loc(mem_write_loc),
		.mem_w_en(mem_w_en)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// input from controller
		.extend (extend),
		.op2 (op2),
		.ir_ld (ir_ld),
		.op1 (op1),
		.result (result),
		.rf_w_en (rf_w_en),
		.pc_select (pc_select),
		.decode (decode),
		.branch(branch),

		// output to controller
		.opcode (opcode),
		.bitfive (bitfive),
		.biteleven (biteleven),
		.br_enable (br_enable),
		.pc_instr(pc_instr),
		.mem_read_loc(mem_read_loc),
		.mem_write_loc(mem_write_loc),
		.mem_w_en(mem_w_en)
	);

endmodule