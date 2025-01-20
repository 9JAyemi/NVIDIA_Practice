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
wire [2:0] mem_raddr_sig; // signal for mux for  r_addr_0_mem input

wire w_data_mem_sig;

    wire [1:0] reg_wdata_sig; // signal for mux for  w_data_reg input

    wire [1:0] reg_raddr0_sig; // signal for mux to determine which address in the register to read

    wire  reg_raddr1_sig;  // signal for mux to determine which address in the register to read

 wire mem_waddr_sig; // signal to allow for  w_addr_mem input 

    wire mem_w_en_sig; // signal to allow for w_en_mem to enable writting to memory 

//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

     wire reg_waddr_sig; // signal for mux for w_addr_reg input (DELETE?)

    wire reg_w_en_sig; // signal to allow for w_en_reg to enable writting to register 

     wire pc_ld;  

    wire ir_ld;

    wire [1:0] alu_sig;    // signal for ALU related computation (might need to change size)

     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)

    wire [2:0] pc_mux; // signal used to select what gets loaded into the pc 

     wire [2:0] alu_input1_sig;

    wire [3:0] alu_input2_sig;

    wire cc_sig; 

    wire nzp_mux;

    wire sti1_sig;

    wire ldi1_sig;

    

    wire bit_5; // signal used for imm5 operations
    wire bit_11; // signal used for PCoffset11 operations
	wire bit_8;
	wire bit_7;
	wire bit_6;
    wire [15:0] ir_output; // ouput from ir register 

    wire n; // bit 11 used for CC
    wire z; // bit 10 used for CC
    wire  p; // bit 9 used for CC
    wire  N;
    wire  Z;
     wire  P;
    //----------------------------------------------------------------------
    // Control Module
    //----------------------------------------------------------------------
    PUnCControl ctrl(
        .clk             (clk),
        .rst             (rst),

        .mem_raddr_sig   (mem_raddr_sig)   ,
        .reg_wdata_sig    (reg_wdata_sig)  , 
        .reg_raddr0_sig   (reg_raddr0_sig)     , 
        .reg_raddr1_sig   (reg_raddr1_sig)     ,  
        .mem_waddr_sig    (mem_waddr_sig)     , 
        .mem_w_en_sig  (mem_w_en_sig)   ,
 
//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

    .reg_waddr_sig         (reg_waddr_sig)   , // signal for mux for w_addr_reg input (DELETE?)
     .reg_w_en_sig         (reg_w_en_sig)   , // signal to allow for w_en_reg to enable writting to register 
     .w_data_mem_sig           (w_data_mem_sig),

    .pc_ld       (pc_ld)  ,  
    .ir_ld      (ir_ld)   ,
    .alu_sig               (alu_sig )   ,    // signal for ALU related computation (might need to change size)
     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)
    .pc_mux                (pc_mux)   , 
    .alu_input1_sig        (alu_input1_sig)   ,
    .alu_input2_sig        (alu_input2_sig)   , 
    .cc_sig                (cc_sig) , 
    .nzp_mux               (nzp_mux ),
    .sti1_sig              (sti1_sig ) ,
    .ldi1_sig              (ldi1_sig )    ,

    .bit_5 (bit_5),  // signal used for imm5 operations
    .bit_11(bit_11), // signal used for PCoffset11 operations
	.bit_8(bit_8),
	.bit_7(bit_7),
	.bit_6(bit_6),
    .ir (ir_output), // ouput from ir register 

    .n(n), // bit 11 used for CC
    .z(z), // bit 10 used for CC
    .p(p), // bit 9 used for CC
    . N(N), 
    .Z(Z),
    .P(P)
        // Add more ports here
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

        .mem_raddr_sig   (mem_raddr_sig)   ,
        .reg_wdata_sig    (reg_wdata_sig)  , 
        .reg_raddr0_sig   (reg_raddr0_sig)     , 
        .reg_raddr1_sig   (reg_raddr1_sig)     ,  
        .mem_waddr_sig    (mem_waddr_sig)     , 
        .mem_w_en_sig  (mem_w_en_sig)   ,
 
//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

    .reg_waddr_sig         (reg_waddr_sig)   , // signal for mux for w_addr_reg input (DELETE?)
     .reg_w_en_sig         (reg_w_en_sig)   , // signal to allow for w_en_reg to enable writting to register 
.w_data_mem_sig          (w_data_mem_sig),
    .pc_ld       (pc_ld)  ,  
    .ir_ld      (ir_ld)   ,
    .alu_sig               (alu_sig )   ,    // signal for ALU related computation (might need to change size)
     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)
    .pc_mux                (pc_mux)   , 
    .alu_input1_sig        (alu_input1_sig)   ,
    .alu_input2_sig        (alu_input2_sig )   , 
    .cc_sig                (cc_sig ) , 
    .nzp_mux               (nzp_mux ),
    .sti1_sig              (sti1_sig ) ,
    .ldi1_sig              (ldi1_sig  )    ,

    .bit_5          (bit_5),  // signal used for imm5 operations
    .bit_11          (bit_11 ), // signal used for PCoffset11 operations
	.bit_8(bit_8),
	.bit_7(bit_7),
	.bit_6(bit_6),
    .ir (ir_output), // ouput from ir register 

    .n                     (n), // bit 11 used for CC
    .z (z), // bit 10 used for CC
    .p (p), // bit 9 used for CC
    .N (N), 
    .Z (Z),
    .P (P)

        
        // Add more ports here
    );

endmodule
