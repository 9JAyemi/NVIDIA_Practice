//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"


module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Input Signals from Datapath
	input [15:0] ir,
	// input  rf_p_zero, --> we may need datapath signals to signal transition to second states

// OUTPUTS TO DP
	// Memory Control wires
	output reg			 	mem_wr_en,

	output reg		[2:0] 	mem_r_addr_sel, // combination of state2_LDI (s1) and state_LD (s0)... may need to also make state2_LDI a datapath output
								// added extra bit for LDR
	output reg	 			state2_STI, // may need to make a datapath output
   	output reg	 			STR,

   // Register File Controls
	output reg  	[2:0]	RF_wr_addr,
	output reg  			RF_wr_en,
	output reg  	[2:0]	RF_r_addr_0,
	output reg  	[2:0]	RF_r_addr_1,

	output reg		[1:0]	RF_w_data_sel, // combination of C_wr_RF (s0) and mem_ld	(s1)


   // Instruction Register Controls
   output reg             ir_ld,

   // Program Counter Controls
   output reg			  JMP_RET_JSRR,
   output reg             pc_ld,
   output reg             pc_clr,
   output reg             pc_up,

   // ALU Controls
   output reg				add_const,
   output reg  		[1:0] alu_sel, // combination of alu_s1 and alu_s0

   // Condition Code Controls
   output reg				cc_en,			
   output reg				n,
   output reg				z,
   output reg				p,
   

   // SEXT Controls
   output reg		[10:0] const,
   output reg		[3:0]  SEXT_Select
);

	// FSM States
	// Add your FSM State values as localparams here
	
	
	/* how to account for 4-bit opcode with 19 distinct states*/
	localparam STATE_INIT     = 5'b10000;
	localparam STATE_FETCH     = 5'b11000;
	localparam STATE_DECODE     = 5'b11100;
	localparam STATE2_STI = 5'b11110;
	localparam STATE2_LDI = 5'b11111;

	// State, Next State
	/*do i have to make these 5-bits?*/
	reg [4:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		mem_wr_en = 1'd0;
		mem_r_addr_sel = 3'b000;
		state2_STI /*may need to make a datapath output*/= 1'd0;
		STR = 1'd0;
		RF_wr_addr = 3'b000;
		RF_wr_en = 1'd0;
		RF_r_addr_0 = 3'b000;
		RF_r_addr_1 = 3'b000;
		RF_w_data_sel = 2'b00;
		ir_ld = 1'd0;
		add_const = 0;
		JMP_RET_JSRR = 1'd0;
		pc_ld = 1'd0;
		pc_clr = 1'd0;
		pc_up = 1'd0;
		alu_sel = 2'b00;
		cc_en = 1'd0;
		n = 1'd0;
		z = 1'd0;
		p = 1'd0;
		const = 11'b00000000000;
		SEXT_Select = 4'b0000;

		// Add your output logic here
		case (state)
			STATE_INIT: begin
            pc_clr     = 1'd1;
         end
         STATE_FETCH: begin
            ir_ld      = 1'd1;
         end
         STATE_DECODE: begin
			 pc_up = 1'd1; // always increment PC
         end
		 // possible excecute states
			`OC_ADD: begin
				
				alu_sel = 2'b01;
				add_const = ir[`Bit5]; // set to bit 5 for add instruction
				cc_en = 1'd1;

				const = 11'd0 + ir[`imm5];
				SEXT_Select = 4'b1000;

				RF_wr_addr = ir[`DR_11to9];
				RF_wr_en = 1'd1;
				RF_r_addr_0 = ir[`SR1_8to6];
				RF_r_addr_1 = ir[`SR2_2to0];
			end

			`OC_AND: begin
				alu_sel = 2'b10;
				add_const = ir[`Bit5]; // set to bit 5 for add instruction
				cc_en = 1'd1;

				const = 11'd0 + ir[`imm5];
				SEXT_Select = 4'b1000;

				RF_wr_addr = ir[`DR_11to9];
				RF_wr_en = 1'd1;
				RF_r_addr_0 = ir[`SR1_8to6];
				RF_r_addr_1 = ir[`SR2_2to0];
			end

			`OC_BR: begin
				const = 11'd0 + ir[`PCOffset9];
				SEXT_Select = 4'b0010;
				
				cc_en = 1'd0;
				n = ir[`BR_N];
				z = ir[`BR_Z];
				p = ir[`BR_P];
			end

			`OC_JMP: begin
				pc_ld = 1;
				JMP_RET_JSRR = 1;
				
				RF_r_addr_0 = ir[`BaseR_8to6];
			end

			`OC_JSR: begin
				pc_ld = 1;
				JMP_RET_JSRR = ~ir[`JSR_BIT_NUM];

				const = ir[`PCOffset11];
				SEXT_Select = 4'b0001;

				RF_wr_en = 1'd1;
				RF_r_addr_0 = ir[`BaseR_8to6];
				RF_wr_addr = 3'b111;
				RF_w_data_sel = 2'b01; // PC_wr_RF = 1
			end

			`OC_LD: begin
				mem_r_addr_sel = 2'b01; // state_LD (s0) = 1

				const = 11'd0 + ir[`PCOffset9];
				SEXT_Select = 4'b0010;

				cc_en = 1;
				
				RF_wr_en = 1'd1;
				RF_wr_addr = ir[`DR_11to9];
				RF_w_data_sel = 2'b10; // mem_ld (s1) = 1
			end

			`OC_LDIC1: begin
				mem_r_addr_sel = 2'b01; // state_LD (s0) = 1

				const = 11'd0 + ir[`PCOffset9];
				SEXT_Select = 4'b0010;

				// RF_w_data_sel = 2'b10; // mem_ld (s1) = 1
				// RF_wr_en = 1'd1;
				// RF_wr_addr = ir[`DR_11to9];

			end

			`OC_LDIC2: begin
				mem_r_addr_sel = 2'b10; // state2_LDI (s1) = 1

				cc_en = 1'd1;

				RF_wr_en = 1'd1;
				RF_wr_addr = ir[`DR_11to9];
				RF_w_data_sel = 2'b10; // this now selects for indirect register rather than mem
			end

			`OC_LDR: begin
				mem_r_addr_sel = 3'b100;

				alu_sel = 2'b01;
				add_const = 1'd1;

				const = 11'd0 + ir[`offset6];
				SEXT_Select = 4'b0100;

				cc_en = 1'd1;

				RF_wr_addr = ir[`DR_11to9];
				RF_wr_en = 1'd1;
				RF_r_addr_0 = ir[`BaseR_8to6];
				RF_w_data_sel = 2'b10; // mem_ld (s1) = 1
			end

			`OC_LEA: begin
				const = 11'd0 + ir[`PCOffset9];
				SEXT_Select = 4'b0010;

				cc_en = 1;

				RF_w_data_sel = 2'b11; // PC_wr_RF and mem_ld = 1
				RF_wr_addr = ir[`DR_11to9];
				RF_wr_en = 1'd1;
			end

			`OC_NOT: begin
				alu_sel = 2'b11;

				cc_en = 1'd1;

				RF_wr_addr = ir[`DR_11to9];
				RF_wr_en = 1'd1;
				RF_r_addr_0 = ir[`SR1_8to6];
			end

			`OC_ST: begin
				RF_r_addr_0 = ir[`SR_11to9];
				mem_wr_en = 1'd1;
				SEXT_Select = 4'b0010;
				const = 11'd0 + ir[`PCOffset9]; 	
			end

			// sti is wrong because we should still have PC+SEXT in second cycle
			`OC_STI1: begin
				mem_r_addr_sel = 2'b01; // state_LD (s0) = 1
				// RF_r_addr_0 = ir[`SR_11to9];

				SEXT_Select = 4'b0010;
				const = 11'd0 + ir[`PCOffset9];				
			end

			`OC_STI2: begin // this might be a problem
				mem_r_addr_sel = 2'b10; // state2_LDI (s1) and state_LD (s0) = 1
				mem_wr_en = 1'd1;

				SEXT_Select = 4'b0010;
				const = 11'd0 + ir[`PCOffset9];	

				state2_STI = 1'd1;					
			end

			`OC_STR: begin
				alu_sel = 2'b01; // alu_s0 = 1
				add_const = 1'd1;

				SEXT_Select = 4'b0100;
				const = 11'd0 + ir[`offset6];
				RF_r_addr_0 = ir[`BaseR_8to6];
				RF_r_addr_1 = ir[`SR_11to9];

				// CHEAT state2_STI = 1'd1; 
				mem_wr_en = 1'd1;
				STR = 1'd1; //CHEAT: will make PC_Addr = BaseR+SEXT
			end
			
			`OC_HLT: begin
				// keep empty as no signals are on
			end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		 next_state = STATE_FETCH;

		// Add your next-state logic here
		case (state)
		// init
			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end
			STATE_DECODE: begin
				case (ir[`OC])
					`OC_ADD: begin
						next_state = `OC_ADD;
					end

					`OC_AND: begin
						next_state = `OC_AND;
					end

					`OC_BR: begin
						next_state = `OC_BR;
					end

					`OC_JMP: begin
						next_state = `OC_JMP;
					end

					`OC_JSR: begin
						next_state = `OC_JSR;
					end

					`OC_LD: begin
						next_state = `OC_LD;
					end

					`OC_LDIC1: begin
						next_state = `OC_LDIC1;
					end

					`OC_LDR: begin
						next_state = `OC_LDR;
					end

					`OC_LEA: begin
						next_state = `OC_LEA;
					end

					`OC_NOT: begin
						next_state = `OC_NOT;
					end

					`OC_ST: begin
						next_state = `OC_ST;
					end
					`OC_STI1: begin
						next_state = `OC_STI1;
					end
					`OC_STR: begin
						next_state = `OC_STR;
					end
					`OC_HLT: begin
						next_state = `OC_HLT;
					end
				endcase
			end
			`OC_STI1: begin
				next_state = `OC_STI2; // idk if this will be a problem //RZ: I think this will be good
			end
			`OC_LDIC1: begin
				next_state = `OC_LDIC2;
			end
			`OC_HLT: begin // next state is still halt
				next_state = `OC_HLT;
			end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// initial state here
			state <= STATE_INIT;
		end
		else begin
			state <= next_state;
		end
	end
endmodule