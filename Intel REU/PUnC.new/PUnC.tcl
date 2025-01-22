analyze -sv PUnC.v

elaborate -top PUnC


clock clk
reset rst

assert {rst |-> ##2 pc_debug_data == 0}
assume {pc_debug_data == 0}
assert {ir_output[15:12] == 4'b0001 && bit_5 == 0 |-> ##1 pc_debug_data == $past(pc_debug_data) + 1 && reg_w_en_sig == 1 && cc_sig == 1 && alu_sig == 0  }

prove -all