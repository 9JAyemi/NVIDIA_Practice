//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath1.v"
`include "PUnCControl1.v"

module PUnC1(
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

	wire [15:0] ir;

	wire		mem_wr_en;

	wire [2:0] 	mem_r_addr_sel;
   	
	wire 		state2_STI;
   	wire	 	STR;

	wire [2:0]	RF_wr_addr;
	wire 		RF_wr_en;
	wire [2:0]	RF_r_addr_0;
	wire [2:0]	RF_r_addr_1;

	wire [1:0]	RF_w_data_sel;


    wire        ir_ld;

   // Program Counter Controls
   wire			  JMP_RET_JSRR;
   wire             pc_ld;
   wire             pc_clr;
   wire             pc_up;

   // ALU Controls
   wire				add_const;
   wire  		[1:0] alu_sel; // combination of alu_s1 and alu_s0

   // Condition Code Controls
   wire				cc_en;			
   wire				n;
   wire				z;
   wire				p;
   

   // SEXT Controls
   wire		[10:0] const;
   wire		[3:0]  SEXT_Select;

	// Declare your wires for connecting the datapath to the controller here

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl1 ctrl(
		.clk             (clk),
		.rst             (rst),

		// inputs from DP
		.ir	(ir), 

		// outputs to DP
		.mem_wr_en		(mem_wr_en),
	    .mem_r_addr_sel(mem_r_addr_sel),
   	 	.state2_STI(state2_STI),
    	.STR(STR),
    	.RF_wr_addr(RF_wr_addr),
    	.RF_wr_en(RF_wr_en),
    	.RF_r_addr_0(RF_r_addr_0),
    	.RF_r_addr_1(RF_r_addr_1),
    	.RF_w_data_sel(RF_w_data_sel),
    	.ir_ld(ir_ld),
    	.JMP_RET_JSRR(JMP_RET_JSRR),
    	.pc_ld(pc_ld),
    	.pc_clr(pc_clr),
    	.pc_up(pc_up),
    	.add_const(add_const),
    	.alu_sel(alu_sel),
    	.cc_en(cc_en),
    	.n(n),
    	.z(z),
    	.p(p),
		.const(const),
		.SEXT_Select(SEXT_Select)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath1 dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// outputs to controller
		.ir	(ir), 

		// inputs from controller
		.mem_wr_en		(mem_wr_en),
	    .mem_r_addr_sel(mem_r_addr_sel),
   	 	.state2_STI(state2_STI),
    	.STR(STR),
    	.RF_wr_addr(RF_wr_addr),
    	.RF_wr_en(RF_wr_en),
    	.RF_r_addr_0(RF_r_addr_0),
    	.RF_r_addr_1(RF_r_addr_1),
    	.RF_w_data_sel(RF_w_data_sel),
    	.ir_ld(ir_ld),
    	.JMP_RET_JSRR(JMP_RET_JSRR),
    	.pc_ld(pc_ld),
    	.pc_clr(pc_clr),
    	.pc_up(pc_up),
    	.add_const(add_const),
    	.alu_sel(alu_sel),
    	.cc_en(cc_en),
    	.n(n),
    	.z(z),
    	.p(p),
		.const(const),
		.SEXT_Select(SEXT_Select)
	);

endmodule
