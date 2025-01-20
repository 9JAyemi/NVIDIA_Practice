analyze -sv MIPS_NonPipe.v

elaborate -top MIPS_CPU

clock clk
reset reset

#test that upon reset, resets program counter and alu results
assert {reset |-> (program_counter == 0) && (result == 0)}
