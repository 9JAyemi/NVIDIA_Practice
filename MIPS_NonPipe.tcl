analyze -sv MIPS_NonPipe.v

elaborate -top MIPS_CPU

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (result == 0)}

# test ADD instruction executes in 1 clock cycle
 assume {result > 0}
 assert { alu_op == 2'b00 && (reg_write) |-> ##1 result == registers[$past(rs)] + registers[$past(rt)]}
assume {alu_src == 0}
assert {(!reset) && alu_src == 0 && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1  result == (registers[rs]) + (registers[rt])} 
assert {(!reset) && alu_src == 0 && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1 (registers[$past(rd)] == result)}


# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600

set_engine_mode Tri
prove -all


