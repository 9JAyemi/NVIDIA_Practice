analyze -sv MIPS_NonPipe.v

elaborate -top MIPS_CPU

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (pc == 0) && (result == 0)}

# test ADD instruction executes in 1 clock cycle
 # assume {result > 0}
# assert { alu_op == 2'b00 && (reg_write) |-> ##1 result == registers[$past(rs)] + registers[$past(rt)]}

# assert {(!reset) && alu_src == 0 && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1  result == (registers[rs]) + (registers[rt]) && pc == $past(pc) + 4} 
# assert {(!reset) && alu_src == 0 && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && alu_op == 2'b00 && reg_write |-> ##1 (registers[$past(rd)] == result) && pc == $past(pc) + 4}

assume {pc == 0}
assert {(!reset) && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 |-> ##1  result == (registers[rs]) + (registers[rt]) && pc == $past(pc) + 4 && alu_op == 1} 
assert {(!reset) && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 |-> ##1  registers[$past(rd)] == $past(result) && pc == $past(pc) + 4}
assert {(!reset) && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 |-> ##1 reg_write == 1};
assert {(!reset) && instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100010 |-> ##1  registers[$past(rd)] == $past(result) && pc == $past(pc) + 4}


# test JR instruction executes in 1 clock cycle
assert {(!reset) && instruction[31:26] == 6'b000010 |-> ##1 j_db == 1};


# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600

set_engine_mode Tri
prove -all


