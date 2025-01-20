analyze -sv MIPS_NonPipe.v

elaborate -top Datapath

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (program_counter == 0) && (result == 0)}

# test ADD instruction executes in 1 clock cycle
assume {registers[rs] > 0 && registers[rt] > 0}
assert {instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000 && (reg_write) |-> ##1 registers[rd] == result }

# Set the time limit to 1 hour (3600 seconds)
set_prove_time_limit 3600
set_engine_mode Tri
prove -all