// Top-level module for a non-pipelined MIPS CPU
module MIPS_CPU(
    input clk,
    input reset,
    input [31:0] instruction,
    output [31:0] result
);
    
    // Internal signals
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd;
    wire [31:0] reg_data1, reg_data2, alu_result, immediate;
    wire alu_src, reg_write;
    wire [1:0] alu_op;
    reg [31:0] registers [0:31];

    // Instantiate Datapath
    Datapath dp(
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .result(result),
        .registers(registers)
    );

    // Instantiate Controller
    Controller ctrl(
        .opcode(instruction[31:26]),
        .funct(instruction[5:0]),
        .registers(registers),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op)
    );

endmodule

// Datapath module
module Datapath(
    input clk,
    input reset,
    input [31:0] instruction,
    input alu_src,
    input reg_write,
    input [1:0] alu_op,
    output reg [31:0] result
    output reg [31:0] registers [0:31];
);
    
   // reg [31:0] registers [0:31];
    reg [31:0] alu_input1, alu_input2;
    reg [31:0] program_counter;  // Added Program Counter
    wire [4:0] rs, rt, rd;
    wire [15:0] immediate;
    wire [31:0] sign_ext_imm;

    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign immediate = instruction[15:0];
    assign sign_ext_imm = {{16{immediate[15]}}, immediate};

    always @(*) begin
        alu_input1 = registers[rs];
        alu_input2 = alu_src ? sign_ext_imm : registers[rt];
    end
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            program_counter <= 0;  // Reset PC
            result <= 0;
            
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 0;  // Reset all registers
        end
        end else begin
            program_counter <= program_counter + 4;  // Increment PC by 4
            case (alu_op)
                2'b00: result <= alu_input1 + alu_input2; // ADD
                2'b01: result <= alu_input1 - alu_input2; // SUB
                2'b10: result <= alu_input1 & alu_input2; // AND
                2'b11: result <= (alu_input1 < alu_input2) ? 1 : 0; // SLT (used for BLT)
                default: result <= 0;
            endcase
            if (reg_write) begin
                registers[rd] <= result;
            end
        end
    end

    always @(posedge clk) begin
        if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b001000) begin // JR
            program_counter <= registers[rs];  // Jump to register address
        end
    end

endmodule

// Controller module
module Controller(
    input clk,
    input reset,
    input [5:0] opcode,
    input [5:0] funct,
    input [31:0] registers [0:31];
    output reg alu_src,
    output reg reg_write,
    output reg [1:0] alu_op
);

    // State definition
    typedef enum logic [1:0] {
        IDLE, EXECUTE
    } state_t;

    state_t current_state, next_state;

    // Sequential logic for state transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        next_state = current_state;
        alu_src = 0;
        reg_write = 0;
        alu_op = 2'b00;
        case (current_state)
            IDLE: begin
                if (opcode != 6'b000000 || funct != 6'b001000) begin
                    next_state = EXECUTE;
                end
            end
            EXECUTE: begin
                case (opcode)
                    6'b000000: begin // R-type instructions
                        alu_src = 0;
                        reg_write = 1;
                        case (funct)
                            6'b100000: alu_op = 2'b00; // ADD
                            6'b100010: alu_op = 2'b01; // SUB
                            6'b100100: alu_op = 2'b10; // AND
                            6'b101010: alu_op = 2'b11; // SLT
                            6'b001000: begin // JR
                                alu_src = 0;
                                reg_write = 0;
                                next_state = IDLE;
                            end
                            default: alu_op = 2'b00;
                        endcase
                    end
                    6'b001000: begin // ADDI
                        alu_src = 1;
                        reg_write = 1;
                        alu_op = 2'b00;
                    end
                    6'b000100: begin // BEQ
                        alu_src = 0;
                        reg_write = 0;
                        alu_op = 2'b01;
                    end
                    6'b000101: begin // BNE
                        alu_src = 0;
                        reg_write = 0;
                        alu_op = 2'b01;
                    end
                    6'b001010: begin // BLT
                        alu_src = 0;
                        reg_write = 0;
                        alu_op = 2'b11;
                    end
                    6'b001011: begin // BGT
                        alu_src = 0;
                        reg_write = 0;
                        alu_op = 2'b11;
                    end
                    default: begin
                        alu_src = 0;
                        reg_write = 0;
                        alu_op = 2'b00;
                    end
                endcase
                next_state = IDLE;
            end
        endcase
    end

endmodule
