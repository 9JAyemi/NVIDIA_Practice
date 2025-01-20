module alu_full(
    `ifdef TAINT
    input op1_t,
    input op2_t,
    input opcode_t,
    input ops_correlated_t,
    output reg result_t,
    output reg exception_t,
    `endif
    
    input clk,
    input rst,
    input [3:0] op1,
    input [3:0] op2,
    input [2:0] opcode,
    input [7:0] ops_correlated,
    output reg [7:0] result,
    output reg exception
);

parameter
    ADD = 3'b000,
    SUB = 3'b001,
    MUL = 3'b010,
    DIV = 3'b011,
    SLL = 3'b100,
    SRL = 3'b101,
    SLA = 3'b110,
    SRA = 3'b111,
    OP_WIDTH = 4; // bitwidth of op1 and op2

always @(*) begin
    exception = 0; // default value
    case (opcode)
        ADD: begin
            result = op1 + op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && (!ops_correlated[0] || ops_correlated_t);
            `endif
            end
        SUB: begin
            result = op1 - op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && (!ops_correlated[1] || ops_correlated_t);
            `endif
            end
        MUL: begin
            result = op1 * op2;
            `ifdef TAINT
            result_t = !((op1 == 0 && !op1_t) || (op2 == 0 && !op2_t)) && (op1_t || op2_t) && (!ops_correlated[2] || ops_correlated_t);
            `endif
            end
        /*
	DIV: begin
            result = op1 / op2;
            exception = (op2 == 0) ? 1 : 0;
            `ifdef TAINT
            result_t = !((op1 == 0 && !op1_t) || (op2 == 0 && !op2_t)) && (op1_t || op2_t) && (!ops_correlated[3] || ops_correlated_t);
            exception_t = (op2_t) ? 1: 0;
            `endif
            end
        */
	SLL: begin
            result = op1 << op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && !((op2 == 0 || op2 >= OP_WIDTH) && !op2_t) && (!ops_correlated[4] || ops_correlated_t);
            `endif
            end
        SRL: begin
            result = op1 >> op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && !((op2 == 0 || op2 >= OP_WIDTH) && !op2_t) && (!ops_correlated[5] || ops_correlated_t);
            `endif
            end
        SLA: begin
            result = op1 << op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && !((op2 == 0 || op2 >= OP_WIDTH) && !op2_t) && (!ops_correlated[6] || ops_correlated_t);
            `endif
            end
        SRA: begin
            result = op1 >> op2;
            `ifdef TAINT
            result_t = (op1_t || op2_t) && !((op2 == 0 || op2 >= OP_WIDTH) && !op2_t) && (!ops_correlated[7] || ops_correlated_t);
            `endif
            end
    endcase
end

// Only for verification purposes, facilitate property writing
reg init;
always @(posedge clk) begin
    if (rst)
        init <= 1;
    else
        init <= 0;
end

endmodule
