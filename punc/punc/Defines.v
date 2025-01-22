//==============================================================================
// Global Defines for PUnC LC3 Computer
//==============================================================================

// Add defines here that you'll use in both the datapath and the controller

//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12       // Used to select opcode bits from the IR

`define DR_11to9 11:9
`define Bit5 5 // was 4
`define SR1_8to6 8:6
`define SR2_2to0 2:0
`define PCOffset9 8:0
`define imm5 4:0
`define BaseR_8to6 8:6
`define PCOffset11 10:0
`define offset6 5:0
`define SR_11to9 11:9

`define OC_ADD 4'b0001 // Instruction-specific opcodes
`define OC_AND 4'b0101
`define OC_BR  4'b0000
`define OC_JMP 4'b1100
`define OC_JSR 4'b0100
`define OC_LD  4'b0010
`define OC_LDIC1 4'b1010
`define OC_LDIC2 5'b11010
`define OC_LDR 4'b0110
`define OC_LEA 4'b1110
`define OC_NOT 4'b1001
`define OC_ST  4'b0011
`define OC_STI1 4'b1011
`define OC_STI2 5'b11011
`define OC_STR 4'b0111
`define OC_HLT 4'b1111

`define IMM_BIT_NUM 5  // Bit for distinguishing ADDR/ADDI and ANDR/ANDI
`define IS_IMM 1'b1
`define JSR_BIT_NUM 11 // Bit for distinguishing JSR/JSRR
`define IS_JSR 1'b1

`define BR_N 11        // Location of special bits in BR instruction
`define BR_Z 10
`define BR_P 9

`define ALU_FN_PASS 2'b00
`define ALU_FN_ADD 2'b01
`define ALU_FN_AND 2'b10
`define ALU_FN_NOT 2'b11

`define MUX_SELECT_ZERO 2'b00
`define MUX_SELECT_ONE 2'b01
`define MUX_SELECT_TWO 2'b10
`define MUX_SELECT_THREE 2'b11
