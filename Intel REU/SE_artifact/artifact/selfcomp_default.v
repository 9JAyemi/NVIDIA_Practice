//==============================================================================
// Default SE Testing Module
//==============================================================================

`include "../SE_verilog/SE_default.v"

module DefaultTester (
  input clock,
  input reset,
  input [7:0] io_in_inst,
  input [127:0] io_in_op1,
  input [127:0] io_in_op2,
  input [127:0] io_in_cond,
  input  io_in_valid,
  output io_in_ready,
  output [127:0] io_out_resultOne,
  output [127:0] io_out_resultTwo,
  output io_out_validOne,
  output io_out_validTwo,
  input io_out_ready,
  output [7:0] io_out_cntr,
  output timingLeak,
  output timingLeakDone,
  output bothValid
);

SE se1(
  .clock(clock),
  .reset(reset),
  .io_in_inst(io_in_inst),
  .io_in_op1(io_in_op1),
  .io_in_op2(io_in_op2),
  .io_in_cond(io_in_cond),
  .io_in_valid(io_in_valid),
  .io_in_ready(io_in_ready),
  .io_out_result(io_out_resultOne),
  .io_out_valid(io_out_validOne),
  .io_out_ready(io_out_ready),
  .io_out_cntr(io_out_cntr)
);

SE se2(
  .clock(clock),
  .reset(reset),
  .io_in_inst(io_in_inst),
  .io_in_op1(io_in_op1),
  .io_in_op2(io_in_op2),
  .io_in_cond(io_in_cond),
  .io_in_valid(io_in_valid),
  .io_in_ready(io_in_ready),
  .io_out_result(io_out_resultTwo),
  .io_out_valid(io_out_validTwo),
  .io_out_ready(io_out_ready),
  .io_out_cntr(io_out_cntr)
);

assign oneValid = io_out_validOne | io_out_validTwo;
assign bothValid = io_out_validOne & io_out_validTwo;

endmodule