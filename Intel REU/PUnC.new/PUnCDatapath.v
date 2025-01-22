//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"


// Are we allowed to do any type of combinational logic in the control module or should we just have it be here?

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

    // Add more ports here

// INPUT WIRES FOR MUXES/WRITTING
    input [2:0] mem_raddr_sig, // signal for mux for  r_addr_0_mem input
    input w_data_mem_sig,

    input [1:0]  reg_wdata_sig, // signal for mux for  w_data_reg input

    input [1:0] reg_raddr0_sig, // signal for mux to determine which address in the register to read

    input wire  reg_raddr1_sig,  // signal for mux to determine which address in the register to read

 input wire mem_waddr_sig, // signal to allow for  w_addr_mem input 

    input wire mem_w_en_sig, // signal to allow for w_en_mem to enable writting to memory 

//  input  mem_w_data,  // signal for mux for w_data_mem input (DELETE?)

    input wire reg_waddr_sig, // signal for mux for w_addr_reg input (DELETE?)

    input wire reg_w_en_sig, // signal to allow for w_en_reg to enable writting to register 

    input wire pc_ld,  

    input wire ir_ld,

    input[1:0] alu_sig,    // signal for ALU related computation (might need to change size)

     // input wire [2:0] offset_sel, // signal used to select which bit gets offset (MIGHT DELETE)

    input wire [2:0] pc_mux, // signal used to select what gets loaded into the pc 

    input wire [2:0] alu_input1_sig,

    input [3:0] alu_input2_sig,

    input cc_sig, 

    input nzp_mux, 

    input sti1_sig,

    input ldi1_sig,

    
// OUTPUT WIRES 
    output wire bit_5,  // signal used for imm5 operations
    output wire bit_11, // signal used for PCoffset11 operations
	output bit_8,
	output bit_7,
	output bit_6,
    output [15:0] ir, // ouput from ir register 

    output wire n, // bit 11 used for CC
    output wire z, // bit 10 used for CC
    output wire  p, // bit 9 used for CC
    output reg  N, 
    output reg  Z,
    output reg  P

// in controller we send those wires and check the if statement, then set the signals needed to 
// have the pc = pc + sext()
    


);

    // Local Registers
    reg  [15:0] pc;
    reg  [15:0] ir;

    // Declare other local wires and registers here



    //wires for memblock
wire[15:0] w_data_mem;
wire[15:0] r_addr_0_mem;
wire[15:0] w_addr_mem;
wire[15:0] r_data_0_mem;

//wires for reg block
wire[15:0] w_data_reg;
wire[2:0] r_addr_0_reg;
wire[2:0] r_addr_1_reg;
wire[2:0] w_addr_reg;
wire[15:0] r_data_0_reg;
wire[15:0] r_data_1_reg;


// Intermediate wires/regs

wire signed[15:0] imm5; // wire used for imm5 
wire signed[15:0]offset_6; // wire used for offset6
wire signed[15:0]PCoffset_9; // wire used for PCoffset9
wire signed[15:0] PCoffset_11;
// wire offset_selected; // MIGHT DELETE
wire [15:0] nextPC;
wire[15:0] alu_input1;
wire [15:0] alu_input2;
wire [15:0] alu_output;

reg [15:0] sti1;
reg [15:0] ldi1;

    // Assign PC debug net
    assign pc_debug_data = pc;


    //----------------------------------------------------------------------
    // Memory Module
    //----------------------------------------------------------------------

    // 1024-entry 16-bit memory (connect other ports)
    Memory mem(
        .clk      (clk),
        .rst      (rst),
        .r_addr_0 (r_addr_0_mem),
        .r_addr_1 (mem_debug_addr),
        .w_addr   (w_addr_mem),
        .w_data   (w_data_mem),
        .w_en     (mem_w_en_sig),
        .r_data_0 (r_data_0_mem),
        .r_data_1 (mem_debug_data)
    );

    //----------------------------------------------------------------------
    // Register File Module
    //----------------------------------------------------------------------

    // 8-entry 16-bit register file (connect other ports)
    RegisterFile rfile(
        .clk      (clk),
        .rst      (rst),
        .r_addr_0 (r_addr_0_reg),
        .r_addr_1 (r_addr_1_reg),
        .r_addr_2 (rf_debug_addr),
        .w_addr   (w_addr_reg),
        .w_data   (w_data_reg),
        .w_en     (reg_w_en_sig),
        .r_data_0 (r_data_0_reg),
        .r_data_1 (r_data_1_reg),
        .r_data_2 (rf_debug_data)
    );

    //----------------------------------------------------------------------
    // Add all other datapath logic here
    //----------------------------------------------------------------------

    // Output Signal Logic

assign bit_5 = ir[5];
assign bit_11 = ir[11];
assign bit_8 = ir[8];
assign bit_7 = ir[7];
assign bit_6 = ir[6];
// assign ir_output = ir;
assign n = ir[11];
assign z = ir[10];
assign p = ir[9];


    // SEXT Combinational Logic
assign imm5 = {{11{ir[4]}}, ir[4:0]};
assign offset_6 = {{10{ir[5]}}, ir[5:0]};
assign PCoffset_9 = {{7{ir[8]}}, ir[8:0]};
assign PCoffset_11 = {{5{ir[10]}}, ir[10:0]};

// COMBINATIONAL CODES LOGIC


// MUX SIGNAL LOGIC FOR REGISTER AND MEMORY

// (how do you handle default values to insure that you only have a signal letting a m)
// what address gets read from memory? (HOW DO I HANDLE LOOP CASE FOR LDI )
assign r_addr_0_mem = (mem_raddr_sig == 2'b00) ? pc : 
                    (mem_raddr_sig == 2'b01) ? alu_output :
                        ldi1;

// what address are we writting too in memory? 

assign w_addr_mem = !mem_waddr_sig ? alu_output : sti1;

// What data do we write to memory? (CHECK)

assign w_data_mem = !w_data_mem_sig ? r_data_0_reg : r_data_1_reg;

// what gets loaded into pc? (CHECK r_addr_0[7])
reg [15:0] ircPC;
always @(posedge clk) begin
ircPC <= pc + 1;

end
assign nextPC = (pc_mux == 3'b000)  ? ircPC :  
                (pc_mux == 3'b001)  ? alu_output :
                // (pc_mux == 3'b010)   ?  ir[8:6] : 
                    r_data_0_reg;  

// what gets read by r_addr_0 in the register? 
assign r_addr_0_reg = (reg_raddr0_sig == 2'b00) ? ir[8:6] : 
                    (reg_raddr0_sig == 2'b01) ? ir[11:9] : 
                    (reg_raddr0_sig == 2'b10) ? 7 :
                    pc;
                    

// what gets read by r_addr_1? (SHOULD I KEEP AS ONLY INPUT BECAUSE ONLY ONE THING IS READ)
assign r_addr_1_reg = !reg_raddr1_sig ? ir[2:0] : ir[3:1];  

//which address are we writting too in the register?
assign w_addr_reg = !reg_waddr_sig ? ir[11:9] : 7; 

// what data are we writting into for the register
assign w_data_reg = (reg_wdata_sig == 2'b00) ? alu_output :
                    (reg_wdata_sig == 2'b01) ?  r_data_0_mem :
                    pc;

//which offset bits will be used as inputs for ALU? (MIGHT DELETE)

// assign offset_selected = (offset_sel == 2'b00) ? imm5 :
                //      (offset_sel == 2'b01) ? offset_6 :
                //      (offset_sel == 2'b10) ? PCoffset_9 :
                //      PCoffset_11;

// MUX SIGNAL LOGIC FOR ALU

// left side/first input of ALU operation
assign alu_input1 = !alu_input1_sig ? r_data_0_reg : pc;
    

// right side input of ALU operation
assign alu_input2 = (alu_input2_sig == 3'b000) ? r_data_1_reg :
                    (alu_input2_sig == 3'b001) ? imm5         : 
                    (alu_input2_sig == 3'b010) ? PCoffset_9    :
                    (alu_input2_sig == 3'b011) ? PCoffset_11   :
                        offset_6;

// What is the ALU doing?
assign alu_output = (alu_sig == 2'b00) ? (alu_input1 + alu_input2) :
                    (alu_sig == 2'b01) ? (alu_input1 & alu_input2) :
                    ~alu_input1;
                    


 
//DEBUGGING

//when declaring wires that are going into alu declare as wire signed[15:0], check (ask maria) about adding



// Goal is to set each signal in the controller based on which state we are in

wire [15:0] NZP_input;
assign NZP_input = !nzp_mux ? alu_output : r_data_0_mem;

always @( posedge clk) begin

if (cc_sig) begin
    N <= NZP_input[15];
    Z <= NZP_input== 0;
    P <= ~NZP_input[15] && ~(NZP_input == 0);
end
    
        if(ir_ld) begin
            ir <= r_data_0_mem; //ask about the difference between addr and data
        end

    
    //set the register thing here
    if(sti1_sig) begin
        sti1 <= r_data_0_mem;
    end

    if(ldi1_sig) begin
        ldi1 <= r_data_0_mem;
    end
            
        if(pc_ld) begin 
            pc <= nextPC;
        end

        if(rst) begin
        pc <= 0;
        
    
    end

    
end
endmodule

