//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
    // External Inputs
    input  wire        clk,            // Clock
    input  wire        rst,           // Reset

// INPUT  WIRES 
    input wire bit_5,  // signal used for imm5 operations
    input wire bit_11, // signal used for PCoffset11 operations
	input wire bit_8,
	input wire bit_7,
	input wire bit_6,
    input [15:0] ir, // ouput from ir register 
    input wire n,
    input wire z,
    input wire p,
    input  N,
    input  Z,
    input  P,
      
//OUTPUT WIRES

    output reg [2:0] mem_raddr_sig, // signal for mux for  r_addr_0_mem input

    output reg w_data_mem_sig,

    output reg [1:0] reg_wdata_sig, // signal for mux for  w_data_reg input

    output reg [1:0] reg_raddr0_sig, // signal for mux to determine which address in the register to read

    output reg  reg_raddr1_sig,  // signal for mux to determine which address in the register to read

    output reg mem_waddr_sig, // signal to allow for  w_addr_mem input 

    output reg mem_w_en_sig, // signal to allow for w_en_mem to enable writting to memory 

//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

    output reg reg_waddr_sig, // signal for mux for w_addr_reg input (DELETE?)

    output reg reg_w_en_sig, // signal to allow for w_en_reg to enable writting to register 

    output reg pc_ld,  

    output reg ir_ld,

    output reg [1:0] alu_sig,    // signal for ALU related computation (might need to change size)

     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)

    output reg [2:0] pc_mux, // signal used to select what gets loaded into the pc 

    output reg [2:0] alu_input1_sig,

    output reg [3:0] alu_input2_sig,

    output reg cc_sig, 

    output reg nzp_mux,

    output reg sti1_sig,

    output reg ldi1_sig
    
    

);

    // FSM States

    // Add your FSM State values as localparams here
    localparam STATE_FETCH     = 5'd0;
    localparam STATE_DECODE     = 5'd1;
    localparam STATE_EXECUTE = 5'd2;
    localparam STATE_EXECUTE2 = 5'd3;
    localparam STATE_HALT = 5'd4;


    // State, Next State
    reg [5:0] state, next_state;

    // Output Combinational Logic
    always @( * ) begin
        // Set default values for outputs here (prevents implicit latching)
 mem_raddr_sig = 0;

 w_data_mem_sig = 0;

reg_wdata_sig = 0;

reg_raddr0_sig = 0;

reg_raddr1_sig = 0;

mem_waddr_sig = 0;

mem_w_en_sig = 0;

//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

reg_waddr_sig = 0;

reg_w_en_sig = 0;

pc_ld = 0; 

ir_ld = 0;

alu_sig = 0;    

     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)
 pc_mux = 0; // signal used to select what gets loaded into the pc 

alu_input1_sig = 0;

alu_input2_sig = 0;

 cc_sig = 0;

 nzp_mux = 0;

sti1_sig = 0;

ldi1_sig = 0;

        // Add your output logic here
        case (state)
    STATE_FETCH: begin
     //   reg_raddr0_sig = 2'b11;
     mem_raddr_sig = 2'b00;
      ir_ld = 1;
    end
    STATE_DECODE: begin
        pc_ld = 1;
    end
   
   STATE_EXECUTE: begin

    case(ir[`OC])
 `OC_ADD: begin
    if(bit_5 == 0) begin
        reg_w_en_sig = 1;
        cc_sig = 1;
    end
    else begin
        reg_w_en_sig = 1;
        alu_input2_sig = 3'b001;
        cc_sig = 1;
    end
    
    end
   
    `OC_AND: begin
        if(bit_5 == 0) begin
        reg_w_en_sig = 1;
        alu_sig = 2'b01;
        cc_sig = 1;
        end
    else begin
    reg_w_en_sig = 1;
     alu_sig = 2'b01;
    alu_input2_sig = 3'b001;
    cc_sig = 1;
    end
    end

    `OC_BR: begin
        if((n && N) || (z && Z) || (p && P)) begin
        pc_mux = 3'b001;
        pc_ld = 1;
        alu_input1_sig = 1;
        alu_input2_sig = 3'b010;
        end
    end

    `OC_JMP: begin
		if(bit_8 && bit_7 && bit_6) begin
			reg_raddr0_sig = 2'b10;
        	pc_ld = 1;
		end
		else begin
        pc_mux = 3'b010;
        pc_ld = 1;
		end
    end

    `OC_JSR: begin //needs debugging
        reg_waddr_sig = 1;
        reg_w_en_sig = 1;
        reg_wdata_sig = 2'b10;
    end

   `OC_LD: begin
    reg_w_en_sig = 1;
    alu_input1_sig = 2'b01; //pc
    alu_input2_sig = 3'b010; //SEXT(PCoffset9)
    mem_raddr_sig = 2'b01; // mem(pc + SEXT(PCoffset9))
    reg_wdata_sig = 1;
    cc_sig = 1;
    nzp_mux = 1;
    end 

    `OC_LDI: begin
    
        mem_raddr_sig = 2'b01; //mem(pc + SEXT(PCoffset9))
        alu_input1_sig = 2'b01; //pc
        alu_input2_sig = 3'b010; //SEXT(PCoffset9)
        ldi1_sig = 1;
    end

    

    `OC_LDR: begin 
        mem_raddr_sig = 2'b01;
        reg_w_en_sig = 1; 
        alu_input2_sig = 3'b100; //SEXT(PCoffset6) 
        cc_sig = 1;
        nzp_mux = 1;
        reg_wdata_sig = 1;
    end 
	
    `OC_LEA: begin 
        reg_w_en_sig = 1; 
        reg_w_en_sig = 1;
        mem_raddr_sig = 2'b01;
        alu_input1_sig = 2'b01; //pc
        alu_input2_sig = 3'b010; //SEXT(PCoffset9) 
        cc_sig = 1;
    end 
    `OC_NOT: begin
        alu_sig = 2'b11;
        reg_w_en_sig = 1;
        cc_sig = 1;
    end 

    `OC_ST: begin 
     alu_input1_sig = 2'b01; //pc
    alu_input2_sig = 3'b010; // SEXT(PCoffset9)
    reg_raddr0_sig = 2'b01; //reading data from adress at ir_output[11:9]
    mem_w_en_sig = 1;
    end 

    `OC_STI: begin 
    alu_input1_sig = 2'b01; //pc
    alu_input2_sig = 3'b010; // SEXT(PCoffset9)
   mem_raddr_sig = 2'b01; //reading data from adress at ir_output[11:9]
    sti1_sig = 1;
    end 

    

    `OC_STR: begin 
    alu_input2_sig = 3'b100; // SEXT(PCoffset6)
    reg_raddr1_sig = 2'b01; //reading data from adress at ir_output[11:9]
    w_data_mem_sig = 1;
    mem_w_en_sig = 1;
  //  reg_raddr0_sig = 2'b01;
    end 

    `OC_HLT: begin 
   
    end
    endcase
   end

   STATE_EXECUTE2: begin
    case(ir[`OC])

    `OC_JSR: begin //put in second execute 
        if(bit_11 == 0) begin
        pc_mux = 3'b010;  
        pc_ld = 1;
        end
        else begin
        pc_mux = 3'b001; // alu ouput ADD
        pc_ld = 1;
        alu_input1_sig = 2'b01; //pc
        alu_input2_sig = 3'b011; //SEXT(PCoffset11)
        end
    end
    `OC_LDI: begin //put in second execute
         reg_w_en_sig = 1;
        mem_raddr_sig = 2'b10; // ldi1 
        reg_wdata_sig = 1; //
        cc_sig = 1;
        nzp_mux = 1;
    end 
    `OC_STI: begin  // put in execute 2
          mem_waddr_sig = 1;
         mem_w_en_sig = 1;
         reg_raddr0_sig = 2'b01;
    end 
    endcase
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
            next_state = STATE_EXECUTE;
         end

         STATE_EXECUTE: begin
            if(ir[`OC] == `OC_LDI || ir[`OC] == `OC_STI || ir[`OC] == `OC_JSR ) begin
                next_state = STATE_EXECUTE2;
            end
            else if(ir[`OC] == `OC_HLT) begin
                next_state = STATE_HALT;
            end
            else  begin
                next_state = STATE_FETCH;
            end
            end
         
         STATE_EXECUTE2: begin
            next_state = STATE_FETCH;
         end

         STATE_HALT: begin
            next_state = STATE_HALT;
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