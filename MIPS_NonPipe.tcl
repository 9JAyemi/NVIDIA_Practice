analyze -sv MIPS_NonPipe.v

elaborate -top Datapath

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (program_counter == 0) && (result == 0)}

# test ADD instruction executes in 1 clock cycle
# assume {result > 0}
# assert { alu_op == 2'b00 && (reg_write) |-> ##1 result == registers[$past(rs)] + registers[$past(rt)]}
assume {instruction[31:26] == 6'b000000 |-> ##1 $stable(instruction[31:26])}
assume {instruction[5:0] == 6'b100000 |-> ##1 $stable(instruction[5:0])}
assume {alu_op == 1 |-> ##1 $stable(alu_op)}
assume {reg_write == 1 |-> ##1 $stable (reg_write)}

assert {(!reset) && !alu_src && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1  result == $past(registers[$past(rs)]) + $past(registers[$past(rt)])} 
assert {(!reset) && !alu_src && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1 (registers[$past(rd)] == result)}


# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600

set_engine_mode Tri
prove -all


