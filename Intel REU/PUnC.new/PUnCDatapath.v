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
 	input wire [2:0] result,
 	input rf_w_en,
 	input wire [1:0] pc_select,
 	input decode,
	input branch,
	input [2:0] mem_read_loc,
	input [1:0] mem_write_loc,
	input mem_w_en,

 	// output to controller
 	output wire [3:0] opcode,
 	output bitfive,
 	output biteleven,
	output br_enable,
	output wire [2:0] pc_instr
 );

 	// Local Registers
 	reg  [15:0] pc;
 	reg  [15:0] ir;

 	// internal registers
 	wire [15:0] pc_load;
 	wire [15:0] ir_temp;
 	wire [10:0] pc11;
 	wire [2:0] dr_adr;
 	wire [2:0] sr1_adr;
 	wire [2:0] sr2_adr;
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
 	wire [2:0] r_addr_0;
 	wire [2:0] r_addr_1;
  	wire [15:0] op_sum;
 	wire [15:0] op_and;
 	wire [15:0] w_data;
 	wire [2:0] w_addr;
	wire [15:0] mem_read;
	wire [15:0] mem_write_data;
	wire [15:0] mem_write_addr;
 	reg n;
 	reg p;
 	reg z;
	reg [15:0] mem_addr_1_temp;

 	// Assign PC debug net
 	assign pc_debug_data = pc;


 	//----------------------------------------------------------------------
 	// Memory Module
 	//----------------------------------------------------------------------

 	// 1024-entry 16-bit memory (connect other ports)
 	Memory mem(
 		.clk      (clk),
 		.rst      (rst),
 		.r_addr_0 (mem_read),
 		.r_addr_1 (mem_debug_addr),
 		.w_addr   (mem_write_addr),
 		.w_data   (mem_write_data),
 		.w_en     (mem_w_en),
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
 		.r_addr_1 (r_addr_1), 
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
 			pc <= pc + 1;
 		end
		if (pc_select != 0) begin
			pc <= pc_load;
		end

		else if (rst == 1) begin
			pc <= 0;
		end

 		// ir logic
 		if (ir_ld == 1) begin
 			ir <= ir_temp;
 		end

		//ldi logic
		if (mem_read_loc == `mem_read_loc_ldi1) begin
			mem_addr_1_temp <= ir_temp;
		end

		// condition code logic
		if (result != 0) begin
			n <= w_data[15];
 			p <= ~w_data[15] & (w_data != 0);
 			z <= (w_data == 0);
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
	assign pc_instr = ir[8:6];

 	assign bitfive = ir[5];
 	assign biteleven = ir[11];
	assign br_enable = (ir[11] & n) | (ir[10] & z) | (ir[9] & p) | (~(ir[11]) & ~(ir[10]) & ~(ir[9]));

 	assign op_sum = op1_out + op2_out;
 	assign op_and = op1_out & op2_out;

 	assign extended = (extend == `extend_pc6) ? {{11{pc6[5]}}, {1{pc6[4:0]}}} :
 					(extend == `extend_pc9) ? {{8{pc9[8]}}, {1{pc9[7:0]}}}:
 					(extend == `extend_pc11) ? {{6{pc11[10]}}, {1{pc11[9:0]}}} :
 					(extend == `extend_imm5) ? {{12{imm5[4]}}, {1{imm5[3:0]}}} :
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
					(result == `result_mem) ? ir_temp :
					(result == `result_pc) ? pc :
 											0;

	assign pc_load = (pc_select == `pc_select_jmp || pc_select == `pc_select_jsrr) ? r_data_0 :
					(pc_select == `pc_select_jsr) ? (pc + extended) :
					pc;

	assign mem_read = (mem_read_loc == `mem_read_loc_ld) ? (pc + extended) :
					(mem_read_loc == `mem_read_loc_ldr) ? (r_data_0 + extended) :
					(mem_read_loc == `mem_read_loc_ldi1) ? (pc + extended) :
					(mem_write_loc == `mem_write_loc_sti) ? (pc + extended) :
					(mem_read_loc == `mem_read_loc_ldi2) ? (mem_addr_1_temp) :
					pc;

	assign mem_write_data = (mem_write_loc != 0) ? r_data_1 :
						pc;

	assign mem_write_addr = (mem_write_loc == `mem_write_loc_st) ? (pc + extended) :
						(mem_write_loc == `mem_write_loc_str) ? (r_data_0 + extended) :
						(mem_write_loc == `mem_write_loc_sti) ? (ir_temp) :
						0;

	assign r_addr_0 = sr1_adr;
	assign r_addr_1 = (mem_write_loc != 0) ? dr_adr :
				sr2_adr;

 	assign w_addr = (pc_select == `pc_select_jsr || pc_select == `pc_select_jsrr) ? 16'd7 : 
					dr_adr;

 endmodule