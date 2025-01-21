analyze -sv MIPS_NonPipe.v

elaborate -top Datapath

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (top.dp.program_counter == 0) && (result == 0)}

# test ADD instruction executes in 1 clock cycle
assume {result > 0}
# assert { alu_op == 2'b00 && (reg_write) |-> ##1 result == registers[$past(rs)] + registers[$past(rt)]}
assert {(!reset) && alu_op == 2'b00 && reg_write |-> ##1 (result == $past(registers[rs]) + $past([rt]))} 
   # |-> ##1 (top.dp.registers[$past(top.dp.rd)] == result)}

# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600
set_hierarchical_access -enable
set_engine_mode Tri
prove -all


