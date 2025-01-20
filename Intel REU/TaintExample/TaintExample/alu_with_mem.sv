
// Two modes, mem[rd] = mem[rs1] ^ mem[rs2] or mem[rd] = mem[rs1] ^ imm
module alu_mem(
    `ifdef TAINT
    input rs1_t,
    input rs2_t,
    input rd_t,
    input imm_t,
    input mode_t,
    output result_t,
    `endif
    input clk,
    input rst,
    input [3:0] rs1,
    input [3:0] rs2,
    input [3:0] rd,
    input [7:0] imm,
    input mode,
    output [7:0] result
);

reg [7:0] mem [0:15];
wire [7:0] op1, op2;
wire reg_same;
`ifdef TAINT
reg [15:0] mem_t;
wire op1_t, op2_t;
`endif

// check if all memory is the same and not tainted

// check if operation could have actually changed memory

// check if sequence of trusted operations is redundant

// rs1 == rs2

// imm == mem[rs2]

reg [3:0] rs1_prev;
reg [3:0] rs2_prev;


assign op1 = mem[rs1];
assign op2 = mode ? imm : mem[rs2];
assign result = op1 ^ op2;
assign reg_same = rs1 == rs2;

`ifdef TAINT
assign op1_t = mem_t[rs1] || (rs1_t && rs1 != rs1_prev && result != mem[rd]);
assign op2_t = mode_t || (mode && imm_t) || (!mode && mem_t[rs2] || (!mode && rs2_t && rs2 != rs2_prev && result != mem[rd]));
assign result_t = (!reg_same && (op1_t || op2_t));
`endif

always @(posedge clk) begin
    mem[rd] <= result;

    rs1_prev <= rs1;
    rs2_prev <= rs2;


    `ifdef TAINT
    mem_t[rd] <= result_t || rd_t;
    `endif
end

// Only for verification purpose, facilitate property writing
reg init;
always @(posedge clk) begin
    if (rst)
        init <= 1;
    else
        init <= 0;
end

endmodule