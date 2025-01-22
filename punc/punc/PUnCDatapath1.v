//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory1.v"
`include "RegisterFile1.v"
`include "Defines.v"

module PUnCDatapath1(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

	// Add more ports here
// INPUTS FROM CONTROLLER
	// Memory Control wires
	input 	wire		 	mem_wr_en,

	input 	wire	[2:0] 	mem_r_addr_sel, // combination of state2_LDI (s1) and state_LD (s0)... may need to also make state2_LDI a datapath output
   	
	input 	wire 			state2_STI, // may need to make a datapath output
   	input 	wire 			STR,

   // Register File Controls
	input   wire	[2:0]	RF_wr_addr,
	input   wire			RF_wr_en,
	input   wire	[2:0]	RF_r_addr_0,
	input   wire	[2:0]	RF_r_addr_1,

	input 	wire	[1:0]	RF_w_data_sel, // combination of C_wr_RF (s0) and mem_ld	(s1)


   // Instruction Register Controls
   input    wire          ir_ld,

   // Program Counter Controls
   input 	wire		  JMP_RET_JSRR,
   input    wire          pc_ld,
   input    wire          pc_clr,
   input    wire          pc_up,

   // ALU Controls
   input 	wire			add_const,
   input   	wire	[1:0] alu_sel, // combination of alu_s1 and alu_s0

   // Condition Code Controls
   input 	wire			cc_en,			
   input 	wire			n,
   input 	wire			z,
   input 	wire			p,
   

   // SEXT Controls
   input 	wire	[10:0] const_n,
   input 	wire	[3:0]  SEXT_Select,

   // Output signals to controller
   output reg 		[15:0] ir
);

// Declare other local wires and registers here

	// CC Port
	wire br;

	// ALU PORT
	wire [15:0] alu_b;
	
	//  MEMORY PORTS
	wire [15:0] mem_r_addr; // INT
	wire [15:0] mem_wr_data; // INT
	wire [15:0] mem_wr_addr; // INT
	wire [15:0] mem_r_data; // INT

	//  RF PORTS
	wire [15:0] RF_r_data_0; // INT
	wire [15:0] RF_r_data_1; // INT
	wire [15:0] RF_wr_data; // INT /*this channel should be a wire*/
	
//----------------------------------------------------------------------
	// Local Register 'Modules'
	//----------------------------------------------------------------------
	reg  [15:0] pc;
	// reg	 [15:0] instruction_reg;
	reg N;
	reg Z;
	reg P;

	// cheat
	reg [15:0] indirect;
	always @(posedge clk) begin
	indirect = mem_r_data;
	end

	wire [15:0] alu_c;
	wire [15:0] sign_extended_const;
	wire [15:0] pc_adder; 
	// Assign PC debug net
	assign pc_debug_data = pc;

	

	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// MEMORY FUNCTIONALITY (muxes)

	assign mem_r_addr = (mem_r_addr_sel == `MUX_SELECT_ZERO) ? pc:
						(mem_r_addr_sel == `MUX_SELECT_ONE) ? pc_adder:
						(mem_r_addr_sel == `MUX_SELECT_TWO) ? indirect: // NOTE: instead of pass through from RF, it reads from indirect
						(mem_r_addr_sel == `MUX_SELECT_THREE) ? mem_r_data: 
						(mem_r_addr_sel == 3'b100) ? (alu_c): 7'd77;

	assign mem_wr_data = (STR == 1'b0) ? alu_c: /*else*/ RF_r_data_1;

	assign mem_wr_addr = (state2_STI == 1'b0) ? pc_adder: /*else*/ indirect;


	// 1024-entry 16-bit memory (connect other ports)
	Memory1 mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (mem_r_addr), // INT
		.r_addr_1 (mem_debug_addr),
		.w_addr   (mem_wr_addr), // INT
		.w_data   (mem_wr_data), // INT
		.w_en     (mem_wr_en), // EXT
		.r_data_0 (mem_r_data), // INT
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// RF FUNCTIONALITY (muxes)

	assign RF_wr_data = (RF_w_data_sel == `MUX_SELECT_ZERO) ? alu_c:
						(RF_w_data_sel == `MUX_SELECT_ONE) ? pc:
						(RF_w_data_sel == `MUX_SELECT_TWO) ? mem_r_data: // error?
						(RF_w_data_sel == `MUX_SELECT_THREE) ? pc_adder: 7'd77;
	

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile1 rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (RF_r_addr_0), // EXT
		.r_addr_1 (RF_r_addr_1), // EXT
		.r_addr_2 (rf_debug_addr),
		.w_addr   (RF_wr_addr), // EXT
		.w_data   (RF_wr_data), // INT
		.w_en     (RF_wr_en), // EXT
		.r_data_0 (RF_r_data_0), // INT
		.r_data_1 (RF_r_data_1), // INT
		.r_data_2 (rf_debug_data)
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------

	// IR FUNCTIONALITY
	always @(posedge clk) begin
		if (ir_ld) begin
			ir = mem_r_data;
		end
		if (rst) begin
			ir <= 16'd0;
		end
	end
	
	// PC FUNCTIONALITY
	always @(posedge clk) begin
		if (pc_clr) begin
			pc <= 16'd0;
		end 
		if (pc_up) begin
			pc = pc + 16'd1;
		end
		if (pc_ld || (br && ir[`OC] == `OC_BR)) begin
			pc = (JMP_RET_JSRR) ? (alu_c):
				 (~JMP_RET_JSRR) ? (pc_adder): 7'd77;
		end
	end

	// CC FUNCTIONALITTY
	always @(posedge clk) begin
		if (cc_en) begin
			N = alu_c[15]; 
			Z = ~(|alu_c); // !alu_c; // ~(|alu_c); // 16-bit bitwise nor
			P = ~alu_c[15] & (|alu_c); // ~alu_c[15] && alu_c; // (|alu_c); // ensures that P isnt on for 0  
		end
	end

	assign br = (N&n) | (Z&z) | (P&p); // indicates whether or not to branch

	// PC adder FUNCTIONALIY
	assign pc_adder = /*cheat*/(STR == 1'd1) ? (alu_c) : (pc + sign_extended_const);	

	// SEXT FUNCTIONALY
	assign sign_extended_const = (SEXT_Select == 4'b1000) ? {{11{const_n[4]}}, const_n[4:0]}: // 5 -> 16 bit
								(SEXT_Select == 4'b0100) ? {{10{const_n[5]}}, const_n[5:0]}: // 6 -> 16 bit
								(SEXT_Select == 4'b0010) ? {{7{const_n[8]}}, const_n[8:0]}: // 9 -> 16 bit
								(SEXT_Select == 4'b0001) ? {{5{const_n[10]}}, const_n[10:0]}: 7'd77; // 10 -> 16-bit

	
	// ALU FUNCTIONALITY
	assign alu_b = (add_const == 1'd1) ? (sign_extended_const):
					(add_const == 1'd0) ? (RF_r_data_1): 7'd77;

	assign alu_c = (alu_sel == `ALU_FN_PASS) ? (RF_r_data_0):
					   (alu_sel == `ALU_FN_ADD) ? (RF_r_data_0 + alu_b):
					   (alu_sel == `ALU_FN_AND) ? (RF_r_data_0 & alu_b):
					   (alu_sel == `ALU_FN_NOT) ? (~RF_r_data_0): /*default value for debugging*/ 7'd77;
endmodule
