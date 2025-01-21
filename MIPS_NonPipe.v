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

    // Instantiate Datapath
    Datapath dp(
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .result(result)
    );

    // Instantiate Controller
    Controller ctrl(
        .opcode(instruction[31:26]),
        .funct(instruction[5:0]),
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
);
    
    reg [31:0] registers [0:31];
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
    input [5:0] opcode,
    input [5:0] funct,
    output reg alu_src,
    output reg reg_write,
    output reg [1:0] alu_op
);

    always @(*) begin
        case (opcode)
            6'b000000: begin // R-type instructions
                alu_src = 0;
                reg_write = 1;
                case (funct)
                    6'b100000: alu_op = 2'b00; // ADD
                    6'b100010: alu_op = 2'b01; // SUB
                    6'b100100: alu_op = 2'b10; // AND
                    6'b101010: alu_op = 2'b11; // SLT (for BLT and BGT)
                    6'b001000: begin // JR
                        alu_src = 0;
                        reg_write = 0;
                    end
                    default: alu_op = 2'b00;
                endcase
            end
            6'b001000: begin // ADDI
                alu_src = 1;
                reg_write = 1;
                alu_op = 2'b00;
            end
            6'b000100: begin // BEQ (using subtraction)
                alu_src = 0;
                reg_write = 0;
                alu_op = 2'b01;
            end
            6'b000101: begin // BNE (using subtraction)
                alu_src = 0;
                reg_write = 0;
                alu_op = 2'b01;
            end
            6'b001010: begin // BLT (assuming SLT logic)
                alu_src = 0;
                reg_write = 0;
                alu_op = 2'b11;
            end
            6'b001011: begin // BGT (using SLT with reversed operands)
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
    end

endmodule